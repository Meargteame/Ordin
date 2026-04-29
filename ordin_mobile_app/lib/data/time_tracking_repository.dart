import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/time_entry.dart';
import '../models/task.dart';
import 'task_repository.dart';
import 'storage_service.dart';

class TimeTrackingRepository {
  late Box<TimeEntry> _timeEntriesBox;
  late TaskRepository _taskRepository;

  Future<void> init(StorageService storage) async {
    _timeEntriesBox = await Hive.openBox<TimeEntry>('timeEntries');
    _taskRepository = TaskRepository(storage);
  }

  Future<List<TimeEntry>> loadTimeEntries() async {
    return _timeEntriesBox.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  Future<void> saveTimeEntry(TimeEntry entry) async {
    await _timeEntriesBox.put(entry.id, entry);
  }

  Future<void> deleteTimeEntry(String id) async {
    await _timeEntriesBox.delete(id);
  }

  Future<TimeEntry?> getActiveTimer() async {
    return _timeEntriesBox.values
        .where((entry) => entry.isRunning)
        .firstOrNull;
  }

  Future<TimeEntry> startTimer(String? taskId, String category) async {
    final activeTimer = await getActiveTimer();
    if (activeTimer != null) {
      await stopTimer();
    }

    final entry = TimeEntry(
      id: const Uuid().v4(),
      taskId: taskId,
      startTime: DateTime.now(),
      endTime: null,
      durationMinutes: 0,
      category: category,
      notes: '',
    );

    await saveTimeEntry(entry);
    return entry;
  }

  Future<TimeEntry?> stopTimer() async {
    final activeTimer = await getActiveTimer();
    if (activeTimer == null) return null;

    activeTimer.endTime = DateTime.now();
    activeTimer.durationMinutes = activeTimer.calculateDuration();
    await saveTimeEntry(activeTimer);
    
    return activeTimer;
  }

  Future<List<TimeEntry>> getEntriesForDateRange(DateTime start, DateTime end) async {
    return _timeEntriesBox.values
        .where((entry) =>
            entry.startTime.isAfter(start.subtract(const Duration(days: 1))) &&
            entry.startTime.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  Future<List<TimeEntry>> getEntriesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getEntriesForDateRange(startOfDay, endOfDay);
  }

  Future<Map<String, int>> getTimeByCategory(DateTime start, DateTime end) async {
    final entries = await getEntriesForDateRange(start, end);
    final report = <String, int>{};

    for (final entry in entries) {
      if (entry.endTime != null) {
        report[entry.category] = (report[entry.category] ?? 0) + entry.durationMinutes;
      }
    }

    return report;
  }

  Future<Map<String, int>> getTimeByGoal(DateTime start, DateTime end) async {
    final entries = await getEntriesForDateRange(start, end);
    final tasks = await _taskRepository.loadTasks();
    final taskMap = {for (var t in tasks) t.id: t};
    final report = <String, int>{};

    for (final entry in entries) {
      if (entry.endTime != null && entry.taskId != null) {
        final task = taskMap[entry.taskId];
        if (task != null) {
          for (final goalId in task.goalIds) {
            report[goalId] = (report[goalId] ?? 0) + entry.durationMinutes;
          }
        }
      }
    }

    return report;
  }

  Future<int> getTotalMinutesForDate(DateTime date) async {
    final entries = await getEntriesForDate(date);
    return entries
        .where((e) => e.endTime != null)
        .fold<int>(0, (sum, e) => sum + e.durationMinutes);
  }

  Future<Map<String, int>> getTodayTimeByCategory() async {
    return getTimeByCategory(DateTime.now(), DateTime.now());
  }
}

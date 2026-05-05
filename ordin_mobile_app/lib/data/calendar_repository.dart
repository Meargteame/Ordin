import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/recurring_task.dart';
import '../models/time_block.dart';
import 'task_repository.dart';
import 'storage_service.dart';

class CalendarRepository {
  late Box<RecurringTask> _recurringTasksBox;
  late Box<TimeBlock> _timeBlocksBox;
  late TaskRepository _taskRepository;

  Future<void> init(StorageService storage) async {
    _recurringTasksBox = await Hive.openBox<RecurringTask>('recurringTasks');
    _timeBlocksBox = await Hive.openBox<TimeBlock>('timeBlocks');
    _taskRepository = TaskRepository(storage);
  }

  Future<List<Task>> getTasksForDateRange(DateTime start, DateTime end) async {
    final allTasks = await _taskRepository.loadTasks();
    return allTasks.where((task) {
      return task.date.isAfter(start.subtract(const Duration(days: 1))) &&
          task.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<List<TimeBlock>> getTimeBlocksForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _timeBlocksBox.values.where((block) {
      return block.startTime.isAfter(startOfDay.subtract(const Duration(minutes: 1))) &&
          block.startTime.isBefore(endOfDay);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<void> saveTimeBlock(TimeBlock block) async {
    await _timeBlocksBox.put(block.id, block);
  }

  Future<void> deleteTimeBlock(String id) async {
    await _timeBlocksBox.delete(id);
  }

  Future<bool> hasOverlappingTimeBlock(DateTime start, DateTime end, String? excludeId) async {
    final date = start;
    final blocks = await getTimeBlocksForDate(date);
    
    final testBlock = TimeBlock(
      id: 'test',
      startTime: start,
      endTime: end,
      title: 'test',
    );

    for (final block in blocks) {
      if (block.id != excludeId && block.overlaps(testBlock)) {
        return true;
      }
    }

    return false;
  }

  Future<List<RecurringTask>> loadRecurringTasks() async {
    return _recurringTasksBox.values.toList()
      ..sort((a, b) => a.nextOccurrence.compareTo(b.nextOccurrence));
  }

  Future<void> saveRecurringTask(RecurringTask task) async {
    await _recurringTasksBox.put(task.id, task);
  }

  Future<void> deleteRecurringTask(String id) async {
    await _recurringTasksBox.delete(id);
  }

  Future<void> generateNextOccurrence(String recurringTaskId) async {
    final recurringTask = _recurringTasksBox.get(recurringTaskId);
    if (recurringTask == null) return;

    if (recurringTask.endDate != null &&
        recurringTask.nextOccurrence.isAfter(recurringTask.endDate!)) {
      return;
    }

    final task = Task(
      id: const Uuid().v4(),
      title: recurringTask.title,
      isDone: false,
      date: recurringTask.nextOccurrence,
      goalIds: [],
    );

    await _taskRepository.saveTask(task);

    recurringTask.nextOccurrence = calculateNextOccurrence(recurringTask);
    await saveRecurringTask(recurringTask);
  }

  DateTime calculateNextOccurrence(RecurringTask task) {
    final current = task.nextOccurrence;

    switch (task.pattern) {
      case RecurrencePattern.daily:
        return current.add(const Duration(days: 1));
      case RecurrencePattern.weekly:
        return current.add(const Duration(days: 7));
      case RecurrencePattern.monthly:
        return DateTime(
          current.month == 12 ? current.year + 1 : current.year,
          current.month == 12 ? 1 : current.month + 1,
          current.day,
          current.hour,
          current.minute,
        );
      case RecurrencePattern.custom:
        return current.add(const Duration(days: 1));
    }
  }

  Future<void> checkAndGenerateRecurringTasks() async {
    final recurringTasks = await loadRecurringTasks();
    final now = DateTime.now();

    for (final recurringTask in recurringTasks) {
      while (recurringTask.nextOccurrence.isBefore(now) ||
          recurringTask.nextOccurrence.day == now.day &&
              recurringTask.nextOccurrence.month == now.month &&
              recurringTask.nextOccurrence.year == now.year) {
        await generateNextOccurrence(recurringTask.id);
        
        if (recurringTask.endDate != null &&
            recurringTask.nextOccurrence.isAfter(recurringTask.endDate!)) {
          break;
        }
      }
    }
  }

  Future<Map<DateTime, int>> getUpcomingDays(int days) async {
    final now = DateTime.now();
    final upcoming = <DateTime, int>{};

    for (int i = 1; i <= days; i++) {
      final date = now.add(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      
      final tasks = await getTasksForDateRange(startOfDay, startOfDay);
      final blocks = await getTimeBlocksForDate(startOfDay);
      
      upcoming[startOfDay] = tasks.length + blocks.length;
    }

    return upcoming;
  }
}
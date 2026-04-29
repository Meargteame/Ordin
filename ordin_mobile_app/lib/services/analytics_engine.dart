import '../models/task.dart';
import '../models/habit.dart';
import '../models/goal.dart';
import '../models/time_entry.dart';
import '../data/task_repository.dart';
import '../data/habit_repository.dart';
import '../data/goal_repository.dart';
import '../data/time_tracking_repository.dart';
import '../data/storage_service.dart';

class AnalyticsEngine {
  late TaskRepository _taskRepository;
  late HabitRepository _habitRepository;
  late GoalRepository _goalRepository;
  late TimeTrackingRepository _timeRepository;

  Future<void> init(StorageService storage) async {
    _taskRepository = TaskRepository(storage);
    _habitRepository = HabitRepository(storage);
    _goalRepository = GoalRepository();
    await _goalRepository.init(storage);
    _timeRepository = TimeTrackingRepository();
    await _timeRepository.init(storage);
  }

  Future<double> calculateProductivityScore(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final tasks = await _taskRepository.loadTasks();
    final todayTasks = tasks.where((t) =>
        t.date.year == date.year &&
        t.date.month == date.month &&
        t.date.day == date.day).toList();
    
    final taskScore = todayTasks.isEmpty
        ? 0.0
        : todayTasks.where((t) => t.isDone).length / todayTasks.length;

    final habits = await _habitRepository.loadHabits();
    final habitScore = habits.isEmpty
        ? 0.0
        : habits.where((h) => h.isDoneToday).length / habits.length;

    final totalMinutes = await _timeRepository.getTotalMinutesForDate(date);
    final timeScore = (totalMinutes / 480.0).clamp(0.0, 1.0);

    final goals = await _goalRepository.getActiveGoals();
    double goalScore = 0.0;
    if (goals.isNotEmpty) {
      int goalsProgressed = 0;
      for (final goal in goals) {
        final previousProgress = await _getPreviousProgress(goal.id, date);
        if (goal.progress > previousProgress) {
          goalsProgressed++;
        }
      }
      goalScore = goalsProgressed / goals.length;
    }

    return (taskScore * 0.3) + (habitScore * 0.25) + (timeScore * 0.25) + (goalScore * 0.2);
  }

  Future<double> _getPreviousProgress(String goalId, DateTime date) async {
    return 0.0;
  }

  Future<Map<int, double>> getProductivityTrend(DateTime start, DateTime end) async {
    final trend = <int, double>{};
    var current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final score = await calculateProductivityScore(current);
      trend[current.millisecondsSinceEpoch] = score;
      current = current.add(const Duration(days: 1));
    }

    return trend;
  }

  Future<Map<int, int>> getMostProductiveHours() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final entries = await _timeRepository.getEntriesForDateRange(thirtyDaysAgo, now);

    final hourCounts = <int, int>{};
    for (final entry in entries) {
      if (entry.endTime != null) {
        final hour = entry.startTime.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + entry.durationMinutes;
      }
    }

    return hourCounts;
  }

  Future<Map<int, double>> getMostProductiveDays() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final dayScores = <int, double>{};
    var current = thirtyDaysAgo;

    while (current.isBefore(now)) {
      final score = await calculateProductivityScore(current);
      dayScores[current.weekday] = (dayScores[current.weekday] ?? 0.0) + score;
      current = current.add(const Duration(days: 1));
    }

    final dayCounts = <int, int>{};
    current = thirtyDaysAgo;
    while (current.isBefore(now)) {
      dayCounts[current.weekday] = (dayCounts[current.weekday] ?? 0) + 1;
      current = current.add(const Duration(days: 1));
    }

    for (final day in dayScores.keys) {
      dayScores[day] = dayScores[day]! / dayCounts[day]!;
    }

    return dayScores;
  }

  Future<Map<DateTime, int>> getHabitCompletionHeatmap(String habitId, int days) async {
    final heatmap = <DateTime, int>{};
    return heatmap;
  }

  Future<Map<String, dynamic>> getCrossAreaInsights() async {
    final insights = <String, dynamic>{};
    
    final now = DateTime.now();
    final score = await calculateProductivityScore(now);
    insights['todayScore'] = (score * 100).toInt();

    final weekAgo = now.subtract(const Duration(days: 7));
    final weekScores = await getProductivityTrend(weekAgo, now);
    final avgWeekScore = weekScores.values.isEmpty
        ? 0.0
        : weekScores.values.reduce((a, b) => a + b) / weekScores.length;
    insights['weekAverage'] = (avgWeekScore * 100).toInt();

    final timeByCategory = await _timeRepository.getTodayTimeByCategory();
    insights['topCategory'] = timeByCategory.entries.isEmpty
        ? 'None'
        : timeByCategory.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return insights;
  }
}

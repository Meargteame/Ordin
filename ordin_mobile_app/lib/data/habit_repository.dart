import 'dart:convert';
import '../models/habit.dart';
import 'storage_service.dart';

class HabitRepository {
  final StorageService _storage;
  static const String _habitsKey = 'habits';
  static const String _lastCheckDateKey = 'lastCheckDate';

  HabitRepository(this._storage);

  Future<List<Habit>> loadHabits() async {
    try {
      final habitJsonList = await _storage.getList(_habitsKey);
      return habitJsonList
          .map((jsonStr) => Habit.fromJson(json.decode(jsonStr)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveHabit(Habit habit) async {
    final habits = await loadHabits();
    final existingIndex = habits.indexWhere((h) => h.id == habit.id);
    
    if (existingIndex != -1) {
      habits[existingIndex] = habit;
    } else {
      habits.add(habit);
    }

    await _saveHabits(habits);
  }

  Future<void> deleteHabit(String id) async {
    final habits = await loadHabits();
    habits.removeWhere((habit) => habit.id == id);
    await _saveHabits(habits);
  }

  Future<void> performDailyReset() async {
    final currentDate = DateTime.now();
    final lastCheckDateStr = await _storage.getString(_lastCheckDateKey);
    
    if (lastCheckDateStr == null) {
      await _saveLastCheckDate(currentDate);
      return;
    }

    final lastCheckDate = DateTime.parse(lastCheckDateStr);
    
    if (_isSameDay(lastCheckDate, currentDate)) {
      return;
    }

    final habits = await loadHabits();
    for (final habit in habits) {
      if (!habit.isDoneToday) {
        habit.streak = 0;
      }
      habit.isDoneToday = false;
    }

    await _saveHabits(habits);
    await _saveLastCheckDate(currentDate);
  }

  Future<void> _saveHabits(List<Habit> habits) async {
    final habitJsonList = habits
        .map((habit) => json.encode(habit.toJson()))
        .toList();
    await _storage.saveList(_habitsKey, habitJsonList);
  }

  Future<void> _saveLastCheckDate(DateTime date) async {
    await _storage.saveString(_lastCheckDateKey, date.toIso8601String());
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

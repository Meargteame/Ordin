enum HabitFrequency { daily, weekdays, weekends, custom }
enum HabitCategory { morning, afternoon, evening, anytime, health, productivity, personal }

class Habit {
  final String id;
  final String name;
  String? description;
  bool isDoneToday;
  int streak;
  int bestStreak;
  HabitFrequency frequency;
  HabitCategory category;
  List<int> customDays; // 1=Monday, 7=Sunday
  String? reminderTime; // HH:mm format
  Map<String, bool> completionHistory; // date -> completed
  DateTime createdAt;
  int totalCompletions;
  List<String> linkedHabitIds; // For habit stacking

  Habit({
    required this.id,
    required this.name,
    this.description,
    required this.isDoneToday,
    required this.streak,
    this.bestStreak = 0,
    this.frequency = HabitFrequency.daily,
    this.category = HabitCategory.anytime,
    List<int>? customDays,
    this.reminderTime,
    Map<String, bool>? completionHistory,
    DateTime? createdAt,
    this.totalCompletions = 0,
    List<String>? linkedHabitIds,
  }) : customDays = customDays ?? [],
       completionHistory = completionHistory ?? {},
       createdAt = createdAt ?? DateTime.now(),
       linkedHabitIds = linkedHabitIds ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isDoneToday': isDoneToday,
      'streak': streak,
      'bestStreak': bestStreak,
      'frequency': frequency.name,
      'category': category.name,
      'customDays': customDays,
      'reminderTime': reminderTime,
      'completionHistory': completionHistory,
      'createdAt': createdAt.toIso8601String(),
      'totalCompletions': totalCompletions,
      'linkedHabitIds': linkedHabitIds,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isDoneToday: json['isDoneToday'] ?? false,
      streak: json['streak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      frequency: HabitFrequency.values.firstWhere(
        (f) => f.name == json['frequency'],
        orElse: () => HabitFrequency.daily,
      ),
      category: HabitCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => HabitCategory.anytime,
      ),
      customDays: json['customDays'] != null ? List<int>.from(json['customDays']) : [],
      reminderTime: json['reminderTime'],
      completionHistory: json['completionHistory'] != null 
        ? Map<String, bool>.from(json['completionHistory'])
        : {},
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
      totalCompletions: json['totalCompletions'] ?? 0,
      linkedHabitIds: json['linkedHabitIds'] != null 
        ? List<String>.from(json['linkedHabitIds'])
        : [],
    );
  }

  void toggle(DateTime date) {
    final dateKey = _dateKey(date);
    isDoneToday = !isDoneToday;
    completionHistory[dateKey] = isDoneToday;
    
    if (isDoneToday) {
      streak++;
      totalCompletions++;
      if (streak > bestStreak) {
        bestStreak = streak;
      }
    } else {
      streak = streak > 0 ? streak - 1 : 0;
      totalCompletions = totalCompletions > 0 ? totalCompletions - 1 : 0;
    }
  }

  bool isScheduledForToday() {
    final now = DateTime.now();
    final weekday = now.weekday; // 1=Monday, 7=Sunday
    
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekdays:
        return weekday >= 1 && weekday <= 5;
      case HabitFrequency.weekends:
        return weekday == 6 || weekday == 7;
      case HabitFrequency.custom:
        return customDays.contains(weekday);
    }
  }

  double get successRate {
    if (completionHistory.isEmpty) return 0;
    final completed = completionHistory.values.where((v) => v).length;
    return completed / completionHistory.length;
  }

  int get completedDaysThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      if (date.isAfter(now)) break;
      final key = _dateKey(date);
      if (completionHistory[key] == true) count++;
    }
    
    return count;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class Habit {
  final String id;
  final String name;
  bool isDoneToday;
  int streak;

  Habit({
    required this.id,
    required this.name,
    required this.isDoneToday,
    required this.streak,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isDoneToday': isDoneToday,
      'streak': streak,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      isDoneToday: json['isDoneToday'],
      streak: json['streak'],
    );
  }

  void toggle() {
    isDoneToday = !isDoneToday;
    if (isDoneToday) {
      streak++;
    } else {
      streak = streak > 0 ? streak - 1 : 0;
    }
  }
}

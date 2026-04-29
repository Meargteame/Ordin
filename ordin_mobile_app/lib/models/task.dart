class Task {
  final String id;
  final String title;
  bool isDone;
  final DateTime date;

  Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'date': date.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isDone: json['isDone'],
      date: DateTime.parse(json['date']),
    );
  }

  bool isScheduledFor(DateTime targetDate) {
    return date.year == targetDate.year &&
           date.month == targetDate.month &&
           date.day == targetDate.day;
  }
}

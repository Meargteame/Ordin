class Task {
  final String id;
  final String title;
  bool isDone;
  final DateTime date;
  String? projectId;
  List<String> goalIds;
  String? description;
  int? estimatedMinutes;

  Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.date,
    this.projectId,
    List<String>? goalIds,
    this.description,
    this.estimatedMinutes,
  }) : goalIds = goalIds ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'date': date.toIso8601String(),
      'projectId': projectId,
      'goalIds': goalIds,
      'description': description,
      'estimatedMinutes': estimatedMinutes,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isDone: json['isDone'],
      date: DateTime.parse(json['date']),
      projectId: json['projectId'],
      goalIds: json['goalIds'] != null ? List<String>.from(json['goalIds']) : [],
      description: json['description'],
      estimatedMinutes: json['estimatedMinutes'],
    );
  }

  bool isScheduledFor(DateTime targetDate) {
    return date.year == targetDate.year &&
           date.month == targetDate.month &&
           date.day == targetDate.day;
  }
}

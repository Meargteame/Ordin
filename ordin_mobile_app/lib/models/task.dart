enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  bool isDone;
  final DateTime date;
  DateTime? dueDate;
  TaskPriority priority;
  List<String> tags;
  String? projectId;
  List<String> goalIds;
  String? description;
  int? estimatedMinutes;
  List<Subtask> subtasks;

  Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.date,
    this.dueDate,
    this.priority = TaskPriority.medium,
    List<String>? tags,
    this.projectId,
    List<String>? goalIds,
    this.description,
    this.estimatedMinutes,
    List<Subtask>? subtasks,
  }) : goalIds = goalIds ?? [],
       tags = tags ?? [],
       subtasks = subtasks ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'date': date.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,
      'tags': tags,
      'projectId': projectId,
      'goalIds': goalIds,
      'description': description,
      'estimatedMinutes': estimatedMinutes,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isDone: json['isDone'],
      date: DateTime.parse(json['date']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      projectId: json['projectId'],
      goalIds: json['goalIds'] != null ? List<String>.from(json['goalIds']) : [],
      description: json['description'],
      estimatedMinutes: json['estimatedMinutes'],
      subtasks: json['subtasks'] != null 
        ? (json['subtasks'] as List).map((s) => Subtask.fromJson(s)).toList()
        : [],
    );
  }

  bool isScheduledFor(DateTime targetDate) {
    return date.year == targetDate.year &&
           date.month == targetDate.month &&
           date.day == targetDate.day;
  }

  bool get isOverdue {
    if (dueDate == null || isDone) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
           dueDate!.month == now.month &&
           dueDate!.day == now.day;
  }

  int get completedSubtasks => subtasks.where((s) => s.isDone).length;
  double get subtaskProgress => subtasks.isEmpty ? 0 : completedSubtasks / subtasks.length;
}

class Subtask {
  final String id;
  final String title;
  bool isDone;

  Subtask({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isDone': isDone,
  };

  factory Subtask.fromJson(Map<String, dynamic> json) => Subtask(
    id: json['id'],
    title: json['title'],
    isDone: json['isDone'] ?? false,
  );
}

import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 10)
class Goal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  GoalCategory category;

  @HiveField(4)
  GoalStatus status;

  @HiveField(5)
  Priority priority;

  @HiveField(6)
  DateTime? deadline;

  @HiveField(7)
  String successMetrics;

  @HiveField(8)
  double progress;

  @HiveField(9)
  List<String> linkedTaskIds;

  @HiveField(10)
  List<String> linkedProjectIds;

  @HiveField(11)
  final DateTime createdDate;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    this.deadline,
    required this.successMetrics,
    required this.progress,
    required this.linkedTaskIds,
    required this.linkedProjectIds,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'status': status.index,
      'priority': priority.index,
      'deadline': deadline?.toIso8601String(),
      'successMetrics': successMetrics,
      'progress': progress,
      'linkedTaskIds': linkedTaskIds,
      'linkedProjectIds': linkedProjectIds,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: GoalCategory.values[json['category']],
      status: GoalStatus.values[json['status']],
      priority: Priority.values[json['priority']],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      successMetrics: json['successMetrics'],
      progress: json['progress'],
      linkedTaskIds: List<String>.from(json['linkedTaskIds']),
      linkedProjectIds: List<String>.from(json['linkedProjectIds']),
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}

@HiveType(typeId: 11)
enum GoalCategory {
  @HiveField(0)
  career,
  @HiveField(1)
  health,
  @HiveField(2)
  finance,
  @HiveField(3)
  relationships,
  @HiveField(4)
  personalGrowth,
  @HiveField(5)
  learning,
}

@HiveType(typeId: 12)
enum GoalStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  completed,
  @HiveField(2)
  archived,
  @HiveField(3)
  onHold,
}

@HiveType(typeId: 13)
enum Priority {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low,
}

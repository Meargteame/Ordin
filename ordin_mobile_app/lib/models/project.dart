import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 20)
class Project extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  ProjectStatus status;

  @HiveField(4)
  String category;

  @HiveField(5)
  DateTime? deadline;

  @HiveField(6)
  String? linkedGoalId;

  @HiveField(7)
  double progress;

  @HiveField(8)
  final DateTime createdDate;

  @HiveField(9)
  DateTime? completedDate;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    this.deadline,
    this.linkedGoalId,
    required this.progress,
    required this.createdDate,
    this.completedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.index,
      'category': category,
      'deadline': deadline?.toIso8601String(),
      'linkedGoalId': linkedGoalId,
      'progress': progress,
      'createdDate': createdDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: ProjectStatus.values[json['status']],
      category: json['category'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      linkedGoalId: json['linkedGoalId'],
      progress: json['progress'],
      createdDate: DateTime.parse(json['createdDate']),
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
    );
  }
}

@HiveType(typeId: 21)
enum ProjectStatus {
  @HiveField(0)
  planning,
  @HiveField(1)
  active,
  @HiveField(2)
  onHold,
  @HiveField(3)
  completed,
  @HiveField(4)
  archived,
}

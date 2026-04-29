import 'package:hive/hive.dart';

part 'milestone.g.dart';

@HiveType(typeId: 14)
class Milestone extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String goalId;

  @HiveField(2)
  String title;

  @HiveField(3)
  DateTime targetDate;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  DateTime? completedDate;

  Milestone({
    required this.id,
    required this.goalId,
    required this.title,
    required this.targetDate,
    required this.isCompleted,
    this.completedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'title': title,
      'targetDate': targetDate.toIso8601String(),
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'],
      goalId: json['goalId'],
      title: json['title'],
      targetDate: DateTime.parse(json['targetDate']),
      isCompleted: json['isCompleted'],
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
    );
  }
}

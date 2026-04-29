import 'package:hive/hive.dart';

part 'task_dependency.g.dart';

@HiveType(typeId: 24)
class TaskDependency extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final String dependsOnTaskId;

  TaskDependency({
    required this.id,
    required this.taskId,
    required this.dependsOnTaskId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'dependsOnTaskId': dependsOnTaskId,
    };
  }

  factory TaskDependency.fromJson(Map<String, dynamic> json) {
    return TaskDependency(
      id: json['id'],
      taskId: json['taskId'],
      dependsOnTaskId: json['dependsOnTaskId'],
    );
  }
}

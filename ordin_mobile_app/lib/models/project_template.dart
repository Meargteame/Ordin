import 'package:hive/hive.dart';

part 'project_template.g.dart';

@HiveType(typeId: 22)
class ProjectTemplate extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<TaskTemplate> taskTemplates;

  ProjectTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.taskTemplates,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'taskTemplates': taskTemplates.map((t) => t.toJson()).toList(),
    };
  }

  factory ProjectTemplate.fromJson(Map<String, dynamic> json) {
    return ProjectTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      taskTemplates: (json['taskTemplates'] as List)
          .map((t) => TaskTemplate.fromJson(t))
          .toList(),
    );
  }
}

@HiveType(typeId: 23)
class TaskTemplate {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? description;

  @HiveField(2)
  int? estimatedMinutes;

  @HiveField(3)
  List<String> dependsOnTitles;

  TaskTemplate({
    required this.title,
    this.description,
    this.estimatedMinutes,
    required this.dependsOnTitles,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'estimatedMinutes': estimatedMinutes,
      'dependsOnTitles': dependsOnTitles,
    };
  }

  factory TaskTemplate.fromJson(Map<String, dynamic> json) {
    return TaskTemplate(
      title: json['title'],
      description: json['description'],
      estimatedMinutes: json['estimatedMinutes'],
      dependsOnTitles: List<String>.from(json['dependsOnTitles'] ?? []),
    );
  }
}

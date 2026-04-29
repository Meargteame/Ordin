import 'package:hive/hive.dart';

part 'learning_item.g.dart';

@HiveType(typeId: 68)
class LearningItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  LearningType type;

  @HiveField(3)
  LearningStatus status;

  @HiveField(4)
  double progress;

  @HiveField(5)
  DateTime? completedDate;

  LearningItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.progress,
    this.completedDate,
  });
}

@HiveType(typeId: 69)
enum LearningType {
  @HiveField(0)
  book,
  @HiveField(1)
  course,
  @HiveField(2)
  skill,
  @HiveField(3)
  certification,
}

@HiveType(typeId: 70)
enum LearningStatus {
  @HiveField(0)
  notStarted,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  paused,
}

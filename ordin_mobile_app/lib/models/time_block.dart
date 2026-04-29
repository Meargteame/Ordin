import 'package:hive/hive.dart';

part 'time_block.g.dart';

@HiveType(typeId: 42)
class TimeBlock extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  DateTime startTime;

  @HiveField(2)
  DateTime endTime;

  @HiveField(3)
  String? taskId;

  @HiveField(4)
  String title;

  @HiveField(5)
  String? description;

  TimeBlock({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.taskId,
    required this.title,
    this.description,
  });

  bool overlaps(TimeBlock other) {
    return startTime.isBefore(other.endTime) && endTime.isAfter(other.startTime);
  }

  int get durationMinutes => endTime.difference(startTime).inMinutes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'taskId': taskId,
      'title': title,
      'description': description,
    };
  }

  factory TimeBlock.fromJson(Map<String, dynamic> json) {
    return TimeBlock(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      taskId: json['taskId'],
      title: json['title'],
      description: json['description'],
    );
  }
}

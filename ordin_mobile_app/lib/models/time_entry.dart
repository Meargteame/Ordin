import 'package:hive/hive.dart';

part 'time_entry.g.dart';

@HiveType(typeId: 30)
class TimeEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String? taskId;

  @HiveField(2)
  DateTime startTime;

  @HiveField(3)
  DateTime? endTime;

  @HiveField(4)
  int durationMinutes;

  @HiveField(5)
  String category;

  @HiveField(6)
  String notes;

  TimeEntry({
    required this.id,
    this.taskId,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.category,
    required this.notes,
  });

  bool get isRunning => endTime == null;

  int calculateDuration() {
    if (endTime == null) {
      return DateTime.now().difference(startTime).inMinutes;
    }
    return endTime!.difference(startTime).inMinutes;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'category': category,
      'notes': notes,
    };
  }

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'],
      taskId: json['taskId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      durationMinutes: json['durationMinutes'],
      category: json['category'],
      notes: json['notes'],
    );
  }
}

import 'package:hive/hive.dart';

part 'recurring_task.g.dart';

@HiveType(typeId: 40)
class RecurringTask extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  RecurrencePattern pattern;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime? endDate;

  @HiveField(5)
  DateTime nextOccurrence;

  RecurringTask({
    required this.id,
    required this.title,
    required this.pattern,
    required this.startDate,
    this.endDate,
    required this.nextOccurrence,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'pattern': pattern.index,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextOccurrence': nextOccurrence.toIso8601String(),
    };
  }

  factory RecurringTask.fromJson(Map<String, dynamic> json) {
    return RecurringTask(
      id: json['id'],
      title: json['title'],
      pattern: RecurrencePattern.values[json['pattern']],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      nextOccurrence: DateTime.parse(json['nextOccurrence']),
    );
  }
}

@HiveType(typeId: 41)
enum RecurrencePattern {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  custom,
}

import 'package:hive/hive.dart';

part 'health_metric.g.dart';

@HiveType(typeId: 62)
class HealthMetric extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  HealthMetricType type;

  @HiveField(3)
  double value;

  @HiveField(4)
  String? notes;

  HealthMetric({
    required this.id,
    required this.date,
    required this.type,
    required this.value,
    this.notes,
  });
}

@HiveType(typeId: 63)
enum HealthMetricType {
  @HiveField(0)
  workout,
  @HiveField(1)
  waterIntake,
  @HiveField(2)
  sleep,
  @HiveField(3)
  weight,
  @HiveField(4)
  meals,
}

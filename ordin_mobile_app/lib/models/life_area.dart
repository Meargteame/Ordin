import 'package:hive/hive.dart';

part 'life_area.g.dart';

@HiveType(typeId: 60)
class LifeArea extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  LifeAreaType type;

  @HiveField(3)
  double healthScore;

  @HiveField(4)
  DateTime lastUpdated;

  LifeArea({
    required this.id,
    required this.name,
    required this.type,
    required this.healthScore,
    required this.lastUpdated,
  });
}

@HiveType(typeId: 61)
enum LifeAreaType {
  @HiveField(0)
  health,
  @HiveField(1)
  finance,
  @HiveField(2)
  relationships,
  @HiveField(3)
  learning,
  @HiveField(4)
  custom,
}

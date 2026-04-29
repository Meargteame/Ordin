import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: 66)
class Contact extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<ImportantDate> importantDates;

  @HiveField(3)
  DateTime? lastInteraction;

  @HiveField(4)
  String notes;

  Contact({
    required this.id,
    required this.name,
    required this.importantDates,
    this.lastInteraction,
    required this.notes,
  });
}

@HiveType(typeId: 67)
class ImportantDate {
  @HiveField(0)
  String label;

  @HiveField(1)
  DateTime date;

  ImportantDate({
    required this.label,
    required this.date,
  });
}

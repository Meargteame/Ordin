import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 51)
class JournalEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  String content;

  @HiveField(3)
  Mood? mood;

  @HiveField(4)
  List<String> gratitudeItems;

  @HiveField(5)
  List<String> photoUrls;

  JournalEntry({
    required this.id,
    required this.date,
    required this.content,
    this.mood,
    required this.gratitudeItems,
    required this.photoUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'content': content,
      'mood': mood?.index,
      'gratitudeItems': gratitudeItems,
      'photoUrls': photoUrls,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      content: json['content'],
      mood: json['mood'] != null ? Mood.values[json['mood']] : null,
      gratitudeItems: List<String>.from(json['gratitudeItems'] ?? []),
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
    );
  }
}

@HiveType(typeId: 52)
enum Mood {
  @HiveField(0)
  great,
  @HiveField(1)
  good,
  @HiveField(2)
  neutral,
  @HiveField(3)
  bad,
  @HiveField(4)
  terrible,
}

import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 50)
class Note extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  List<String> tags;

  @HiveField(4)
  String? linkedEntityType;

  @HiveField(5)
  String? linkedEntityId;

  @HiveField(6)
  final DateTime createdDate;

  @HiveField(7)
  DateTime modifiedDate;

  @HiveField(8)
  List<String> photoUrls;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    this.linkedEntityType,
    this.linkedEntityId,
    required this.createdDate,
    required this.modifiedDate,
    required this.photoUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'linkedEntityType': linkedEntityType,
      'linkedEntityId': linkedEntityId,
      'createdDate': createdDate.toIso8601String(),
      'modifiedDate': modifiedDate.toIso8601String(),
      'photoUrls': photoUrls,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []),
      linkedEntityType: json['linkedEntityType'],
      linkedEntityId: json['linkedEntityId'],
      createdDate: DateTime.parse(json['createdDate']),
      modifiedDate: DateTime.parse(json['modifiedDate']),
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LearningItemAdapter extends TypeAdapter<LearningItem> {
  @override
  final int typeId = 68;

  @override
  LearningItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LearningItem(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as LearningType,
      status: fields[3] as LearningStatus,
      progress: fields[4] as double,
      completedDate: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LearningItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.progress)
      ..writeByte(5)
      ..write(obj.completedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LearningTypeAdapter extends TypeAdapter<LearningType> {
  @override
  final int typeId = 69;

  @override
  LearningType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LearningType.book;
      case 1:
        return LearningType.course;
      case 2:
        return LearningType.skill;
      case 3:
        return LearningType.certification;
      default:
        return LearningType.book;
    }
  }

  @override
  void write(BinaryWriter writer, LearningType obj) {
    switch (obj) {
      case LearningType.book:
        writer.writeByte(0);
        break;
      case LearningType.course:
        writer.writeByte(1);
        break;
      case LearningType.skill:
        writer.writeByte(2);
        break;
      case LearningType.certification:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LearningStatusAdapter extends TypeAdapter<LearningStatus> {
  @override
  final int typeId = 70;

  @override
  LearningStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LearningStatus.notStarted;
      case 1:
        return LearningStatus.inProgress;
      case 2:
        return LearningStatus.completed;
      case 3:
        return LearningStatus.paused;
      default:
        return LearningStatus.notStarted;
    }
  }

  @override
  void write(BinaryWriter writer, LearningStatus obj) {
    switch (obj) {
      case LearningStatus.notStarted:
        writer.writeByte(0);
        break;
      case LearningStatus.inProgress:
        writer.writeByte(1);
        break;
      case LearningStatus.completed:
        writer.writeByte(2);
        break;
      case LearningStatus.paused:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

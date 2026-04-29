// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringTaskAdapter extends TypeAdapter<RecurringTask> {
  @override
  final int typeId = 40;

  @override
  RecurringTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringTask(
      id: fields[0] as String,
      title: fields[1] as String,
      pattern: fields[2] as RecurrencePattern,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime?,
      nextOccurrence: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringTask obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.pattern)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.nextOccurrence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrencePatternAdapter extends TypeAdapter<RecurrencePattern> {
  @override
  final int typeId = 41;

  @override
  RecurrencePattern read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrencePattern.daily;
      case 1:
        return RecurrencePattern.weekly;
      case 2:
        return RecurrencePattern.monthly;
      case 3:
        return RecurrencePattern.custom;
      default:
        return RecurrencePattern.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrencePattern obj) {
    switch (obj) {
      case RecurrencePattern.daily:
        writer.writeByte(0);
        break;
      case RecurrencePattern.weekly:
        writer.writeByte(1);
        break;
      case RecurrencePattern.monthly:
        writer.writeByte(2);
        break;
      case RecurrencePattern.custom:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrencePatternAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

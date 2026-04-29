// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_metric.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthMetricAdapter extends TypeAdapter<HealthMetric> {
  @override
  final int typeId = 62;

  @override
  HealthMetric read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthMetric(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      type: fields[2] as HealthMetricType,
      value: fields[3] as double,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HealthMetric obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthMetricAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HealthMetricTypeAdapter extends TypeAdapter<HealthMetricType> {
  @override
  final int typeId = 63;

  @override
  HealthMetricType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HealthMetricType.workout;
      case 1:
        return HealthMetricType.waterIntake;
      case 2:
        return HealthMetricType.sleep;
      case 3:
        return HealthMetricType.weight;
      case 4:
        return HealthMetricType.meals;
      default:
        return HealthMetricType.workout;
    }
  }

  @override
  void write(BinaryWriter writer, HealthMetricType obj) {
    switch (obj) {
      case HealthMetricType.workout:
        writer.writeByte(0);
        break;
      case HealthMetricType.waterIntake:
        writer.writeByte(1);
        break;
      case HealthMetricType.sleep:
        writer.writeByte(2);
        break;
      case HealthMetricType.weight:
        writer.writeByte(3);
        break;
      case HealthMetricType.meals:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthMetricTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

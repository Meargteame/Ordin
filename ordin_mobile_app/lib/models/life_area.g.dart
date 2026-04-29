// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'life_area.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LifeAreaAdapter extends TypeAdapter<LifeArea> {
  @override
  final int typeId = 60;

  @override
  LifeArea read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LifeArea(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as LifeAreaType,
      healthScore: fields[3] as double,
      lastUpdated: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LifeArea obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.healthScore)
      ..writeByte(4)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LifeAreaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LifeAreaTypeAdapter extends TypeAdapter<LifeAreaType> {
  @override
  final int typeId = 61;

  @override
  LifeAreaType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LifeAreaType.health;
      case 1:
        return LifeAreaType.finance;
      case 2:
        return LifeAreaType.relationships;
      case 3:
        return LifeAreaType.learning;
      case 4:
        return LifeAreaType.custom;
      default:
        return LifeAreaType.health;
    }
  }

  @override
  void write(BinaryWriter writer, LifeAreaType obj) {
    switch (obj) {
      case LifeAreaType.health:
        writer.writeByte(0);
        break;
      case LifeAreaType.finance:
        writer.writeByte(1);
        break;
      case LifeAreaType.relationships:
        writer.writeByte(2);
        break;
      case LifeAreaType.learning:
        writer.writeByte(3);
        break;
      case LifeAreaType.custom:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LifeAreaTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

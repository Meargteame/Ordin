// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dependency.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskDependencyAdapter extends TypeAdapter<TaskDependency> {
  @override
  final int typeId = 24;

  @override
  TaskDependency read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskDependency(
      id: fields[0] as String,
      taskId: fields[1] as String,
      dependsOnTaskId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TaskDependency obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.dependsOnTaskId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskDependencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_template.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectTemplateAdapter extends TypeAdapter<ProjectTemplate> {
  @override
  final int typeId = 22;

  @override
  ProjectTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectTemplate(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      taskTemplates: (fields[3] as List).cast<TaskTemplate>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProjectTemplate obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.taskTemplates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskTemplateAdapter extends TypeAdapter<TaskTemplate> {
  @override
  final int typeId = 23;

  @override
  TaskTemplate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskTemplate(
      title: fields[0] as String,
      description: fields[1] as String?,
      estimatedMinutes: fields[2] as int?,
      dependsOnTitles: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TaskTemplate obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.estimatedMinutes)
      ..writeByte(3)
      ..write(obj.dependsOnTitles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTemplateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

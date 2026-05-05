// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 10;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as GoalCategory,
      status: fields[4] as GoalStatus,
      priority: fields[5] as Priority,
      deadline: fields[6] as DateTime?,
      successMetrics: fields[7] as String,
      progress: fields[8] as double,
      linkedTaskIds: (fields[9] as List).cast<String>(),
      linkedProjectIds: (fields[10] as List).cast<String>(),
      createdDate: fields[11] as DateTime,
      type: fields[12] as GoalType,
      parentGoalId: fields[13] as String?,
      childGoalIds: (fields[14] as List).cast<String>(),
      dependencyGoalIds: (fields[15] as List).cast<String>(),
      blockedGoalIds: (fields[16] as List).cast<String>(),
      metrics: (fields[17] as List).cast<GoalMetric>(),
      automationConfig: (fields[18] as Map).cast<String, dynamic>(),
      aiConfidenceScore: fields[19] as double,
      aiSuggestions: (fields[20] as List).cast<String>(),
      aiMetadata: (fields[21] as Map).cast<String, dynamic>(),
      accountabilityPartnerIds: (fields[22] as List).cast<String>(),
      visibility: fields[23] as GoalVisibility,
      sharedWithUserIds: (fields[24] as List).cast<String>(),
      checkIns: (fields[25] as List).cast<GoalCheckIn>(),
      contextData: (fields[26] as Map).cast<String, dynamic>(),
      resourceIds: (fields[27] as List).cast<String>(),
      difficulty: fields[28] as GoalDifficulty,
      tags: (fields[29] as List).cast<String>(),
      lastActivityDate: fields[30] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(31)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.deadline)
      ..writeByte(7)
      ..write(obj.successMetrics)
      ..writeByte(8)
      ..write(obj.progress)
      ..writeByte(9)
      ..write(obj.linkedTaskIds)
      ..writeByte(10)
      ..write(obj.linkedProjectIds)
      ..writeByte(11)
      ..write(obj.createdDate)
      ..writeByte(12)
      ..write(obj.type)
      ..writeByte(13)
      ..write(obj.parentGoalId)
      ..writeByte(14)
      ..write(obj.childGoalIds)
      ..writeByte(15)
      ..write(obj.dependencyGoalIds)
      ..writeByte(16)
      ..write(obj.blockedGoalIds)
      ..writeByte(17)
      ..write(obj.metrics)
      ..writeByte(18)
      ..write(obj.automationConfig)
      ..writeByte(19)
      ..write(obj.aiConfidenceScore)
      ..writeByte(20)
      ..write(obj.aiSuggestions)
      ..writeByte(21)
      ..write(obj.aiMetadata)
      ..writeByte(22)
      ..write(obj.accountabilityPartnerIds)
      ..writeByte(23)
      ..write(obj.visibility)
      ..writeByte(24)
      ..write(obj.sharedWithUserIds)
      ..writeByte(25)
      ..write(obj.checkIns)
      ..writeByte(26)
      ..write(obj.contextData)
      ..writeByte(27)
      ..write(obj.resourceIds)
      ..writeByte(28)
      ..write(obj.difficulty)
      ..writeByte(29)
      ..write(obj.tags)
      ..writeByte(30)
      ..write(obj.lastActivityDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalMetricAdapter extends TypeAdapter<GoalMetric> {
  @override
  final int typeId = 23;

  @override
  GoalMetric read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalMetric(
      id: fields[0] as String,
      name: fields[1] as String,
      unit: fields[2] as String,
      targetValue: fields[3] as double,
      currentValue: fields[4] as double,
      weight: fields[5] as double,
      type: fields[6] as MetricType,
      automationSource: fields[7] as String?,
      lastUpdated: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GoalMetric obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.targetValue)
      ..writeByte(4)
      ..write(obj.currentValue)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.automationSource)
      ..writeByte(8)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalMetricAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalCheckInAdapter extends TypeAdapter<GoalCheckIn> {
  @override
  final int typeId = 25;

  @override
  GoalCheckIn read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalCheckIn(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      progressUpdate: fields[2] as double,
      notes: fields[3] as String,
      moodRating: fields[4] as int,
      energyLevel: fields[5] as int,
      challenges: (fields[6] as List).cast<String>(),
      wins: (fields[7] as List).cast<String>(),
      metricUpdates: (fields[8] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, GoalCheckIn obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.progressUpdate)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.moodRating)
      ..writeByte(5)
      ..write(obj.energyLevel)
      ..writeByte(6)
      ..write(obj.challenges)
      ..writeByte(7)
      ..write(obj.wins)
      ..writeByte(8)
      ..write(obj.metricUpdates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalCheckInAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalCategoryAdapter extends TypeAdapter<GoalCategory> {
  @override
  final int typeId = 11;

  @override
  GoalCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalCategory.career;
      case 1:
        return GoalCategory.health;
      case 2:
        return GoalCategory.finance;
      case 3:
        return GoalCategory.relationships;
      case 4:
        return GoalCategory.personalGrowth;
      case 5:
        return GoalCategory.learning;
      default:
        return GoalCategory.career;
    }
  }

  @override
  void write(BinaryWriter writer, GoalCategory obj) {
    switch (obj) {
      case GoalCategory.career:
        writer.writeByte(0);
        break;
      case GoalCategory.health:
        writer.writeByte(1);
        break;
      case GoalCategory.finance:
        writer.writeByte(2);
        break;
      case GoalCategory.relationships:
        writer.writeByte(3);
        break;
      case GoalCategory.personalGrowth:
        writer.writeByte(4);
        break;
      case GoalCategory.learning:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalStatusAdapter extends TypeAdapter<GoalStatus> {
  @override
  final int typeId = 12;

  @override
  GoalStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalStatus.active;
      case 1:
        return GoalStatus.completed;
      case 2:
        return GoalStatus.archived;
      case 3:
        return GoalStatus.onHold;
      case 4:
        return GoalStatus.cancelled;
      default:
        return GoalStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, GoalStatus obj) {
    switch (obj) {
      case GoalStatus.active:
        writer.writeByte(0);
        break;
      case GoalStatus.completed:
        writer.writeByte(1);
        break;
      case GoalStatus.archived:
        writer.writeByte(2);
        break;
      case GoalStatus.onHold:
        writer.writeByte(3);
        break;
      case GoalStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PriorityAdapter extends TypeAdapter<Priority> {
  @override
  final int typeId = 13;

  @override
  Priority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Priority.high;
      case 1:
        return Priority.medium;
      case 2:
        return Priority.low;
      default:
        return Priority.high;
    }
  }

  @override
  void write(BinaryWriter writer, Priority obj) {
    switch (obj) {
      case Priority.high:
        writer.writeByte(0);
        break;
      case Priority.medium:
        writer.writeByte(1);
        break;
      case Priority.low:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final int typeId = 20;

  @override
  GoalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalType.objective;
      case 1:
        return GoalType.keyResult;
      case 2:
        return GoalType.initiative;
      case 3:
        return GoalType.milestone;
      default:
        return GoalType.objective;
    }
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    switch (obj) {
      case GoalType.objective:
        writer.writeByte(0);
        break;
      case GoalType.keyResult:
        writer.writeByte(1);
        break;
      case GoalType.initiative:
        writer.writeByte(2);
        break;
      case GoalType.milestone:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalVisibilityAdapter extends TypeAdapter<GoalVisibility> {
  @override
  final int typeId = 21;

  @override
  GoalVisibility read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalVisibility.private;
      case 1:
        return GoalVisibility.shared;
      case 2:
        return GoalVisibility.team;
      case 3:
        return GoalVisibility.public;
      default:
        return GoalVisibility.private;
    }
  }

  @override
  void write(BinaryWriter writer, GoalVisibility obj) {
    switch (obj) {
      case GoalVisibility.private:
        writer.writeByte(0);
        break;
      case GoalVisibility.shared:
        writer.writeByte(1);
        break;
      case GoalVisibility.team:
        writer.writeByte(2);
        break;
      case GoalVisibility.public:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalVisibilityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalDifficultyAdapter extends TypeAdapter<GoalDifficulty> {
  @override
  final int typeId = 22;

  @override
  GoalDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalDifficulty.easy;
      case 1:
        return GoalDifficulty.medium;
      case 2:
        return GoalDifficulty.hard;
      case 3:
        return GoalDifficulty.stretch;
      default:
        return GoalDifficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, GoalDifficulty obj) {
    switch (obj) {
      case GoalDifficulty.easy:
        writer.writeByte(0);
        break;
      case GoalDifficulty.medium:
        writer.writeByte(1);
        break;
      case GoalDifficulty.hard:
        writer.writeByte(2);
        break;
      case GoalDifficulty.stretch:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MetricTypeAdapter extends TypeAdapter<MetricType> {
  @override
  final int typeId = 24;

  @override
  MetricType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MetricType.number;
      case 1:
        return MetricType.percentage;
      case 2:
        return MetricType.currency;
      case 3:
        return MetricType.time;
      case 4:
        return MetricType.count;
      case 5:
        return MetricType.boolean;
      default:
        return MetricType.number;
    }
  }

  @override
  void write(BinaryWriter writer, MetricType obj) {
    switch (obj) {
      case MetricType.number:
        writer.writeByte(0);
        break;
      case MetricType.percentage:
        writer.writeByte(1);
        break;
      case MetricType.currency:
        writer.writeByte(2);
        break;
      case MetricType.time:
        writer.writeByte(3);
        break;
      case MetricType.count:
        writer.writeByte(4);
        break;
      case MetricType.boolean:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetricTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

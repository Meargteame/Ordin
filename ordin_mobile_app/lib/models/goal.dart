import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 10)
class Goal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  GoalCategory category;

  @HiveField(4)
  GoalStatus status;

  @HiveField(5)
  Priority priority;

  @HiveField(6)
  DateTime? deadline;

  @HiveField(7)
  String successMetrics;

  @HiveField(8)
  double progress;

  @HiveField(9)
  List<String> linkedTaskIds;

  @HiveField(10)
  List<String> linkedProjectIds;

  @HiveField(11)
  final DateTime createdDate;

  // Advanced OKR Fields
  @HiveField(12)
  GoalType type; // Objective, KeyResult, Initiative, Task

  @HiveField(13)
  String? parentGoalId; // For OKR hierarchy

  @HiveField(14)
  List<String> childGoalIds; // Sub-goals/Key Results

  @HiveField(15)
  List<String> dependencyGoalIds; // Goals this depends on

  @HiveField(16)
  List<String> blockedGoalIds; // Goals blocked by this one

  // Multi-Metric Tracking
  @HiveField(17)
  List<GoalMetric> metrics; // Multiple KPIs per goal

  @HiveField(18)
  Map<String, dynamic> automationConfig; // External data sources

  // AI & Intelligence
  @HiveField(19)
  double aiConfidenceScore; // AI prediction of success likelihood

  @HiveField(20)
  List<String> aiSuggestions; // AI-generated next actions

  @HiveField(21)
  Map<String, dynamic> aiMetadata; // ML model data

  // Social & Accountability
  @HiveField(22)
  List<String> accountabilityPartnerIds;

  @HiveField(23)
  GoalVisibility visibility;

  @HiveField(24)
  List<String> sharedWithUserIds;

  // Advanced Tracking
  @HiveField(25)
  List<GoalCheckIn> checkIns; // Progress check-ins with notes

  @HiveField(26)
  Map<String, dynamic> contextData; // Location, energy, mood when working on goal

  @HiveField(27)
  List<String> resourceIds; // Linked learning materials, articles, etc.

  @HiveField(28)
  GoalDifficulty difficulty;

  @HiveField(29)
  List<String> tags; // Flexible tagging system

  @HiveField(30)
  DateTime? lastActivityDate;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    this.deadline,
    required this.successMetrics,
    required this.progress,
    required this.linkedTaskIds,
    required this.linkedProjectIds,
    required this.createdDate,
    this.type = GoalType.objective,
    this.parentGoalId,
    this.childGoalIds = const [],
    this.dependencyGoalIds = const [],
    this.blockedGoalIds = const [],
    this.metrics = const [],
    this.automationConfig = const {},
    this.aiConfidenceScore = 0.5,
    this.aiSuggestions = const [],
    this.aiMetadata = const {},
    this.accountabilityPartnerIds = const [],
    this.visibility = GoalVisibility.private,
    this.sharedWithUserIds = const [],
    this.checkIns = const [],
    this.contextData = const {},
    this.resourceIds = const [],
    this.difficulty = GoalDifficulty.medium,
    this.tags = const [],
    this.lastActivityDate,
  });

  // Calculate overall progress from multiple metrics
  double get calculatedProgress {
    if (metrics.isEmpty) return progress;
    
    double totalWeight = metrics.fold(0.0, (sum, metric) => sum + metric.weight);
    if (totalWeight == 0) return progress;
    
    double weightedProgress = metrics.fold(0.0, (sum, metric) => 
      sum + (metric.currentValue / metric.targetValue * metric.weight));
    
    return (weightedProgress / totalWeight).clamp(0.0, 1.0);
  }

  // Check if goal is at risk based on deadline and progress
  bool get isAtRisk {
    if (deadline == null) return false;
    
    final now = DateTime.now();
    final totalDuration = deadline!.difference(createdDate).inDays;
    final elapsedDuration = now.difference(createdDate).inDays;
    
    if (totalDuration <= 0) return false;
    
    final expectedProgress = elapsedDuration / totalDuration;
    final actualProgress = calculatedProgress;
    
    return actualProgress < (expectedProgress * 0.8); // 20% behind expected
  }

  // Get next suggested actions based on goal type and progress
  List<String> get suggestedActions {
    List<String> actions = List.from(aiSuggestions);
    
    // Add default suggestions based on progress
    if (calculatedProgress < 0.1) {
      actions.add('Break this goal into smaller milestones');
      actions.add('Schedule dedicated time blocks for this goal');
    } else if (calculatedProgress < 0.5) {
      actions.add('Review and adjust your approach');
      actions.add('Celebrate small wins to maintain momentum');
    } else if (calculatedProgress < 0.9) {
      actions.add('Push through the final stretch');
      actions.add('Prepare for goal completion celebration');
    }
    
    return actions;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'status': status.index,
      'priority': priority.index,
      'deadline': deadline?.toIso8601String(),
      'successMetrics': successMetrics,
      'progress': progress,
      'linkedTaskIds': linkedTaskIds,
      'linkedProjectIds': linkedProjectIds,
      'createdDate': createdDate.toIso8601String(),
      'type': type.index,
      'parentGoalId': parentGoalId,
      'childGoalIds': childGoalIds,
      'dependencyGoalIds': dependencyGoalIds,
      'blockedGoalIds': blockedGoalIds,
      'metrics': metrics.map((m) => m.toJson()).toList(),
      'automationConfig': automationConfig,
      'aiConfidenceScore': aiConfidenceScore,
      'aiSuggestions': aiSuggestions,
      'aiMetadata': aiMetadata,
      'accountabilityPartnerIds': accountabilityPartnerIds,
      'visibility': visibility.index,
      'sharedWithUserIds': sharedWithUserIds,
      'checkIns': checkIns.map((c) => c.toJson()).toList(),
      'contextData': contextData,
      'resourceIds': resourceIds,
      'difficulty': difficulty.index,
      'tags': tags,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: GoalCategory.values[json['category']],
      status: GoalStatus.values[json['status']],
      priority: Priority.values[json['priority']],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      successMetrics: json['successMetrics'],
      progress: json['progress'],
      linkedTaskIds: List<String>.from(json['linkedTaskIds']),
      linkedProjectIds: List<String>.from(json['linkedProjectIds']),
      createdDate: DateTime.parse(json['createdDate']),
      type: json['type'] != null ? GoalType.values[json['type']] : GoalType.objective,
      parentGoalId: json['parentGoalId'],
      childGoalIds: json['childGoalIds'] != null ? List<String>.from(json['childGoalIds']) : [],
      dependencyGoalIds: json['dependencyGoalIds'] != null ? List<String>.from(json['dependencyGoalIds']) : [],
      blockedGoalIds: json['blockedGoalIds'] != null ? List<String>.from(json['blockedGoalIds']) : [],
      metrics: json['metrics'] != null ? (json['metrics'] as List).map((m) => GoalMetric.fromJson(m)).toList() : [],
      automationConfig: json['automationConfig'] ?? {},
      aiConfidenceScore: json['aiConfidenceScore'] ?? 0.5,
      aiSuggestions: json['aiSuggestions'] != null ? List<String>.from(json['aiSuggestions']) : [],
      aiMetadata: json['aiMetadata'] ?? {},
      accountabilityPartnerIds: json['accountabilityPartnerIds'] != null ? List<String>.from(json['accountabilityPartnerIds']) : [],
      visibility: json['visibility'] != null ? GoalVisibility.values[json['visibility']] : GoalVisibility.private,
      sharedWithUserIds: json['sharedWithUserIds'] != null ? List<String>.from(json['sharedWithUserIds']) : [],
      checkIns: json['checkIns'] != null ? (json['checkIns'] as List).map((c) => GoalCheckIn.fromJson(c)).toList() : [],
      contextData: json['contextData'] ?? {},
      resourceIds: json['resourceIds'] != null ? List<String>.from(json['resourceIds']) : [],
      difficulty: json['difficulty'] != null ? GoalDifficulty.values[json['difficulty']] : GoalDifficulty.medium,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      lastActivityDate: json['lastActivityDate'] != null ? DateTime.parse(json['lastActivityDate']) : null,
    );
  }
}

@HiveType(typeId: 11)
enum GoalCategory {
  @HiveField(0)
  career,
  @HiveField(1)
  health,
  @HiveField(2)
  finance,
  @HiveField(3)
  relationships,
  @HiveField(4)
  personalGrowth,
  @HiveField(5)
  learning,
}

@HiveType(typeId: 12)
enum GoalStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  completed,
  @HiveField(2)
  archived,
  @HiveField(3)
  onHold,
  @HiveField(4)
  cancelled,
}

@HiveType(typeId: 13)
enum Priority {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low,
}

@HiveType(typeId: 20)
enum GoalType {
  @HiveField(0)
  objective,     // High-level outcome (OKR Objective)
  @HiveField(1)
  keyResult,     // Measurable result (OKR Key Result)
  @HiveField(2)
  initiative,    // Project/effort to achieve key result
  @HiveField(3)
  milestone,     // Checkpoint within initiative
}

@HiveType(typeId: 21)
enum GoalVisibility {
  @HiveField(0)
  private,       // Only visible to owner
  @HiveField(1)
  shared,        // Visible to selected people
  @HiveField(2)
  team,          // Visible to team members
  @HiveField(3)
  public,        // Publicly visible
}

@HiveType(typeId: 22)
enum GoalDifficulty {
  @HiveField(0)
  easy,          // Low effort, high confidence
  @HiveField(1)
  medium,        // Moderate effort and confidence
  @HiveField(2)
  hard,          // High effort, moderate confidence
  @HiveField(3)
  stretch,       // Very high effort, low confidence
}

@HiveType(typeId: 23)
class GoalMetric extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String unit;

  @HiveField(3)
  double targetValue;

  @HiveField(4)
  double currentValue;

  @HiveField(5)
  double weight; // Importance weight (0.0 to 1.0)

  @HiveField(6)
  MetricType type;

  @HiveField(7)
  String? automationSource; // External API/app source

  @HiveField(8)
  DateTime lastUpdated;

  GoalMetric({
    required this.id,
    required this.name,
    required this.unit,
    required this.targetValue,
    required this.currentValue,
    required this.weight,
    required this.type,
    this.automationSource,
    required this.lastUpdated,
  });

  double get progressPercentage => (currentValue / targetValue).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'weight': weight,
      'type': type.index,
      'automationSource': automationSource,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory GoalMetric.fromJson(Map<String, dynamic> json) {
    return GoalMetric(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      targetValue: json['targetValue'],
      currentValue: json['currentValue'],
      weight: json['weight'],
      type: MetricType.values[json['type']],
      automationSource: json['automationSource'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

@HiveType(typeId: 24)
enum MetricType {
  @HiveField(0)
  number,        // Simple numeric value
  @HiveField(1)
  percentage,    // 0-100 percentage
  @HiveField(2)
  currency,      // Money amount
  @HiveField(3)
  time,          // Duration in minutes
  @HiveField(4)
  count,         // Integer count
  @HiveField(5)
  boolean,       // Yes/No completion
}

@HiveType(typeId: 25)
class GoalCheckIn extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  double progressUpdate;

  @HiveField(3)
  String notes;

  @HiveField(4)
  int moodRating; // 1-5 scale

  @HiveField(5)
  int energyLevel; // 1-5 scale

  @HiveField(6)
  List<String> challenges;

  @HiveField(7)
  List<String> wins;

  @HiveField(8)
  Map<String, double> metricUpdates; // Metric ID -> new value

  GoalCheckIn({
    required this.id,
    required this.date,
    required this.progressUpdate,
    required this.notes,
    required this.moodRating,
    required this.energyLevel,
    required this.challenges,
    required this.wins,
    required this.metricUpdates,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'progressUpdate': progressUpdate,
      'notes': notes,
      'moodRating': moodRating,
      'energyLevel': energyLevel,
      'challenges': challenges,
      'wins': wins,
      'metricUpdates': metricUpdates,
    };
  }

  factory GoalCheckIn.fromJson(Map<String, dynamic> json) {
    return GoalCheckIn(
      id: json['id'],
      date: DateTime.parse(json['date']),
      progressUpdate: json['progressUpdate'],
      notes: json['notes'],
      moodRating: json['moodRating'],
      energyLevel: json['energyLevel'],
      challenges: List<String>.from(json['challenges']),
      wins: List<String>.from(json['wins']),
      metricUpdates: Map<String, double>.from(json['metricUpdates']),
    );
  }
}

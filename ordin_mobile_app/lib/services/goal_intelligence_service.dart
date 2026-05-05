import 'dart:math';
import '../models/goal.dart';

class GoalIntelligenceService {
  static const List<String> _motivationalPhrases = [
    "You're making great progress!",
    "Keep up the momentum!",
    "Small steps lead to big achievements",
    "Consistency is key to success",
    "You're closer than you think",
  ];

  static const Map<GoalCategory, List<String>> _categoryInsights = {
    GoalCategory.health: [
      "Track your workouts and nutrition daily",
      "Set realistic weekly targets",
      "Find an accountability partner",
      "Celebrate small fitness wins",
      "Focus on consistency over perfection",
    ],
    GoalCategory.career: [
      "Network with industry professionals",
      "Update your skills regularly",
      "Set measurable career milestones",
      "Seek feedback from mentors",
      "Document your achievements",
    ],
    GoalCategory.finance: [
      "Automate your savings",
      "Track expenses weekly",
      "Set up emergency fund first",
      "Invest in your financial education",
      "Review and adjust budget monthly",
    ],
    GoalCategory.learning: [
      "Practice daily, even if just 15 minutes",
      "Apply what you learn immediately",
      "Join study groups or communities",
      "Set specific skill milestones",
      "Teach others to reinforce learning",
    ],
    GoalCategory.relationships: [
      "Schedule regular quality time",
      "Practice active listening",
      "Express gratitude frequently",
      "Address conflicts promptly",
      "Create shared experiences",
    ],
    GoalCategory.personalGrowth: [
      "Reflect on your progress weekly",
      "Step outside your comfort zone",
      "Practice mindfulness daily",
      "Set boundaries and stick to them",
      "Celebrate personal victories",
    ],
  };

  /// Analyzes a goal and provides AI-powered insights
  static GoalAnalysis analyzeGoal(Goal goal, List<Goal> allGoals) {
    final analysis = GoalAnalysis(
      goalId: goal.id,
      confidenceScore: _calculateConfidenceScore(goal),
      riskFactors: _identifyRiskFactors(goal),
      suggestions: _generateSuggestions(goal, allGoals),
      predictedCompletionDate: _predictCompletionDate(goal),
      motivationalMessage: _getMotivationalMessage(goal),
      nextActions: _generateNextActions(goal),
      similarGoalsInsights: _analyzeSimilarGoals(goal, allGoals),
    );

    return analysis;
  }

  /// Calculates AI confidence score for goal completion
  static double _calculateConfidenceScore(Goal goal) {
    double score = 0.5; // Base score

    // Progress factor (40% weight)
    final progressFactor = goal.calculatedProgress * 0.4;
    score += progressFactor;

    // Time factor (20% weight)
    if (goal.deadline != null) {
      final now = DateTime.now();
      final totalDays = goal.deadline!.difference(goal.createdDate).inDays;
      final remainingDays = goal.deadline!.difference(now).inDays;
      
      if (totalDays > 0) {
        final timeProgress = (totalDays - remainingDays) / totalDays;
        final timeVsProgress = goal.calculatedProgress / timeProgress.clamp(0.1, 1.0);
        score += (timeVsProgress.clamp(0.0, 2.0) - 1.0) * 0.2;
      }
    }

    // Activity factor (20% weight)
    if (goal.lastActivityDate != null) {
      final daysSinceActivity = DateTime.now().difference(goal.lastActivityDate!).inDays;
      final activityScore = (7 - daysSinceActivity.clamp(0, 14)) / 7;
      score += activityScore * 0.2;
    }

    // Difficulty factor (10% weight)
    final difficultyMultiplier = {
      GoalDifficulty.easy: 1.2,
      GoalDifficulty.medium: 1.0,
      GoalDifficulty.hard: 0.8,
      GoalDifficulty.stretch: 0.6,
    }[goal.difficulty] ?? 1.0;
    score *= difficultyMultiplier;

    // Check-in frequency factor (10% weight)
    final recentCheckIns = goal.checkIns.where((checkIn) => 
      DateTime.now().difference(checkIn.date).inDays <= 30).length;
    final checkInScore = (recentCheckIns / 4).clamp(0.0, 1.0) * 0.1;
    score += checkInScore;

    return score.clamp(0.0, 1.0);
  }

  /// Identifies potential risk factors for goal failure
  static List<RiskFactor> _identifyRiskFactors(Goal goal) {
    final risks = <RiskFactor>[];

    // Deadline risk
    if (goal.deadline != null && goal.isAtRisk) {
      risks.add(RiskFactor(
        type: RiskType.timeline,
        severity: RiskSeverity.high,
        description: "Goal is behind schedule based on current progress",
        suggestion: "Consider breaking down remaining work into smaller daily tasks",
      ));
    }

    // Inactivity risk
    if (goal.lastActivityDate != null) {
      final daysSinceActivity = DateTime.now().difference(goal.lastActivityDate!).inDays;
      if (daysSinceActivity > 7) {
        risks.add(RiskFactor(
          type: RiskType.inactivity,
          severity: daysSinceActivity > 14 ? RiskSeverity.high : RiskSeverity.medium,
          description: "No recent activity on this goal ($daysSinceActivity days)",
          suggestion: "Schedule specific time blocks for this goal this week",
        ));
      }
    }

    // Complexity risk
    if (goal.childGoalIds.length > 5) {
      risks.add(RiskFactor(
        type: RiskType.complexity,
        severity: RiskSeverity.medium,
        description: "Goal has many sub-goals which may cause overwhelm",
        suggestion: "Focus on 2-3 key sub-goals at a time",
      ));
    }

    // Dependency risk
    if (goal.dependencyGoalIds.isNotEmpty) {
      risks.add(RiskFactor(
        type: RiskType.dependency,
        severity: RiskSeverity.low,
        description: "Goal depends on other goals completion",
        suggestion: "Ensure dependency goals are on track",
      ));
    }

    return risks;
  }

  /// Generates personalized suggestions based on goal analysis
  static List<String> _generateSuggestions(Goal goal, List<Goal> allGoals) {
    final suggestions = <String>[];

    // Category-specific suggestions
    final categoryInsights = _categoryInsights[goal.category] ?? [];
    if (categoryInsights.isNotEmpty) {
      suggestions.add(categoryInsights[Random().nextInt(categoryInsights.length)]);
    }

    // Progress-based suggestions
    if (goal.calculatedProgress < 0.1) {
      suggestions.addAll([
        "Start with the smallest possible action today",
        "Set up your environment for success",
        "Create a detailed action plan",
      ]);
    } else if (goal.calculatedProgress < 0.5) {
      suggestions.addAll([
        "Review what's working and double down on it",
        "Identify and remove obstacles",
        "Find ways to make the process more enjoyable",
      ]);
    } else if (goal.calculatedProgress < 0.9) {
      suggestions.addAll([
        "Maintain momentum with consistent daily actions",
        "Prepare for the final push",
        "Visualize your success to stay motivated",
      ]);
    }

    // Metric-based suggestions
    if (goal.metrics.isNotEmpty) {
      final laggingMetrics = goal.metrics.where((m) => m.progressPercentage < 0.5).toList();
      if (laggingMetrics.isNotEmpty) {
        suggestions.add("Focus on improving: ${laggingMetrics.map((m) => m.name).join(', ')}");
      }
    }

    return suggestions.take(3).toList();
  }

  /// Predicts completion date based on current progress velocity
  static DateTime? _predictCompletionDate(Goal goal) {
    if (goal.calculatedProgress <= 0 || goal.checkIns.length < 2) {
      return goal.deadline;
    }

    // Calculate velocity from recent check-ins
    final recentCheckIns = goal.checkIns
        .where((c) => DateTime.now().difference(c.date).inDays <= 30)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (recentCheckIns.length < 2) return goal.deadline;

    final firstCheckIn = recentCheckIns.first;
    final lastCheckIn = recentCheckIns.last;
    
    final progressDelta = lastCheckIn.progressUpdate - firstCheckIn.progressUpdate;
    final daysDelta = lastCheckIn.date.difference(firstCheckIn.date).inDays;

    if (daysDelta <= 0 || progressDelta <= 0) return goal.deadline;

    final dailyVelocity = progressDelta / daysDelta;
    final remainingProgress = 1.0 - goal.calculatedProgress;
    final daysToCompletion = (remainingProgress / dailyVelocity).ceil();

    return DateTime.now().add(Duration(days: daysToCompletion));
  }

  /// Gets motivational message based on goal state
  static String _getMotivationalMessage(Goal goal) {
    if (goal.calculatedProgress >= 0.9) {
      return "You're almost there! The finish line is in sight! 🎉";
    } else if (goal.calculatedProgress >= 0.5) {
      return "Great progress! You're over halfway to your goal! 💪";
    } else if (goal.calculatedProgress >= 0.25) {
      return "You're building momentum! Keep up the great work! 🚀";
    } else if (goal.calculatedProgress > 0) {
      return "Every journey begins with a single step. You've started! 🌟";
    } else {
      return "The best time to start was yesterday. The second best time is now! ⭐";
    }
  }

  /// Generates specific next actions based on goal state
  static List<String> _generateNextActions(Goal goal) {
    final actions = <String>[];

    if (goal.calculatedProgress == 0) {
      actions.addAll([
        "Define your first milestone",
        "Schedule 30 minutes to work on this goal",
        "Identify the smallest possible first step",
      ]);
    } else {
      actions.addAll([
        "Log your progress from this week",
        "Identify what's working well",
        "Plan your next milestone",
      ]);
    }

    // Add metric-specific actions
    for (final metric in goal.metrics) {
      if (metric.progressPercentage < 0.5) {
        actions.add("Update ${metric.name} (currently ${metric.currentValue}${metric.unit})");
      }
    }

    return actions.take(3).toList();
  }

  /// Analyzes similar goals for insights
  static Map<String, dynamic> _analyzeSimilarGoals(Goal goal, List<Goal> allGoals) {
    final similarGoals = allGoals.where((g) => 
      g.id != goal.id && 
      g.category == goal.category &&
      g.status == GoalStatus.completed
    ).toList();

    if (similarGoals.isEmpty) {
      return {'count': 0, 'insights': []};
    }

    final avgCompletionTime = similarGoals
        .map((g) => g.deadline?.difference(g.createdDate).inDays ?? 0)
        .where((days) => days > 0)
        .fold(0, (sum, days) => sum + days) / similarGoals.length;

    final commonTags = <String, int>{};
    for (final g in similarGoals) {
      for (final tag in g.tags) {
        commonTags[tag] = (commonTags[tag] ?? 0) + 1;
      }
    }

    final topTags = commonTags.entries
        .where((e) => e.value > 1)
        .map((e) => e.key)
        .take(3)
        .toList();

    return {
      'count': similarGoals.length,
      'avgCompletionDays': avgCompletionTime.round(),
      'commonTags': topTags,
      'insights': [
        "Similar goals typically take ${avgCompletionTime.round()} days to complete",
        if (topTags.isNotEmpty) "Successful goals often include: ${topTags.join(', ')}",
      ],
    };
  }

  /// Generates smart goal breakdown using AI principles
  static List<Goal> generateSmartBreakdown(Goal parentGoal) {
    final subGoals = <Goal>[];
    
    // Generate key results for objectives
    if (parentGoal.type == GoalType.objective) {
      final keyResultTemplates = _getKeyResultTemplates(parentGoal.category);
      
      for (int i = 0; i < keyResultTemplates.length && i < 3; i++) {
        final template = keyResultTemplates[i];
        subGoals.add(Goal(
          id: 'kr_${parentGoal.id}_$i',
          title: template['title'] as String? ?? 'Key Result ${i + 1}',
          description: template['description'] as String? ?? '',
          category: parentGoal.category,
          status: GoalStatus.active,
          priority: parentGoal.priority,
          deadline: parentGoal.deadline,
          successMetrics: template['metrics'] as String? ?? '',
          progress: 0.0,
          linkedTaskIds: [],
          linkedProjectIds: [],
          createdDate: DateTime.now(),
          type: GoalType.keyResult,
          parentGoalId: parentGoal.id,
          difficulty: GoalDifficulty.medium,
        ));
      }
    }

    return subGoals;
  }

  static List<Map<String, String>> _getKeyResultTemplates(GoalCategory category) {
    switch (category) {
      case GoalCategory.health:
        return [
          {
            'title': 'Achieve target weight/fitness level',
            'description': 'Measurable physical improvement',
            'metrics': 'Weight, body fat %, or fitness benchmark',
          },
          {
            'title': 'Establish consistent routine',
            'description': 'Build sustainable habits',
            'metrics': 'Days per week of activity',
          },
          {
            'title': 'Improve key health markers',
            'description': 'Optimize health indicators',
            'metrics': 'Blood pressure, cholesterol, etc.',
          },
        ];
      case GoalCategory.career:
        return [
          {
            'title': 'Develop key skills',
            'description': 'Acquire specific competencies',
            'metrics': 'Certifications, courses completed',
          },
          {
            'title': 'Expand professional network',
            'description': 'Build industry connections',
            'metrics': 'New contacts, events attended',
          },
          {
            'title': 'Achieve performance targets',
            'description': 'Meet measurable work goals',
            'metrics': 'KPIs, revenue, projects completed',
          },
        ];
      case GoalCategory.finance:
        return [
          {
            'title': 'Increase savings rate',
            'description': 'Save specific amount monthly',
            'metrics': 'Dollar amount or percentage of income',
          },
          {
            'title': 'Reduce expenses',
            'description': 'Cut unnecessary spending',
            'metrics': 'Monthly expense reduction',
          },
          {
            'title': 'Grow investment portfolio',
            'description': 'Increase investment value',
            'metrics': 'Portfolio value or return percentage',
          },
        ];
      default:
        return [
          {
            'title': 'Complete key milestone 1',
            'description': 'First major checkpoint',
            'metrics': 'Specific deliverable or outcome',
          },
          {
            'title': 'Complete key milestone 2',
            'description': 'Second major checkpoint',
            'metrics': 'Specific deliverable or outcome',
          },
        ];
    }
  }
}

class GoalAnalysis {
  final String goalId;
  final double confidenceScore;
  final List<RiskFactor> riskFactors;
  final List<String> suggestions;
  final DateTime? predictedCompletionDate;
  final String motivationalMessage;
  final List<String> nextActions;
  final Map<String, dynamic> similarGoalsInsights;

  GoalAnalysis({
    required this.goalId,
    required this.confidenceScore,
    required this.riskFactors,
    required this.suggestions,
    this.predictedCompletionDate,
    required this.motivationalMessage,
    required this.nextActions,
    required this.similarGoalsInsights,
  });
}

class RiskFactor {
  final RiskType type;
  final RiskSeverity severity;
  final String description;
  final String suggestion;

  RiskFactor({
    required this.type,
    required this.severity,
    required this.description,
    required this.suggestion,
  });
}

enum RiskType {
  timeline,
  inactivity,
  complexity,
  dependency,
  resource,
}

enum RiskSeverity {
  low,
  medium,
  high,
}
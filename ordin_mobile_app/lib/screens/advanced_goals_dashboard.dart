import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/goal.dart';
import '../services/goal_intelligence_service.dart';
import '../data/goal_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/theme_helper.dart';
import '../theme/ordin_theme.dart';

class AdvancedGoalsDashboard extends StatefulWidget {
  const AdvancedGoalsDashboard({super.key});

  @override
  State<AdvancedGoalsDashboard> createState() => _AdvancedGoalsDashboardState();
}

class _AdvancedGoalsDashboardState extends State<AdvancedGoalsDashboard> with TickerProviderStateMixin {
  late GoalRepository _goalRepo;
  List<Goal> _goals = [];
  Map<String, GoalAnalysis> _analyses = {};
  bool _isLoading = true;
  String _selectedView = 'Overview';
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeOut),
    );
    _initRepo();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _initRepo() async {
    final storage = HiveStorageService();
    await storage.init();
    _goalRepo = GoalRepository();
    await _goalRepo.init(storage);
    await _loadGoalsAndAnalyze();
    _animationController?.forward();
  }

  Future<void> _loadGoalsAndAnalyze() async {
    final goals = await _goalRepo.loadGoals();
    final analyses = <String, GoalAnalysis>{};
    
    for (final goal in goals) {
      analyses[goal.id] = GoalIntelligenceService.analyzeGoal(goal, goals);
    }
    
    setState(() {
      _goals = goals;
      _analyses = analyses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.backgroundColor(context),
        elevation: 0,
        title: Text(
          'Goals Intelligence',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: ThemeHelper.textPrimary(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeHelper.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: ThemeHelper.textSecondary(context)),
            onPressed: () => _loadGoalsAndAnalyze(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: OrdinTheme.primary))
          : _fadeAnimation != null
              ? AnimatedBuilder(
                  animation: _fadeAnimation!,
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnimation!.value,
                    child: Column(
                      children: [
                        _buildViewSelector(),
                        Expanded(child: _buildSelectedView()),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    _buildViewSelector(),
                    Expanded(child: _buildSelectedView()),
                  ],
                ),
    );
  }

  Widget _buildViewSelector() {
    final views = ['Overview', 'AI Insights', 'Risk Analysis', 'Progress Trends'];
    
    return Container(
      height: 60,
      margin: const EdgeInsets.all(20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: views.length,
        itemBuilder: (context, index) {
          final view = views[index];
          final isSelected = _selectedView == view;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(view),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedView = view);
              },
              backgroundColor: ThemeHelper.cardColor(context),
              selectedColor: OrdinTheme.primary,
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : ThemeHelper.textSecondary(context),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? OrdinTheme.primary : ThemeHelper.borderColor(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedView) {
      case 'AI Insights':
        return _buildAIInsightsView();
      case 'Risk Analysis':
        return _buildRiskAnalysisView();
      case 'Progress Trends':
        return _buildProgressTrendsView();
      default:
        return _buildOverviewView();
    }
  }

  Widget _buildOverviewView() {
    final activeGoals = _goals.where((g) => g.status == GoalStatus.active).toList();
    final completedGoals = _goals.where((g) => g.status == GoalStatus.completed).length;
    final avgConfidence = _analyses.values.isEmpty ? 0.0 : 
        _analyses.values.map((a) => a.confidenceScore).reduce((a, b) => a + b) / _analyses.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIntelligenceOverview(activeGoals.length, completedGoals, avgConfidence),
          const SizedBox(height: 24),
          _buildGoalConfidenceChart(),
          const SizedBox(height: 24),
          _buildSmartGoalsList(),
        ],
      ),
    );
  }

  Widget _buildIntelligenceOverview(int activeGoals, int completedGoals, double avgConfidence) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [OrdinTheme.primary, OrdinTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: OrdinTheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'AI INTELLIGENCE OVERVIEW',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewStat('$activeGoals', 'Active Goals'),
                    const SizedBox(height: 16),
                    _buildOverviewStat('$completedGoals', 'Completed'),
                  ],
                ),
              ),
              CircularPercentIndicator(
                radius: 45,
                lineWidth: 8,
                percent: avgConfidence,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(avgConfidence * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Confidence',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                progressColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.3),
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalConfidenceChart() {
    if (_analyses.isEmpty) return const SizedBox.shrink();

    final confidenceData = _analyses.entries.map((entry) {
      final goal = _goals.firstWhere((g) => g.id == entry.key);
      return FlSpot(
        _goals.indexOf(goal).toDouble(),
        entry.value.confidenceScore,
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ThemeHelper.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Confidence Scores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ThemeHelper.textPrimary(context),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: confidenceData,
                    isCurved: true,
                    color: OrdinTheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: OrdinTheme.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: OrdinTheme.primary.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartGoalsList() {
    final activeGoals = _goals.where((g) => g.status == GoalStatus.active).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Goals Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeHelper.textPrimary(context),
          ),
        ),
        const SizedBox(height: 16),
        ...activeGoals.take(3).map((goal) => _buildSmartGoalCard(goal)),
      ],
    );
  }

  Widget _buildSmartGoalCard(Goal goal) {
    final analysis = _analyses[goal.id];
    if (analysis == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: ThemeHelper.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.textPrimary(context),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(analysis.confidenceScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(analysis.confidenceScore * 100).toInt()}% confidence',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getConfidenceColor(analysis.confidenceScore),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 6,
            percent: goal.calculatedProgress,
            backgroundColor: ThemeHelper.borderColor(context),
            progressColor: _getCategoryColor(goal.category),
            barRadius: const Radius.circular(3),
          ),
          const SizedBox(height: 12),
          Text(
            analysis.motivationalMessage,
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelper.textSecondary(context),
              fontStyle: FontStyle.italic,
            ),
          ),
          if (analysis.nextActions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Next Actions:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.textSecondary(context),
              ),
            ),
            const SizedBox(height: 4),
            ...analysis.nextActions.take(2).map((action) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Icon(Icons.arrow_right, size: 16, color: ThemeHelper.textTertiary(context)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      action,
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeHelper.textTertiary(context),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildAIInsightsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI-Powered Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ThemeHelper.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          ..._analyses.entries.map((entry) {
            final goal = _goals.firstWhere((g) => g.id == entry.key);
            return _buildAIInsightCard(goal, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildAIInsightCard(Goal goal, GoalAnalysis analysis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: ThemeHelper.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: OrdinTheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (analysis.suggestions.isNotEmpty) ...[
            Text(
              'AI Suggestions:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            ...analysis.suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: OrdinTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 13,
                        color: ThemeHelper.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
          if (analysis.predictedCompletionDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: OrdinTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: OrdinTheme.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Predicted completion: ${_formatDate(analysis.predictedCompletionDate!)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: OrdinTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskAnalysisView() {
    final riskyGoals = _analyses.entries
        .where((entry) => entry.value.riskFactors.isNotEmpty)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ThemeHelper.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          if (riskyGoals.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: ThemeHelper.cardDecoration(context),
              child: Column(
                children: [
                  Icon(Icons.check_circle, color: OrdinTheme.success, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'All Goals Looking Good!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No significant risks detected in your current goals.',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeHelper.textSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...riskyGoals.map((entry) {
              final goal = _goals.firstWhere((g) => g.id == entry.key);
              return _buildRiskCard(goal, entry.value);
            }),
        ],
      ),
    );
  }

  Widget _buildRiskCard(Goal goal, GoalAnalysis analysis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: ThemeHelper.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: OrdinTheme.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...analysis.riskFactors.map((risk) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getRiskColor(risk.severity).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getRiskColor(risk.severity).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getRiskIcon(risk.severity),
                      color: _getRiskColor(risk.severity),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      risk.description,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _getRiskColor(risk.severity),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  risk.suggestion,
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeHelper.textSecondary(context),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProgressTrendsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Trends',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ThemeHelper.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Coming Soon: Advanced progress analytics, velocity tracking, and predictive insights.',
            style: TextStyle(
              fontSize: 16,
              color: ThemeHelper.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return OrdinTheme.success;
    if (confidence >= 0.6) return OrdinTheme.primary;
    if (confidence >= 0.4) return OrdinTheme.warning;
    return OrdinTheme.error;
  }

  Color _getCategoryColor(GoalCategory category) {
    switch (category) {
      case GoalCategory.career:
        return const Color(0xFF3B82F6);
      case GoalCategory.health:
        return const Color(0xFFEF4444);
      case GoalCategory.finance:
        return const Color(0xFF10B981);
      case GoalCategory.relationships:
        return const Color(0xFFEC4899);
      case GoalCategory.personalGrowth:
        return const Color(0xFF8B5CF6);
      case GoalCategory.learning:
        return const Color(0xFFF59E0B);
    }
  }

  Color _getRiskColor(RiskSeverity severity) {
    switch (severity) {
      case RiskSeverity.low:
        return OrdinTheme.warning;
      case RiskSeverity.medium:
        return const Color(0xFFFF8C00);
      case RiskSeverity.high:
        return OrdinTheme.error;
    }
  }

  IconData _getRiskIcon(RiskSeverity severity) {
    switch (severity) {
      case RiskSeverity.low:
        return Icons.info_outline;
      case RiskSeverity.medium:
        return Icons.warning_amber_outlined;
      case RiskSeverity.high:
        return Icons.error_outline;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return 'in $difference days';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/goal.dart';
import '../data/goal_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/theme_helper.dart';
import '../theme/ordin_theme.dart';
import 'goal_form_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with TickerProviderStateMixin {
  late GoalRepository _goalRepo;
  List<Goal> _goals = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    await _loadGoals();
    _animationController?.forward();
  }

  Future<void> _loadGoals() async {
    final goals = await _goalRepo.loadGoals();
    setState(() {
      _goals = goals;
      _isLoading = false;
    });
  }

  List<Goal> get _filteredGoals {
    switch (_selectedFilter) {
      case 'Active':
        return _goals.where((g) => g.status == GoalStatus.active).toList();
      case 'Completed':
        return _goals.where((g) => g.status == GoalStatus.completed).toList();
      case 'On Hold':
        return _goals.where((g) => g.status == GoalStatus.onHold).toList();
      default:
        return _goals;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.backgroundColor(context),
        elevation: 0,
        title: Text(
          'Goals',
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
            icon: Icon(Icons.analytics_outlined, color: ThemeHelper.textSecondary(context)),
            onPressed: () => _showAnalytics(),
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
                        if (_goals.isNotEmpty) _buildOverviewSection(),
                        _buildFilterChips(),
                        Expanded(
                          child: _filteredGoals.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.all(20),
                                  itemCount: _filteredGoals.length,
                                  itemBuilder: (context, index) => _buildGoalCard(_filteredGoals[index], index),
                                ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    if (_goals.isNotEmpty) _buildOverviewSection(),
                    _buildFilterChips(),
                    Expanded(
                      child: _filteredGoals.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _filteredGoals.length,
                              itemBuilder: (context, index) => _buildGoalCard(_filteredGoals[index], index),
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openGoalForm(),
        backgroundColor: OrdinTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Goal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    final activeGoals = _goals.where((g) => g.status == GoalStatus.active).length;
    final completedGoals = _goals.where((g) => g.status == GoalStatus.completed).length;
    final avgProgress = _goals.isEmpty ? 0.0 : _goals.map((g) => g.progress).reduce((a, b) => a + b) / _goals.length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GOALS OVERVIEW',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildOverviewStat('$activeGoals', 'Active'),
                        const SizedBox(width: 24),
                        _buildOverviewStat('$completedGoals', 'Completed'),
                      ],
                    ),
                  ],
                ),
              ),
              CircularPercentIndicator(
                radius: 40,
                lineWidth: 8,
                percent: avgProgress,
                center: Text(
                  '${(avgProgress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                progressColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.3),
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCategoryChart(),
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
          style: const TextStyle(
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

  Widget _buildCategoryChart() {
    final categoryData = <GoalCategory, int>{};
    for (final goal in _goals) {
      categoryData[goal.category] = (categoryData[goal.category] ?? 0) + 1;
    }

    if (categoryData.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: categoryData.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final categories = categoryData.keys.toList();
                  if (value.toInt() >= categories.length) return const SizedBox.shrink();
                  
                  final category = categories[value.toInt()];
                  String label;
                  switch (category) {
                    case GoalCategory.career:
                      label = 'Career';
                      break;
                    case GoalCategory.health:
                      label = 'Health';
                      break;
                    case GoalCategory.finance:
                      label = 'Finance';
                      break;
                    case GoalCategory.relationships:
                      label = 'Social';
                      break;
                    case GoalCategory.personalGrowth:
                      label = 'Growth';
                      break;
                    case GoalCategory.learning:
                      label = 'Learn';
                      break;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: categoryData.entries.map((entry) {
            final index = categoryData.keys.toList().indexOf(entry.key);
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: Colors.white.withOpacity(0.8),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Active', 'Completed', 'On Hold'];
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
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

  Widget _buildGoalCard(Goal goal, int index) {
    final categoryColor = _getCategoryColor(goal.category);
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: ThemeHelper.cardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(goal.category),
                          color: categoryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: ThemeHelper.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getCategoryLabel(goal.category),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircularPercentIndicator(
                        radius: 30,
                        lineWidth: 6,
                        percent: goal.progress,
                        center: Text(
                          '${(goal.progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: categoryColor,
                          ),
                        ),
                        progressColor: categoryColor,
                        backgroundColor: ThemeHelper.borderColor(context),
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                    ],
                  ),
                  if (goal.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      goal.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.textSecondary(context),
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    lineHeight: 8,
                    percent: goal.progress,
                    backgroundColor: ThemeHelper.borderColor(context),
                    progressColor: categoryColor,
                    barRadius: const Radius.circular(4),
                  ),
                  if (goal.deadline != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: ThemeHelper.textTertiary(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Due ${_formatDate(goal.deadline!)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: ThemeHelper.textSecondary(context),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(goal.priority).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getPriorityLabel(goal.priority),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getPriorityColor(goal.priority),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.career:
        return Icons.work_outline;
      case GoalCategory.health:
        return Icons.favorite_outline;
      case GoalCategory.finance:
        return Icons.attach_money;
      case GoalCategory.relationships:
        return Icons.people_outline;
      case GoalCategory.personalGrowth:
        return Icons.psychology_outlined;
      case GoalCategory.learning:
        return Icons.school_outlined;
    }
  }

  String _getCategoryLabel(GoalCategory category) {
    switch (category) {
      case GoalCategory.career:
        return 'Career';
      case GoalCategory.health:
        return 'Health';
      case GoalCategory.finance:
        return 'Finance';
      case GoalCategory.relationships:
        return 'Relationships';
      case GoalCategory.personalGrowth:
        return 'Personal Growth';
      case GoalCategory.learning:
        return 'Learning';
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return OrdinTheme.error;
      case Priority.medium:
        return OrdinTheme.warning;
      case Priority.low:
        return OrdinTheme.success;
    }
  }

  String _getPriorityLabel(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
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

  void _openGoalForm([Goal? goal]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalFormScreen(
          goal: goal,
          onSave: (newGoal) async {
            await _goalRepo.saveGoal(newGoal);
            await _loadGoals();
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showAnalytics() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAnalyticsSheet(),
    );
  }

  Widget _buildAnalyticsSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: ThemeHelper.backgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: ThemeHelper.borderColor(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Goals Analytics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ThemeHelper.textPrimary(context),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Detailed analytics coming soon!',
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeHelper.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: OrdinTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.flag_outlined,
                size: 60,
                color: OrdinTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No goals yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ThemeHelper.textPrimary(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Set your first goal to start tracking progress and achieving your dreams',
              style: TextStyle(
                fontSize: 16,
                color: ThemeHelper.textSecondary(context),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _openGoalForm(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Create Your First Goal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: OrdinTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
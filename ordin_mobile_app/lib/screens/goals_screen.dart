import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../data/goal_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late GoalRepository _goalRepo;
  List<Goal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepo();
  }

  Future<void> _initRepo() async {
    final storage = HiveStorageService();
    await storage.init();
    _goalRepo = GoalRepository();
    await _goalRepo.init(storage);
    await _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await _goalRepo.loadGoals();
    setState(() {
      _goals = goals;
      _isLoading = false;
    });
  }

  Future<void> _addGoal() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    GoalCategory? category;
    Priority? priority;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('New Goal', style: AppTheme.headingLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  style: AppTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: AppTheme.labelMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  style: AppTheme.bodyLarge,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: AppTheme.labelMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<GoalCategory>(
                  value: category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: AppTheme.labelMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: GoalCategory.values.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(_categoryName(c), style: AppTheme.bodyLarge),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => category = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Priority>(
                  value: priority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    labelStyle: AppTheme.labelMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: Priority.values.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(_priorityName(p), style: AppTheme.bodyLarge),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => priority = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Add', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result == true && titleController.text.isNotEmpty && category != null && priority != null) {
      final goal = Goal(
        id: const Uuid().v4(),
        title: titleController.text,
        description: descController.text,
        category: category!,
        status: GoalStatus.active,
        priority: priority!,
        successMetrics: '',
        progress: 0.0,
        linkedTaskIds: [],
        linkedProjectIds: [],
        createdDate: DateTime.now(),
      );
      await _goalRepo.saveGoal(goal);
      await _loadGoals();
    }
  }

  Future<void> _deleteGoal(Goal goal) async {
    await _goalRepo.deleteGoal(goal.id);
    await _loadGoals();
  }

  int get _activeCount => _goals.where((g) => g.status == GoalStatus.active).length;
  int get _completedCount => _goals.where((g) => g.status == GoalStatus.completed).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: GradientAppBar(
        title: 'Goals',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  color: AppTheme.surfaceWhite,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Total', '${_goals.length}', Icons.flag_rounded, AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Active', '$_activeCount', Icons.trending_up_rounded, AppTheme.warningOrange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Done', '$_completedCount', Icons.check_circle_rounded, AppTheme.successGreen),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _goals.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _goals.length,
                          itemBuilder: (context, index) => _buildGoalCard(_goals[index]),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'goals_fab',
        onPressed: _addGoal,
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Goal', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.headingLarge.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final categoryColor = _categoryColor(goal.category);
    final priorityColor = _priorityColor(goal.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_categoryName(goal.category), style: AppTheme.labelMedium.copyWith(color: categoryColor)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_priorityName(goal.priority), style: AppTheme.labelMedium.copyWith(color: priorityColor)),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed),
                  onPressed: () => _deleteGoal(goal),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(goal.title, style: AppTheme.headingMedium),
            if (goal.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(goal.description, style: AppTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      backgroundColor: AppTheme.borderGray,
                      valueColor: AlwaysStoppedAnimation(categoryColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${(goal.progress * 100).toInt()}%', style: AppTheme.labelMedium.copyWith(color: categoryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.flag_rounded, size: 64, color: AppTheme.primaryBlue.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text('No goals yet', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text('Set your first goal to start achieving', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }

  String _categoryName(GoalCategory category) {
    switch (category) {
      case GoalCategory.career: return 'Career';
      case GoalCategory.health: return 'Health';
      case GoalCategory.finance: return 'Finance';
      case GoalCategory.relationships: return 'Relationships';
      case GoalCategory.personalGrowth: return 'Growth';
      case GoalCategory.learning: return 'Learning';
    }
  }

  Color _categoryColor(GoalCategory category) {
    switch (category) {
      case GoalCategory.career: return AppTheme.primaryBlue;
      case GoalCategory.health: return AppTheme.successGreen;
      case GoalCategory.finance: return AppTheme.warningOrange;
      case GoalCategory.relationships: return AppTheme.dangerRed;
      case GoalCategory.personalGrowth: return AppTheme.infoBlue;
      case GoalCategory.learning: return AppTheme.primaryBlue;
    }
  }

  String _priorityName(Priority priority) {
    switch (priority) {
      case Priority.high: return 'High';
      case Priority.medium: return 'Medium';
      case Priority.low: return 'Low';
    }
  }

  Color _priorityColor(Priority priority) {
    switch (priority) {
      case Priority.high: return AppTheme.dangerRed;
      case Priority.medium: return AppTheme.warningOrange;
      case Priority.low: return AppTheme.infoBlue;
    }
  }
}

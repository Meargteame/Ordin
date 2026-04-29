import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../data/goal_repository.dart';
import '../data/hive_storage_service.dart';
import '../widgets/goal_card.dart';
import '../theme/app_theme.dart';
import 'goal_detail_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with SingleTickerProviderStateMixin {
  final GoalRepository _repository = GoalRepository();
  final HiveStorageService _storage = HiveStorageService();
  List<Goal> _goals = [];
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initRepository();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initRepository() async {
    await _storage.init();
    await _repository.init(_storage);
    await _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await _repository.loadGoals();
    setState(() {
      _goals = goals;
      _isLoading = false;
    });
  }

  void _onTabChanged() {
    setState(() {});
  }

  List<Goal> get _filteredGoals {
    if (_tabController.index == 0) {
      return _goals;
    }
    final category = GoalCategory.values[_tabController.index - 1];
    return _goals.where((goal) => goal.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Goals',
                    style: AppTheme.heading1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _goals.isEmpty
                        ? 'No goals yet'
                        : '${_goals.length} ${_goals.length == 1 ? 'goal' : 'goals'}',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            // Category tabs
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip('All', 0),
                  _buildCategoryChip('💼 Career', 1),
                  _buildCategoryChip('💪 Health', 2),
                  _buildCategoryChip('💰 Finance', 3),
                  _buildCategoryChip('❤️ Relations', 4),
                  _buildCategoryChip('🌱 Growth', 5),
                  _buildCategoryChip('📚 Learning', 6),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Goals list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : _filteredGoals.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredGoals.length,
                          itemBuilder: (context, index) {
                            final goal = _filteredGoals[index];
                            return GoalCard(
                              goal: goal,
                              onTap: () => _navigateToDetail(goal),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateGoalDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Goal'),
      ),
    );
  }

  Widget _buildCategoryChip(String label, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.flag_rounded,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No goals yet',
            style: AppTheme.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first goal to get started',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateGoalDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final metricsController = TextEditingController();
    GoalCategory selectedCategory = GoalCategory.career;
    Priority selectedPriority = Priority.medium;
    DateTime? selectedDeadline;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter goal title',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What do you want to achieve?',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<GoalCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: GoalCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_getCategoryName(category)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Priority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: Priority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(_getPriorityName(priority)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedPriority = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Deadline'),
                  subtitle: Text(
                    selectedDeadline != null
                        ? '${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}'
                        : 'No deadline set',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDeadline = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: metricsController,
                  decoration: const InputDecoration(
                    labelText: 'Success Metrics',
                    hintText: 'How will you measure success?',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final goal = Goal(
        id: const Uuid().v4(),
        title: titleController.text,
        description: descriptionController.text,
        category: selectedCategory,
        status: GoalStatus.active,
        priority: selectedPriority,
        deadline: selectedDeadline,
        successMetrics: metricsController.text,
        progress: 0.0,
        linkedTaskIds: [],
        linkedProjectIds: [],
        createdDate: DateTime.now(),
      );

      await _repository.saveGoal(goal);
      await _loadGoals();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal created')),
        );
      }
    }
  }

  String _getCategoryName(GoalCategory category) {
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

  String _getPriorityName(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  Future<void> _navigateToDetail(Goal goal) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailScreen(goalId: goal.id),
      ),
    );
    await _loadGoals();
  }
}

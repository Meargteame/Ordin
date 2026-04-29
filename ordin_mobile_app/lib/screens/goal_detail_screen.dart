import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../data/goal_repository.dart';
import '../data/hive_storage_service.dart';
import '../widgets/milestone_item.dart';

class GoalDetailScreen extends StatefulWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final GoalRepository _repository = GoalRepository();
  final HiveStorageService _storage = HiveStorageService();
  Goal? _goal;
  List<Milestone> _milestones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  Future<void> _initRepository() async {
    await _storage.init();
    await _repository.init(_storage);
    await _loadGoal();
  }

  Future<void> _loadGoal() async {
    final goals = await _repository.loadGoals();
    final goal = goals.where((g) => g.id == widget.goalId).firstOrNull;
    final milestones = goal != null ? await _repository.loadMilestones(goal.id) : <Milestone>[];
    
    setState(() {
      _goal = goal;
      _milestones = milestones;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Goal Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_goal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Goal Details')),
        body: const Center(child: Text('Goal not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_goal!.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDescription(),
            const SizedBox(height: 24),
            _buildProgressSection(),
            const SizedBox(height: 24),
            _buildInfoSection(),
            const SizedBox(height: 24),
            _buildMilestonesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_goal!.description.isEmpty ? 'No description' : _goal!.description),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    Color progressColor;
    if (_goal!.progress < 0.33) {
      progressColor = Colors.red;
    } else if (_goal!.progress < 0.67) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _goal!.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_goal!.progress * 100).toInt()}% complete',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Category', _getCategoryName(_goal!.category)),
            const Divider(),
            _buildInfoRow('Priority', _getPriorityName(_goal!.priority)),
            const Divider(),
            _buildInfoRow(
              'Deadline',
              _goal!.deadline != null
                  ? '${_goal!.deadline!.day}/${_goal!.deadline!.month}/${_goal!.deadline!.year}'
                  : 'No deadline',
            ),
            const Divider(),
            _buildInfoRow('Status', _getStatusName(_goal!.status)),
            if (_goal!.successMetrics.isNotEmpty) ...[
              const Divider(),
              const Text(
                'Success Metrics',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(_goal!.successMetrics),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildMilestonesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Milestones (${_milestones.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddMilestoneDialog,
                ),
              ],
            ),
            if (_milestones.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('No milestones yet', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ..._milestones.map((milestone) => MilestoneItem(
                    milestone: milestone,
                    onToggle: () => _toggleMilestone(milestone),
                    onDelete: () => _deleteMilestone(milestone),
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddMilestoneDialog() async {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Milestone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter milestone title',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Target Date'),
                subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    setDialogState(() => selectedDate = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final milestone = Milestone(
        id: const Uuid().v4(),
        goalId: _goal!.id,
        title: titleController.text,
        targetDate: selectedDate,
        isCompleted: false,
      );

      await _repository.saveMilestone(milestone);
      await _loadGoal();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Milestone added')),
        );
      }
    }
  }

  Future<void> _toggleMilestone(Milestone milestone) async {
    if (milestone.isCompleted) {
      milestone.isCompleted = false;
      milestone.completedDate = null;
    } else {
      await _repository.completeMilestone(milestone.id);
    }
    await _loadGoal();
  }

  Future<void> _deleteMilestone(Milestone milestone) async {
    await _repository.deleteMilestone(milestone.id);
    await _loadGoal();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Milestone deleted')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _repository.deleteGoal(_goal!.id);
      if (mounted) {
        Navigator.pop(context);
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

  String _getStatusName(GoalStatus status) {
    switch (status) {
      case GoalStatus.active:
        return 'Active';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.archived:
        return 'Archived';
      case GoalStatus.onHold:
        return 'On Hold';
    }
  }
}

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../data/task_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

enum TaskFilter { all, today, upcoming, completed }
enum TaskSort { priority, dueDate, alphabetical }

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late TaskRepository _taskRepo;
  List<Task> _tasks = [];
  bool _isLoading = true;
  TaskFilter _currentFilter = TaskFilter.all;
  TaskSort _currentSort = TaskSort.priority;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initRepo();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initRepo() async {
    final storage = HiveStorageService();
    await storage.init();
    _taskRepo = TaskRepository(storage);
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _taskRepo.loadTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  List<Task> get _filteredTasks {
    var filtered = _tasks.where((task) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!task.title.toLowerCase().contains(query) &&
            !task.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Status filter
      switch (_currentFilter) {
        case TaskFilter.all:
          return true;
        case TaskFilter.today:
          return !task.isDone && (task.isDueToday || task.isScheduledFor(DateTime.now()));
        case TaskFilter.upcoming:
          return !task.isDone && task.dueDate != null && task.dueDate!.isAfter(DateTime.now());
        case TaskFilter.completed:
          return task.isDone;
      }
    }).toList();

    // Sort
    switch (_currentSort) {
      case TaskSort.priority:
        filtered.sort((a, b) {
          if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
          final priorityOrder = {TaskPriority.high: 0, TaskPriority.medium: 1, TaskPriority.low: 2};
          return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
        });
        break;
      case TaskSort.dueDate:
        filtered.sort((a, b) {
          if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TaskSort.alphabetical:
        filtered.sort((a, b) {
          if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        break;
    }

    return filtered;
  }

  Future<void> _addTask() async {
    await _showTaskDialog();
  }

  Future<void> _editTask(Task task) async {
    await _showTaskDialog(task: task);
  }

  Future<void> _showTaskDialog({Task? task}) async {
    final isEdit = task != null;
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    DateTime? selectedDueDate = task?.dueDate;
    TaskPriority selectedPriority = task?.priority ?? TaskPriority.medium;
    List<String> selectedTags = List.from(task?.tags ?? []);
    final tagController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Task' : 'New Task', style: AppTheme.headingLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextField(
                  controller: titleController,
                  autofocus: !isEdit,
                  style: AppTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Task title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                TextField(
                  controller: descController,
                  style: AppTheme.bodyMedium,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Add details...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Priority
                Text('Priority', style: AppTheme.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: TaskPriority.values.map((priority) {
                    final isSelected = selectedPriority == priority;
                    final color = _getPriorityColor(priority);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_getPriorityLabel(priority)),
                          selected: isSelected,
                          onSelected: (_) => setDialogState(() => selectedPriority = priority),
                          selectedColor: color.withOpacity(0.2),
                          labelStyle: TextStyle(color: isSelected ? color : AppTheme.textSecondary),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // Due Date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                  title: Text(selectedDueDate == null ? 'Set due date' : _formatDate(selectedDueDate!)),
                  trailing: selectedDueDate != null 
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20),
                        onPressed: () => setDialogState(() => selectedDueDate = null),
                      )
                    : null,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDueDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Tags
                Text('Tags', style: AppTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ...selectedTags.map((tag) => Chip(
                      label: Text(tag, style: AppTheme.labelMedium),
                      deleteIcon: Icon(Icons.close, size: 16),
                      onDeleted: () => setDialogState(() => selectedTags.remove(tag)),
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    )),
                    ActionChip(
                      label: Icon(Icons.add, size: 16),
                      onPressed: () async {
                        final tag = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Add Tag'),
                            content: TextField(
                              controller: tagController,
                              autofocus: true,
                              decoration: InputDecoration(hintText: 'Tag name'),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, tagController.text),
                                child: Text('Add'),
                              ),
                            ],
                          ),
                        );
                        if (tag != null && tag.isNotEmpty && !selectedTags.contains(tag)) {
                          setDialogState(() => selectedTags.add(tag));
                          tagController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.isEmpty) return;
                
                final newTask = Task(
                  id: task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  isDone: task?.isDone ?? false,
                  date: task?.date ?? DateTime.now(),
                  dueDate: selectedDueDate,
                  priority: selectedPriority,
                  tags: selectedTags,
                  description: descController.text.isEmpty ? null : descController.text,
                  subtasks: task?.subtasks ?? [],
                );
                
                _taskRepo.saveTask(newTask).then((_) {
                  _loadTasks();
                  Navigator.pop(context);
                });
              },
              child: Text(isEdit ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleTask(Task task) async {
    task.isDone = !task.isDone;
    await _taskRepo.saveTask(task);
    setState(() {});
  }

  Future<void> _deleteTask(Task task) async {
    await _taskRepo.deleteTask(task.id);
    await _loadTasks();
  }

  Future<void> _manageSubtasks(Task task) async {
    final subtaskController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Subtasks', style: AppTheme.headingLarge),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (task.subtasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('No subtasks yet', style: AppTheme.bodyMedium),
                  )
                else
                  ...task.subtasks.map((subtask) => CheckboxListTile(
                    value: subtask.isDone,
                    title: Text(subtask.title),
                    onChanged: (value) {
                      setDialogState(() => subtask.isDone = value ?? false);
                    },
                    secondary: IconButton(
                      icon: Icon(Icons.delete_outline, size: 20),
                      onPressed: () {
                        setDialogState(() => task.subtasks.remove(subtask));
                      },
                    ),
                  )),
                const SizedBox(height: 16),
                TextField(
                  controller: subtaskController,
                  decoration: InputDecoration(
                    hintText: 'Add subtask',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (subtaskController.text.isNotEmpty) {
                          setDialogState(() {
                            task.subtasks.add(Subtask(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: subtaskController.text,
                            ));
                            subtaskController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setDialogState(() {
                        task.subtasks.add(Subtask(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: value,
                        ));
                        subtaskController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                _taskRepo.saveTask(task).then((_) {
                  _loadTasks();
                  Navigator.pop(context);
                });
              },
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  int get _completedCount => _tasks.where((t) => t.isDone).length;
  int get _overdueCount => _tasks.where((t) => t.isOverdue).length;

  @override
  Widget build(BuildContext context) {
    final displayTasks = _filteredTasks;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: GradientAppBar(
        title: 'Tasks',
        actions: [
          // Sort
          PopupMenuButton<TaskSort>(
            icon: Icon(Icons.sort_rounded, color: Colors.white),
            onSelected: (sort) => setState(() => _currentSort = sort),
            itemBuilder: (context) => [
              PopupMenuItem(value: TaskSort.priority, child: Text('Sort by Priority')),
              PopupMenuItem(value: TaskSort.dueDate, child: Text('Sort by Due Date')),
              PopupMenuItem(value: TaskSort.alphabetical, child: Text('Sort Alphabetically')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Header
                Container(
                  padding: const EdgeInsets.all(20),
                  color: AppTheme.surfaceWhite,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Total', '${_tasks.length}', Icons.list_rounded, AppTheme.primaryBlue)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Done', '$_completedCount', Icons.check_circle_rounded, AppTheme.successGreen)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Overdue', '$_overdueCount', Icons.warning_rounded, AppTheme.dangerRed)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search
                      TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                // Filters
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: TaskFilter.values.map((filter) {
                      final isSelected = _currentFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getFilterLabel(filter)),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _currentFilter = filter),
                          selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                // Task List
                Expanded(
                  child: displayTasks.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: displayTasks.length,
                          itemBuilder: (context, index) => _buildTaskCard(displayTasks[index]),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tasks_fab',
        onPressed: _addTask,
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Task', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.headingMedium.copyWith(color: color)),
          Text(label, style: AppTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isOverdue ? AppTheme.dangerRed : 
                 task.isDone ? AppTheme.successGreen.withOpacity(0.3) : 
                 AppTheme.borderGray,
          width: task.isOverdue || task.isDone ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleTask(task),
          onLongPress: () => _editTask(task),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Checkbox
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isDone ? AppTheme.successGreen : Colors.transparent,
                        border: Border.all(
                          color: task.isDone ? AppTheme.successGreen : AppTheme.borderGray,
                          width: 2,
                        ),
                      ),
                      child: task.isDone ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: Text(
                        task.title,
                        style: AppTheme.bodyLarge.copyWith(
                          decoration: task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone ? AppTheme.textSecondary : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    // Priority indicator
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getPriorityColor(task.priority),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // More menu
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert, size: 20),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                          onTap: () => Future.delayed(Duration.zero, () => _editTask(task)),
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.checklist, size: 18),
                              SizedBox(width: 8),
                              Text('Subtasks'),
                            ],
                          ),
                          onTap: () => Future.delayed(Duration.zero, () => _manageSubtasks(task)),
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: AppTheme.dangerRed),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: AppTheme.dangerRed)),
                            ],
                          ),
                          onTap: () => _deleteTask(task),
                        ),
                      ],
                    ),
                  ],
                ),
                // Description
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.description!,
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                // Due date & Tags
                if (task.dueDate != null || task.tags.isNotEmpty || task.subtasks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (task.dueDate != null)
                        _buildChip(
                          _formatDate(task.dueDate!),
                          Icons.calendar_today,
                          task.isOverdue ? AppTheme.dangerRed : 
                          task.isDueToday ? AppTheme.warningOrange : 
                          AppTheme.textSecondary,
                        ),
                      if (task.subtasks.isNotEmpty)
                        _buildChip(
                          '${task.completedSubtasks}/${task.subtasks.length}',
                          Icons.checklist,
                          AppTheme.primaryBlue,
                        ),
                      ...task.tags.map((tag) => _buildChip(tag, Icons.tag, AppTheme.primaryBlue)),
                    ],
                  ),
                ],
                // Subtask progress
                if (task.subtasks.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: task.subtaskProgress,
                      backgroundColor: AppTheme.borderGray,
                      valueColor: AlwaysStoppedAnimation(AppTheme.successGreen),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTheme.labelMedium.copyWith(color: color)),
        ],
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
            child: Icon(Icons.task_alt_rounded, size: 64, color: AppTheme.primaryBlue.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text(_getEmptyStateTitle(), style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text(_getEmptyStateMessage(), style: AppTheme.bodyMedium),
        ],
      ),
    );
  }

  String _getEmptyStateTitle() {
    if (_searchQuery.isNotEmpty) return 'No tasks found';
    switch (_currentFilter) {
      case TaskFilter.today: return 'No tasks for today';
      case TaskFilter.upcoming: return 'No upcoming tasks';
      case TaskFilter.completed: return 'No completed tasks';
      default: return 'No tasks yet';
    }
  }

  String _getEmptyStateMessage() {
    if (_searchQuery.isNotEmpty) return 'Try a different search term';
    return 'Tap the button below to add a task';
  }

  String _getFilterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all: return 'All';
      case TaskFilter.today: return 'Today';
      case TaskFilter.upcoming: return 'Upcoming';
      case TaskFilter.completed: return 'Completed';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return AppTheme.dangerRed;
      case TaskPriority.medium: return AppTheme.warningOrange;
      case TaskPriority.low: return AppTheme.successGreen;
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return 'High';
      case TaskPriority.medium: return 'Medium';
      case TaskPriority.low: return 'Low';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) return 'Today';
    if (taskDate == tomorrow) return 'Tomorrow';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/goal.dart';
import '../data/task_repository.dart';
import '../data/goal_repository.dart';
import '../data/hive_storage_service.dart';
import '../widgets/task_item.dart';
import '../theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late TaskRepository _taskRepository;
  late GoalRepository _goalRepository;
  late HiveStorageService _storageService;
  List<Task> _tasks = [];
  List<Goal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    try {
      _storageService = HiveStorageService();
      await _storageService.init();
      _taskRepository = TaskRepository(_storageService);
      _goalRepository = GoalRepository();
      await _goalRepository.init(_storageService);
      await _loadTasks();
      await _loadGoals();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackBar('Failed to initialize storage', isError: true);
      }
    }
  }

  Future<void> _loadGoals() async {
    try {
      final goals = await _goalRepository.getActiveGoals();
      setState(() => _goals = goals);
    } catch (e) {
      // Silent fail for goals
    }
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _taskRepository.loadTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackBar('Failed to load tasks', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _showCreateTaskDialog() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final selectedGoals = <String>{};
    
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_task_rounded,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('New Task', style: AppTheme.heading3),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'What needs to be done?',
                        hintStyle: AppTheme.bodyMedium,
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        hintText: 'Description (optional)',
                        hintStyle: AppTheme.bodyMedium,
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 2,
                    ),
                    if (_goals.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Link to Goals', style: AppTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _goals.map((goal) {
                          final isSelected = selectedGoals.contains(goal.id);
                          return FilterChip(
                            label: Text(goal.title),
                            selected: isSelected,
                            onSelected: (selected) {
                              setDialogState(() {
                                if (selected) {
                                  selectedGoals.add(goal.id);
                                } else {
                                  selectedGoals.remove(goal.id);
                                }
                              });
                            },
                            backgroundColor: AppTheme.cardColor,
                            selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final title = titleController.text.trim();
                            
                            if (title.isEmpty) {
                              _showSnackBar('Task title cannot be empty', isError: true);
                              return;
                            }
                            
                            final newTask = Task(
                              id: const Uuid().v4(),
                              title: title,
                              isDone: false,
                              date: DateTime.now(),
                              description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                              goalIds: selectedGoals.toList(),
                            );
                            
                            try {
                              await _taskRepository.saveTask(newTask);
                              
                              // Update goal progress for linked goals
                              for (final goalId in selectedGoals) {
                                await _goalRepository.updateGoalProgress(goalId);
                              }
                              
                              await _loadTasks();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                _showSnackBar('Task created successfully');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                _showSnackBar('Failed to save task', isError: true);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleTask(Task task) async {
    setState(() {
      task.isDone = !task.isDone;
    });
    try {
      await _taskRepository.saveTask(task);
    } catch (e) {
      setState(() {
        task.isDone = !task.isDone;
      });
      if (mounted) {
        _showSnackBar('Failed to update task', isError: true);
      }
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      await _taskRepository.deleteTask(task.id);
      setState(() {
        _tasks.removeWhere((t) => t.id == task.id);
      });
      if (mounted) {
        _showSnackBar('Task deleted');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to delete task', isError: true);
      }
    }
  }

  int get _completedCount => _tasks.where((t) => t.isDone).length;

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
                    'Tasks',
                    style: AppTheme.heading1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tasks.isEmpty
                        ? 'No tasks yet'
                        : '$_completedCount of ${_tasks.length} completed',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            // Task list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : _tasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.task_alt_rounded,
                                  size: 64,
                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No tasks yet',
                                style: AppTheme.heading3.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to create your first task',
                                style: AppTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            return Dismissible(
                              key: Key(task.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              onDismissed: (direction) async {
                                await _deleteTask(task);
                              },
                              child: TaskItem(
                                task: task,
                                onToggle: () => _toggleTask(task),
                                onDelete: () => _deleteTask(task),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTaskDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ),
    );
  }
}

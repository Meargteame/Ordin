import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../data/task_repository.dart';
import '../data/habit_repository.dart';
import '../data/hive_storage_service.dart';
import '../widgets/task_item.dart';
import '../widgets/habit_item.dart';
import '../widgets/focus_text_field.dart';
import '../theme/app_theme.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with WidgetsBindingObserver {
  late TaskRepository _taskRepository;
  late HabitRepository _habitRepository;
  late HiveStorageService _storageService;
  List<Task> _todayTasks = [];
  List<Habit> _habits = [];
  String _focusText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeStorage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndResetDaily();
      _loadData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading) {
      _loadData();
    }
  }

  Future<void> _initializeStorage() async {
    try {
      _storageService = HiveStorageService();
      await _storageService.init();
      _taskRepository = TaskRepository(_storageService);
      _habitRepository = HabitRepository(_storageService);
      await _checkAndResetDaily();
      await _loadData();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackBar('Failed to initialize storage', isError: true);
      }
    }
  }

  Future<void> _checkAndResetDaily() async {
    try {
      await _habitRepository.performDailyReset();
    } catch (e) {
      debugPrint('Daily reset check failed: $e');
    }
  }

  Future<void> _loadData() async {
    try {
      final now = DateTime.now();
      final allTasks = await _taskRepository.loadTasks();
      final todayTasks = allTasks.where((task) => task.isScheduledFor(now)).toList();
      final habits = await _habitRepository.loadHabits();
      final focusText = await _storageService.getString('focus_text') ?? '';
      
      setState(() {
        _todayTasks = todayTasks;
        _habits = habits;
        _focusText = focusText;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackBar('Failed to load data', isError: true);
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

  Future<void> _saveFocusText(String text) async {
    try {
      await _storageService.saveString('focus_text', text);
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to save focus text', isError: true);
      }
    }
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

  Future<void> _toggleHabit(Habit habit) async {
    setState(() {
      habit.toggle();
    });
    try {
      await _habitRepository.saveHabit(habit);
    } catch (e) {
      setState(() {
        habit.toggle();
      });
      if (mounted) {
        _showSnackBar('Failed to update habit', isError: true);
      }
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      await _taskRepository.deleteTask(task.id);
      setState(() {
        _todayTasks.removeWhere((t) => t.id == task.id);
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

  Future<void> _deleteHabit(Habit habit) async {
    try {
      await _habitRepository.deleteHabit(habit.id);
      setState(() {
        _habits.removeWhere((h) => h.id == habit.id);
      });
      if (mounted) {
        _showSnackBar('Habit deleted');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to delete habit', isError: true);
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = _todayTasks.where((t) => t.isDone).length;
    final completedHabits = _habits.where((h) => h.isDoneToday).length;
    final totalItems = _todayTasks.length + _habits.length;
    final completedItems = completedTasks + completedHabits;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting header
                    Text(
                      _getGreeting(),
                      style: AppTheme.heading1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalItems == 0
                          ? 'You have nothing planned for today'
                          : completedItems == totalItems
                              ? '🎉 All done for today!'
                              : 'You have $totalItems ${totalItems == 1 ? 'item' : 'items'} today',
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Progress indicator
                    if (totalItems > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.1),
                              AppTheme.secondaryColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Today\'s Progress',
                                  style: AppTheme.heading3.copyWith(
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                Text(
                                  '$completedItems/$totalItems',
                                  style: AppTheme.heading3.copyWith(
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: totalItems > 0 ? completedItems / totalItems : 0,
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Focus text field
                    FocusTextField(
                      initialText: _focusText,
                      onTextChanged: _saveFocusText,
                    ),
                    const SizedBox(height: 32),
                    
                    // Today's tasks section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Tasks',
                          style: AppTheme.heading2,
                        ),
                        if (_todayTasks.isNotEmpty)
                          Text(
                            '$completedTasks/${_todayTasks.length}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _todayTasks.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.textSecondary.withOpacity(0.1),
                              ),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.task_alt_rounded,
                                    size: 48,
                                    color: AppTheme.textSecondary.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No tasks for today',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _todayTasks.length,
                            itemBuilder: (context, index) {
                              final task = _todayTasks[index];
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
                    const SizedBox(height: 32),
                    
                    // Habits section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Habits',
                          style: AppTheme.heading2,
                        ),
                        if (_habits.isNotEmpty)
                          Text(
                            '$completedHabits/${_habits.length}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _habits.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.textSecondary.withOpacity(0.1),
                              ),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 48,
                                    color: AppTheme.textSecondary.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No habits yet',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _habits.length,
                            itemBuilder: (context, index) {
                              final habit = _habits[index];
                              return Dismissible(
                                key: Key(habit.id),
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
                                  await _deleteHabit(habit);
                                },
                                child: HabitItem(
                                  habit: habit,
                                  onToggle: () => _toggleHabit(habit),
                                  onDelete: () => _deleteHabit(habit),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

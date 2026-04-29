import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../data/habit_repository.dart';
import '../data/hive_storage_service.dart';
import '../widgets/habit_item.dart';
import '../theme/app_theme.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> with WidgetsBindingObserver {
  late HabitRepository _habitRepository;
  late HiveStorageService _storageService;
  List<Habit> _habits = [];
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
    }
  }

  Future<void> _initializeStorage() async {
    try {
      _storageService = HiveStorageService();
      await _storageService.init();
      _habitRepository = HabitRepository(_storageService);
      await _checkAndResetDaily();
      await _loadHabits();
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

  Future<void> _loadHabits() async {
    try {
      final habits = await _habitRepository.loadHabits();
      setState(() {
        _habits = habits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackBar('Failed to load habits', isError: true);
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

  Future<void> _showCreateHabitDialog() async {
    final nameController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                        Icons.auto_awesome_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'New Habit',
                      style: AppTheme.heading3,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'What habit do you want to build?',
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
                        final name = nameController.text.trim();
                        
                        if (name.isEmpty) {
                          _showSnackBar('Habit name cannot be empty', isError: true);
                          return;
                        }
                        
                        final newHabit = Habit(
                          id: const Uuid().v4(),
                          name: name,
                          isDoneToday: false,
                          streak: 0,
                        );
                        
                        try {
                          await _habitRepository.saveHabit(newHabit);
                          await _loadHabits();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            _showSnackBar('Habit created successfully');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            _showSnackBar('Failed to save habit', isError: true);
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
        );
      },
    );
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

  int get _completedCount => _habits.where((h) => h.isDoneToday).length;
  int get _totalStreak => _habits.fold(0, (sum, h) => sum + h.streak);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with stats
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Habits',
                    style: AppTheme.heading1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _habits.isEmpty
                        ? 'No habits yet'
                        : '$_completedCount of ${_habits.length} completed today',
                    style: AppTheme.bodyMedium,
                  ),
                  if (_totalStreak > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.warningColor.withOpacity(0.15),
                            AppTheme.warningColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.warningColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppTheme.warningColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Total streak: $_totalStreak days',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Habit list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : _habits.isEmpty
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
                                  Icons.auto_awesome_rounded,
                                  size: 64,
                                  color: AppTheme.primaryColor.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No habits yet',
                                style: AppTheme.heading3.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to create your first habit',
                                style: AppTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateHabitDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Habit'),
      ),
    );
  }
}

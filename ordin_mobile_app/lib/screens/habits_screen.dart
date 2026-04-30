import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/habit_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  late HabitRepository _habitRepo;
  List<Habit> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepo();
  }

  Future<void> _initRepo() async {
    final storage = HiveStorageService();
    await storage.init();
    _habitRepo = HabitRepository(storage);
    await _habitRepo.performDailyReset();
    await _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await _habitRepo.loadHabits();
    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }

  Future<void> _addHabit() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Habit', style: AppTheme.headingLarge),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Habit name',
            hintStyle: AppTheme.bodyMedium,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.successGreen, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Add', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result,
        isDoneToday: false,
        streak: 0,
      );
      await _habitRepo.saveHabit(habit);
      await _loadHabits();
    }
  }

  Future<void> _toggleHabit(Habit habit) async {
    habit.toggle();
    await _habitRepo.saveHabit(habit);
    setState(() {});
  }

  Future<void> _deleteHabit(Habit habit) async {
    await _habitRepo.deleteHabit(habit.id);
    await _loadHabits();
  }

  int get _completedCount => _habits.where((h) => h.isDoneToday).length;
  int get _longestStreak => _habits.isEmpty ? 0 : _habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Habits', style: AppTheme.displayMedium),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppTheme.borderGray,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Header
                Container(
                  padding: const EdgeInsets.all(20),
                  color: AppTheme.surfaceWhite,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          '${_habits.length}',
                          Icons.auto_awesome_rounded,
                          AppTheme.successGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Today',
                          '$_completedCount',
                          Icons.check_circle_rounded,
                          AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Best Streak',
                          '$_longestStreak',
                          Icons.local_fire_department_rounded,
                          AppTheme.warningOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Habit List
                Expanded(
                  child: _habits.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _habits.length,
                          itemBuilder: (context, index) {
                            final habit = _habits[index];
                            return _buildHabitCard(habit);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addHabit,
        backgroundColor: AppTheme.successGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Habit', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
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

  Widget _buildHabitCard(Habit habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: habit.isDoneToday ? AppTheme.successGreen.withOpacity(0.3) : AppTheme.borderGray,
          width: habit.isDoneToday ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleHabit(habit),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: habit.isDoneToday ? AppTheme.successGreen : Colors.transparent,
                    border: Border.all(
                      color: habit.isDoneToday ? AppTheme.successGreen : AppTheme.borderGray,
                      width: 2,
                    ),
                  ),
                  child: habit.isDoneToday
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.name,
                    style: AppTheme.bodyLarge.copyWith(
                      decoration: habit.isDoneToday ? TextDecoration.lineThrough : null,
                      color: habit.isDoneToday ? AppTheme.textSecondary : AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.warningOrange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 16, color: AppTheme.warningOrange),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.streak}',
                        style: AppTheme.labelLarge.copyWith(color: AppTheme.warningOrange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed),
                  onPressed: () => _deleteHabit(habit),
                ),
              ],
            ),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 64,
              color: AppTheme.successGreen.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text('No habits yet', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text('Build consistency with daily habits', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}

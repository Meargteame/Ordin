import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/habit_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/modern_dark_colors.dart';
import '../theme/modern_dark_typography.dart';
import '../theme/modern_dark_spacing.dart';
import '../widgets/modern/pill_tag.dart';


class ModernHabitsScreen extends StatefulWidget {
  const ModernHabitsScreen({super.key});

  @override
  State<ModernHabitsScreen> createState() => _ModernHabitsScreenState();
}

class _ModernHabitsScreenState extends State<ModernHabitsScreen> {
  late HabitRepository _habitRepo;
  List<Habit> _habits = [];
  bool _isLoading = true;
  HabitCategory? _filterCategory;

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

  List<Habit> get _filteredHabits {
    if (_filterCategory == null) return _habits;
    return _habits.where((h) => h.category == _filterCategory).toList();
  }

  Future<void> _toggleHabit(Habit habit) async {
    habit.toggle(DateTime.now());
    await _habitRepo.saveHabit(habit);
    setState(() {});
  }

  int get _completedCount => _habits.where((h) => h.isDoneToday).length;
  int get _scheduledToday => _habits.where((h) => h.isScheduledForToday()).length;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: ModernDarkColors.darkBackground,
        body: Center(
          child: CircularProgressIndicator(
            color: ModernDarkColors.limeAccent,
          ),
        ),
      );
    }

    final displayHabits = _filteredHabits;

    return Scaffold(
      backgroundColor: ModernDarkColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsHeader(),
            _buildCategoryFilter(),
            Expanded(
              child: displayHabits.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        left: ModernDarkSpacing.screenPadding,
                        right: ModernDarkSpacing.screenPadding,
                        bottom: ModernDarkSpacing.md,
                      ),
                      itemCount: displayHabits.length,
                      itemBuilder: (context, index) => _buildHabitCard(displayHabits[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(ModernDarkSpacing.screenPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Habits',
            style: ModernDarkTypography.displayMedium,
          ),
          Icon(
            Icons.search_rounded,
            color: ModernDarkColors.textPrimary,
            size: 24.0,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ModernDarkSpacing.screenPadding,
        vertical: ModernDarkSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Scheduled', '$_scheduledToday', ModernDarkColors.blue)),
          const SizedBox(width: ModernDarkSpacing.md),
          Expanded(child: _buildStatCard('Done', '$_completedCount', ModernDarkColors.green)),
          const SizedBox(width: ModernDarkSpacing.md),
          Expanded(child: _buildStatCard('Streak', '${_habits.isEmpty ? 0 : _habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b)}', ModernDarkColors.orange)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(ModernDarkSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusMd),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: ModernDarkTypography.headingMedium.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: ModernDarkTypography.labelSmall.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50.0,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: ModernDarkSpacing.screenPadding),
        children: [
          _buildFilterChip('All', _filterCategory == null, () {
            setState(() => _filterCategory = null);
          }),
          ...HabitCategory.values.map((category) {
            return _buildFilterChip(
              _getCategoryLabel(category),
              _filterCategory == category,
              () {
                setState(() => _filterCategory = category);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? ModernDarkColors.limeAccent : ModernDarkColors.cardElevated,
          borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusXs),
        ),
        child: Text(
          label,
          style: ModernDarkTypography.labelMedium.copyWith(
            color: isSelected ? ModernDarkColors.textOnLime : ModernDarkColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final isScheduled = habit.isScheduledForToday();

    return GestureDetector(
      onTap: isScheduled ? () => _toggleHabit(habit) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: ModernDarkSpacing.md),
        padding: const EdgeInsets.all(ModernDarkSpacing.cardPadding),
        decoration: BoxDecoration(
          color: ModernDarkColors.cardElevated,
          borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusMd),
          border: Border.all(
            color: habit.isDoneToday 
                ? ModernDarkColors.green.withOpacity(0.5)
                : ModernDarkColors.cardLight,
            width: habit.isDoneToday ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 28.0,
              height: 28.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: habit.isDoneToday ? ModernDarkColors.green : Colors.transparent,
                border: Border.all(
                  color: habit.isDoneToday ? ModernDarkColors.green : ModernDarkColors.textSecondary,
                  width: 2.0,
                ),
              ),
              child: habit.isDoneToday
                  ? const Icon(Icons.check_rounded, size: 16.0, color: Colors.white)
                  : null,
            ),
            
            const SizedBox(width: ModernDarkSpacing.md),
            
            // Name
            Expanded(
              child: Text(
                habit.name,
                style: ModernDarkTypography.taskTitle.copyWith(
                  decoration: habit.isDoneToday ? TextDecoration.lineThrough : null,
                  color: habit.isDoneToday ? ModernDarkColors.textSecondary : ModernDarkColors.textPrimary,
                ),
              ),
            ),
            
            // Streak
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: ModernDarkColors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusXs),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 16.0,
                    color: ModernDarkColors.orange,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    '${habit.streak}',
                    style: ModernDarkTypography.labelMedium.copyWith(
                      color: ModernDarkColors.orange,
                    ),
                  ),
                ],
              ),
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
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: ModernDarkColors.limeAccent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 64.0,
              color: ModernDarkColors.limeAccent,
            ),
          ),
          const SizedBox(height: ModernDarkSpacing.xxl),
          Text(
            'No habits yet',
            style: ModernDarkTypography.headingLarge,
          ),
          const SizedBox(height: ModernDarkSpacing.sm),
          Text(
            'Build consistency with daily habits',
            style: ModernDarkTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(HabitCategory category) {
    switch (category) {
      case HabitCategory.morning: return 'Morning';
      case HabitCategory.afternoon: return 'Afternoon';
      case HabitCategory.evening: return 'Evening';
      case HabitCategory.anytime: return 'Anytime';
      case HabitCategory.health: return 'Health';
      case HabitCategory.productivity: return 'Productivity';
      case HabitCategory.personal: return 'Personal';
    }
  }
}

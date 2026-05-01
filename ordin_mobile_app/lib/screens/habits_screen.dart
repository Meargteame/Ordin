import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/habit_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/premium_colors.dart';
import '../theme/premium_typography.dart';
import '../theme/premium_spacing.dart';
import '../theme/premium_shadows.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/habit_form_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
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

  Future<void> _addOrEditHabit({Habit? habit}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitFormScreen(
          habit: habit,
          onSave: (updatedHabit) async {
            await _habitRepo.saveHabit(updatedHabit);
            await _loadHabits();
          },
          onDelete: habit != null ? () async {
            await _habitRepo.deleteHabit(habit.id);
            await _loadHabits();
          } : null,
        ),
      ),
    );
  }

  Future<void> _toggleHabit(Habit habit) async {
    habit.toggle(DateTime.now());
    await _habitRepo.saveHabit(habit);
    setState(() {});
  }

  Future<void> _deleteHabit(Habit habit) async {
    await _habitRepo.deleteHabit(habit.id);
    await _loadHabits();
  }

  Future<void> _showHabitStats(Habit habit) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(habit.name, style: PremiumTypography.headingLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('Current Streak', '${habit.streak} days', Icons.local_fire_department),
            _buildStatRow('Best Streak', '${habit.bestStreak} days', Icons.emoji_events),
            _buildStatRow('Total Completions', '${habit.totalCompletions}', Icons.check_circle),
            _buildStatRow('Success Rate', '${(habit.successRate * 100).toStringAsFixed(1)}%', Icons.trending_up),
            _buildStatRow('This Week', '${habit.completedDaysThisWeek}/7 days', Icons.calendar_today),
            if (habit.description != null) ...[
              const SizedBox(height: 16),
              Text('Description', style: PremiumTypography.labelLarge),
              const SizedBox(height: 4),
              Text(habit.description!, style: PremiumTypography.bodyMedium),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: PremiumColors.primary500),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: PremiumTypography.bodyMedium)),
          Text(value, style: PremiumTypography.labelLarge.copyWith(color: PremiumColors.primary500)),
        ],
      ),
    );
  }

  int get _completedCount => _habits.where((h) => h.isDoneToday).length;
  int get _scheduledToday => _habits.where((h) => h.isScheduledForToday()).length;
  int get _longestStreak => _habits.isEmpty ? 0 : _habits.map((h) => h.bestStreak).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    final displayHabits = _filteredHabits;
    
    return Scaffold(
      backgroundColor: PremiumColors.backgroundColor,
      appBar: GradientAppBar(
        title: 'Habits',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Header
                Container(
                  padding: const EdgeInsets.all(PremiumSpacing.screenPadding),
                  decoration: BoxDecoration(
                    color: PremiumColors.surfaceWhite,
                    boxShadow: PremiumShadows.elevationLow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Scheduled', '$_scheduledToday', Icons.event, PremiumColors.primary500)),
                          const SizedBox(width: PremiumSpacing.md),
                          Expanded(child: _buildStatCard('Done', '$_completedCount', Icons.check_circle, PremiumColors.success500)),
                          const SizedBox(width: PremiumSpacing.md),
                          Expanded(child: _buildStatCard('Best', '$_longestStreak', Icons.local_fire_department, PremiumColors.warning500)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text('All'),
                        selected: _filterCategory == null,
                        onSelected: (_) => setState(() => _filterCategory = null),
                      ),
                      const SizedBox(width: 8),
                      ...HabitCategory.values.map((category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getCategoryIcon(category), size: 16),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _getCategoryLabel(category),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          selected: _filterCategory == category,
                          onSelected: (_) => setState(() => _filterCategory = category),
                          selectedColor: _getCategoryColor(category).withOpacity(0.2),
                        ),
                      )),
                    ],
                  ),
                ),
                // Habit List
                Expanded(
                  child: displayHabits.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: displayHabits.length,
                          itemBuilder: (context, index) => _buildHabitCard(displayHabits[index]),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'habits_fab',
        onPressed: () => _addOrEditHabit(),
        backgroundColor: PremiumColors.success500,
        elevation: 6,
        highlightElevation: 10,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Habit', style: PremiumTypography.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(PremiumSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusMedium),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: PremiumSpacing.iconSizeLarge),
          const SizedBox(height: 4),
          Text(value, style: PremiumTypography.headingMedium.copyWith(color: color)),
          Text(label, style: PremiumTypography.labelMedium),
        ],
      ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final isScheduled = habit.isScheduledForToday();
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.96 + (0.04 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: PremiumColors.surfaceWhite,
          borderRadius: BorderRadius.circular(PremiumSpacing.radiusLarge),
          border: Border.all(
            color: habit.isDoneToday ? PremiumColors.success500.withOpacity(0.4) : 
                   !isScheduled ? PremiumColors.gray300.withOpacity(0.5) :
                   PremiumColors.gray300,
            width: habit.isDoneToday ? 2 : 1,
          ),
          boxShadow: !isScheduled ? [] : [
            BoxShadow(
              color: habit.isDoneToday 
                  ? PremiumColors.success500.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isScheduled ? () => _toggleHabit(habit) : null,
            onLongPress: () => _showHabitStats(habit),
            borderRadius: BorderRadius.circular(PremiumSpacing.radiusLarge),
            splashColor: PremiumColors.success500.withOpacity(0.1),
            highlightColor: PremiumColors.success500.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(PremiumSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: habit.isDoneToday ? PremiumColors.success500 : Colors.transparent,
                        border: Border.all(
                          color: habit.isDoneToday ? PremiumColors.success500 : 
                                 !isScheduled ? PremiumColors.gray300.withOpacity(0.5) :
                                 PremiumColors.gray300,
                          width: 2,
                        ),
                        boxShadow: habit.isDoneToday ? [
                          BoxShadow(
                            color: PremiumColors.success500.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ] : null,
                      ),
                      child: habit.isDoneToday
                          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: PremiumTypography.bodyLarge.copyWith(
                              decoration: habit.isDoneToday ? TextDecoration.lineThrough : null,
                              color: !isScheduled ? PremiumColors.gray600 :
                                     habit.isDoneToday ? PremiumColors.gray600 : 
                                     PremiumColors.gray900,
                            ),
                          ),
                          if (!isScheduled)
                            Text('Not scheduled today', style: PremiumTypography.labelMedium.copyWith(color: PremiumColors.gray600)),
                        ],
                      ),
                    ),
                    // Streak
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: PremiumColors.warning500.withOpacity(habit.streak > 0 ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: habit.streak > 0 ? [
                          BoxShadow(
                            color: PremiumColors.warning500.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded, 
                            size: 14, 
                            color: PremiumColors.warning500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.streak}', 
                            style: PremiumTypography.labelMedium.copyWith(
                              color: PremiumColors.warning500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Menu
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert, size: 20),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')],
                          ),
                          onTap: () => Future.delayed(Duration.zero, () => _addOrEditHabit(habit: habit)),
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [Icon(Icons.bar_chart, size: 18), SizedBox(width: 8), Text('Stats')],
                          ),
                          onTap: () => Future.delayed(Duration.zero, () => _showHabitStats(habit)),
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: PremiumColors.error500),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: PremiumColors.error500)),
                            ],
                          ),
                          onTap: () => _deleteHabit(habit),
                        ),
                      ],
                    ),
                  ],
                ),
                // Details
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip(_getCategoryLabel(habit.category), _getCategoryIcon(habit.category), _getCategoryColor(habit.category)),
                    _buildChip(_getFrequencyLabel(habit.frequency), Icons.repeat, PremiumColors.primary500),
                    if (habit.reminderTime != null)
                      _buildChip(habit.reminderTime!, Icons.alarm, PremiumColors.warning500),
                    _buildChip('${(habit.successRate * 100).toStringAsFixed(0)}%', Icons.trending_up, PremiumColors.success500),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 120), // Prevent overflow
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: PremiumTypography.labelMedium.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
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
              color: PremiumColors.success500.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded, size: 64, color: PremiumColors.success500.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text(_filterCategory == null ? 'No habits yet' : 'No habits in this category', style: PremiumTypography.headingLarge),
          const SizedBox(height: 8),
          Text('Build consistency with daily habits', style: PremiumTypography.bodyMedium),
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

  IconData _getCategoryIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.morning: return Icons.wb_sunny;
      case HabitCategory.afternoon: return Icons.wb_cloudy;
      case HabitCategory.evening: return Icons.nightlight_round;
      case HabitCategory.anytime: return Icons.all_inclusive;
      case HabitCategory.health: return Icons.favorite;
      case HabitCategory.productivity: return Icons.trending_up;
      case HabitCategory.personal: return Icons.person;
    }
  }

  Color _getCategoryColor(HabitCategory category) {
    switch (category) {
      case HabitCategory.morning: return PremiumColors.warning500;
      case HabitCategory.afternoon: return PremiumColors.primary500;
      case HabitCategory.evening: return PremiumColors.info500;
      case HabitCategory.anytime: return PremiumColors.gray600;
      case HabitCategory.health: return PremiumColors.error500;
      case HabitCategory.productivity: return PremiumColors.success500;
      case HabitCategory.personal: return PremiumColors.primary500;
    }
  }

  String _getFrequencyLabel(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily: return 'Daily';
      case HabitFrequency.weekdays: return 'Weekdays';
      case HabitFrequency.weekends: return 'Weekends';
      case HabitFrequency.custom: return 'Custom';
    }
  }

  String _getDayLabel(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }
}

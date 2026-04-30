import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/habit_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

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
    final isEdit = habit != null;
    final nameController = TextEditingController(text: habit?.name ?? '');
    final descController = TextEditingController(text: habit?.description ?? '');
    HabitFrequency selectedFrequency = habit?.frequency ?? HabitFrequency.daily;
    HabitCategory selectedCategory = habit?.category ?? HabitCategory.anytime;
    List<int> selectedDays = List.from(habit?.customDays ?? []);
    TimeOfDay? selectedTime = habit?.reminderTime != null 
      ? TimeOfDay(
          hour: int.parse(habit!.reminderTime!.split(':')[0]),
          minute: int.parse(habit.reminderTime!.split(':')[1]),
        )
      : null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Habit' : 'New Habit', style: AppTheme.headingLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                TextField(
                  controller: nameController,
                  autofocus: !isEdit,
                  style: AppTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Habit Name',
                    hintText: 'e.g., Morning meditation',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                TextField(
                  controller: descController,
                  style: AppTheme.bodyMedium,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Why is this habit important?',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Category
                Text('Category', style: AppTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: HabitCategory.values.map((category) {
                    final isSelected = selectedCategory == category;
                    return ChoiceChip(
                      label: Text(_getCategoryLabel(category)),
                      selected: isSelected,
                      onSelected: (_) => setDialogState(() => selectedCategory = category),
                      selectedColor: _getCategoryColor(category).withOpacity(0.2),
                      avatar: isSelected ? Icon(_getCategoryIcon(category), size: 16) : null,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // Frequency
                Text('Frequency', style: AppTheme.labelLarge),
                const SizedBox(height: 8),
                ...HabitFrequency.values.map((freq) => RadioListTile<HabitFrequency>(
                  title: Text(_getFrequencyLabel(freq)),
                  value: freq,
                  groupValue: selectedFrequency,
                  onChanged: (value) => setDialogState(() {
                    selectedFrequency = value!;
                    if (freq != HabitFrequency.custom) selectedDays.clear();
                  }),
                  contentPadding: EdgeInsets.zero,
                )),
                
                // Custom Days
                if (selectedFrequency == HabitFrequency.custom) ...[
                  const SizedBox(height: 8),
                  Text('Select Days', style: AppTheme.labelMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final isSelected = selectedDays.contains(day);
                      return FilterChip(
                        label: Text(_getDayLabel(day)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              selectedDays.add(day);
                            } else {
                              selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 16),
                
                // Reminder Time
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.alarm, color: AppTheme.primaryBlue),
                  title: Text(selectedTime == null 
                    ? 'Set reminder time' 
                    : 'Reminder: ${selectedTime!.format(context)}'),
                  trailing: selectedTime != null 
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20),
                        onPressed: () => setDialogState(() => selectedTime = null),
                      )
                    : null,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setDialogState(() => selectedTime = time);
                    }
                  },
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
                if (nameController.text.isEmpty) return;
                
                final newHabit = Habit(
                  id: habit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  isDoneToday: habit?.isDoneToday ?? false,
                  streak: habit?.streak ?? 0,
                  bestStreak: habit?.bestStreak ?? 0,
                  frequency: selectedFrequency,
                  category: selectedCategory,
                  customDays: selectedDays,
                  reminderTime: selectedTime != null 
                    ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                    : null,
                  completionHistory: habit?.completionHistory ?? {},
                  createdAt: habit?.createdAt,
                  totalCompletions: habit?.totalCompletions ?? 0,
                  linkedHabitIds: habit?.linkedHabitIds ?? [],
                );
                
                _habitRepo.saveHabit(newHabit).then((_) {
                  _loadHabits();
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
        title: Text(habit.name, style: AppTheme.headingLarge),
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
              Text('Description', style: AppTheme.labelLarge),
              const SizedBox(height: 4),
              Text(habit.description!, style: AppTheme.bodyMedium),
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
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTheme.bodyMedium)),
          Text(value, style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryBlue)),
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: GradientAppBar(
        title: 'Habits',
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
                          Expanded(child: _buildStatCard('Scheduled', '$_scheduledToday', Icons.event, AppTheme.primaryBlue)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Done', '$_completedCount', Icons.check_circle, AppTheme.successGreen)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Best', '$_longestStreak', Icons.local_fire_department, AppTheme.warningOrange)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Category Filter
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
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
                              Text(_getCategoryLabel(category)),
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
                const SizedBox(height: 8),
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
        backgroundColor: AppTheme.successGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Habit', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.headingMedium.copyWith(color: color)),
          Text(label, style: AppTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final isScheduled = habit.isScheduledForToday();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: habit.isDoneToday ? AppTheme.successGreen.withOpacity(0.3) : 
                 !isScheduled ? AppTheme.borderGray.withOpacity(0.5) :
                 AppTheme.borderGray,
          width: habit.isDoneToday ? 2 : 1,
        ),
        boxShadow: !isScheduled ? [] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isScheduled ? () => _toggleHabit(habit) : null,
          onLongPress: () => _showHabitStats(habit),
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
                        color: habit.isDoneToday ? AppTheme.successGreen : Colors.transparent,
                        border: Border.all(
                          color: habit.isDoneToday ? AppTheme.successGreen : 
                                 !isScheduled ? AppTheme.borderGray.withOpacity(0.5) :
                                 AppTheme.borderGray,
                          width: 2,
                        ),
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
                            style: AppTheme.bodyLarge.copyWith(
                              decoration: habit.isDoneToday ? TextDecoration.lineThrough : null,
                              color: !isScheduled ? AppTheme.textSecondary :
                                     habit.isDoneToday ? AppTheme.textSecondary : 
                                     AppTheme.textPrimary,
                            ),
                          ),
                          if (!isScheduled)
                            Text('Not scheduled today', style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    // Streak
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.warningOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department_rounded, size: 14, color: AppTheme.warningOrange),
                          const SizedBox(width: 4),
                          Text('${habit.streak}', style: AppTheme.labelMedium.copyWith(color: AppTheme.warningOrange)),
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
                              Icon(Icons.delete, size: 18, color: AppTheme.dangerRed),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: AppTheme.dangerRed)),
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
                    _buildChip(_getFrequencyLabel(habit.frequency), Icons.repeat, AppTheme.primaryBlue),
                    if (habit.reminderTime != null)
                      _buildChip(habit.reminderTime!, Icons.alarm, AppTheme.warningOrange),
                    _buildChip('${(habit.successRate * 100).toStringAsFixed(0)}%', Icons.trending_up, AppTheme.successGreen),
                  ],
                ),
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
              color: AppTheme.successGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded, size: 64, color: AppTheme.successGreen.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text(_filterCategory == null ? 'No habits yet' : 'No habits in this category', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text('Build consistency with daily habits', style: AppTheme.bodyMedium),
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
      case HabitCategory.morning: return AppTheme.warningOrange;
      case HabitCategory.afternoon: return AppTheme.primaryBlue;
      case HabitCategory.evening: return AppTheme.infoBlue;
      case HabitCategory.anytime: return AppTheme.textSecondary;
      case HabitCategory.health: return AppTheme.dangerRed;
      case HabitCategory.productivity: return AppTheme.successGreen;
      case HabitCategory.personal: return AppTheme.primaryBlue;
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

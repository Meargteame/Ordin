import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import 'modern_form_screen.dart';
import 'modern_form_field.dart';

class HabitFormScreen extends StatefulWidget {
  final Habit? habit;
  final Function(Habit) onSave;
  final VoidCallback? onDelete;

  const HabitFormScreen({
    super.key,
    this.habit,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  HabitFrequency _frequency = HabitFrequency.daily;
  HabitCategory _category = HabitCategory.anytime;
  List<int> _customDays = [];
  DateTime? _reminderTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
    _descController = TextEditingController(text: widget.habit?.description ?? '');
    _frequency = widget.habit?.frequency ?? HabitFrequency.daily;
    _category = widget.habit?.category ?? HabitCategory.anytime;
    _customDays = List.from(widget.habit?.customDays ?? []);
    
    if (widget.habit?.reminderTime != null) {
      final parts = widget.habit!.reminderTime!.split(':');
      final now = DateTime.now();
      _reminderTime = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  void _save() {
    if (!_isValid) return;

    final habit = Habit(
      id: widget.habit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      isDoneToday: widget.habit?.isDoneToday ?? false,
      streak: widget.habit?.streak ?? 0,
      bestStreak: widget.habit?.bestStreak ?? 0,
      frequency: _frequency,
      category: _category,
      customDays: _customDays,
      reminderTime: _reminderTime != null
          ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
          : null,
      completionHistory: widget.habit?.completionHistory ?? {},
      createdAt: widget.habit?.createdAt,
      totalCompletions: widget.habit?.totalCompletions ?? 0,
      linkedHabitIds: widget.habit?.linkedHabitIds ?? [],
    );

    widget.onSave(habit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ModernFormScreen(
      title: widget.habit == null ? 'New Habit' : 'Edit Habit',
      icon: Icons.auto_awesome_rounded,
      accentColor: AppTheme.successGreen,
      saveLabel: widget.habit == null ? 'Create Habit' : 'Save Changes',
      isValid: _isValid,
      onSave: _save,
      onDelete: widget.onDelete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          ModernFormField(
            label: 'Habit Name',
            hint: 'e.g., Morning meditation, Drink water',
            icon: Icons.star_rounded,
            controller: _nameController,
            autofocus: widget.habit == null,
          ),
          const SizedBox(height: 24),

          // Description
          ModernFormField(
            label: 'Why is this important?',
            hint: 'Your motivation for building this habit...',
            icon: Icons.lightbulb_rounded,
            controller: _descController,
            maxLines: 3,
          ),
          const SizedBox(height: 32),

          // Category Section
          FormSection(
            title: 'Category',
            icon: Icons.category_rounded,
            child: ModernChoiceSelector<HabitCategory>(
              label: 'When do you want to do this?',
              options: HabitCategory.values,
              selected: _category,
              onSelected: (value) => setState(() => _category = value),
              getLabel: _getCategoryLabel,
              getIcon: _getCategoryIcon,
              getColor: _getCategoryColor,
              wrap: true,
            ),
          ),
          const SizedBox(height: 32),

          // Frequency Section
          FormSection(
            title: 'Frequency',
            icon: Icons.repeat_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernChoiceSelector<HabitFrequency>(
                  label: 'How often?',
                  options: HabitFrequency.values,
                  selected: _frequency,
                  onSelected: (value) => setState(() {
                    _frequency = value;
                    if (value != HabitFrequency.custom) _customDays.clear();
                  }),
                  getLabel: _getFrequencyLabel,
                  getIcon: _getFrequencyIcon,
                  getColor: (_) => AppTheme.primaryBlue,
                  wrap: true,
                ),
                
                // Custom Days Selector
                if (_frequency == HabitFrequency.custom) ...[
                  const SizedBox(height: 20),
                  Text('Select Days', style: AppTheme.labelLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final isSelected = _customDays.contains(day);
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _customDays.remove(day);
                              } else {
                                _customDays.add(day);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppTheme.primaryBlue.withOpacity(0.15)
                                  : AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? AppTheme.primaryBlue
                                    : AppTheme.borderGray,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _getDayLabel(day),
                                style: AppTheme.labelLarge.copyWith(
                                  color: isSelected 
                                      ? AppTheme.primaryBlue
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Reminder Section
          FormSection(
            title: 'Reminder',
            icon: Icons.notifications_rounded,
            child: ModernDateTimePicker(
              label: 'Reminder Time',
              icon: Icons.alarm_rounded,
              value: _reminderTime,
              onChanged: (value) => setState(() => _reminderTime = value),
              isTime: true,
            ),
          ),
          const SizedBox(height: 32),

          // Gamification Info
          if (widget.habit != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.warningOrange.withOpacity(0.1),
                    AppTheme.successGreen.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.warningOrange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warningOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.local_fire_department_rounded, 
                      color: AppTheme.warningOrange, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Streak', style: AppTheme.labelMedium),
                        Text('${widget.habit!.streak} days', 
                          style: AppTheme.headingLarge.copyWith(
                            color: AppTheme.warningOrange)),
                        Text('Best: ${widget.habit!.bestStreak} days', 
                          style: AppTheme.labelMedium),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_rounded, 
                          color: AppTheme.successGreen, size: 24),
                        const SizedBox(height: 4),
                        Text('${widget.habit!.totalCompletions}',
                          style: AppTheme.labelLarge.copyWith(
                            color: AppTheme.successGreen)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
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
      case HabitCategory.morning: return Icons.wb_sunny_rounded;
      case HabitCategory.afternoon: return Icons.wb_cloudy_rounded;
      case HabitCategory.evening: return Icons.nightlight_round;
      case HabitCategory.anytime: return Icons.all_inclusive_rounded;
      case HabitCategory.health: return Icons.favorite_rounded;
      case HabitCategory.productivity: return Icons.trending_up_rounded;
      case HabitCategory.personal: return Icons.person_rounded;
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

  IconData _getFrequencyIcon(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily: return Icons.today_rounded;
      case HabitFrequency.weekdays: return Icons.work_rounded;
      case HabitFrequency.weekends: return Icons.weekend_rounded;
      case HabitFrequency.custom: return Icons.tune_rounded;
    }
  }

  String _getDayLabel(int day) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[day - 1];
  }
}

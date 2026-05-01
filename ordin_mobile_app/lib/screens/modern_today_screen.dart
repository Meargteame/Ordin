import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../data/task_repository.dart';
import '../data/habit_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/modern_dark_colors.dart';
import '../theme/modern_dark_typography.dart';
import '../theme/modern_dark_spacing.dart';
import '../widgets/modern/avatar_group.dart';
import '../widgets/modern/pill_tag.dart';
import '../widgets/modern/productivity_grid.dart';

import '../widgets/modern/stripe_pattern.dart';

class ModernTodayScreen extends StatefulWidget {
  const ModernTodayScreen({super.key});

  @override
  State<ModernTodayScreen> createState() => _ModernTodayScreenState();
}

class _ModernTodayScreenState extends State<ModernTodayScreen> {
  late TaskRepository _taskRepo;
  late HabitRepository _habitRepo;
  List<Task> _todayTasks = [];
  List<Habit> _habits = [];
  bool _isLoading = true;
  String _userName = 'Tisha';

  @override
  void initState() {
    super.initState();
    _initRepos();
  }

  Future<void> _initRepos() async {
    final storage = HiveStorageService();
    await storage.init();
    
    _taskRepo = TaskRepository(storage);
    _habitRepo = HabitRepository(storage);
    
    await _habitRepo.performDailyReset();
    await _loadData();
  }

  Future<void> _loadData() async {
    final tasks = await _taskRepo.getTasksForDate(DateTime.now());
    final habits = await _habitRepo.loadHabits();
    
    setState(() {
      _todayTasks = tasks.where((t) => !t.isDone).take(3).toList();
      _habits = habits;
      _isLoading = false;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  int get _remainingTasksCount => _todayTasks.length;

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

    return Scaffold(
      backgroundColor: ModernDarkColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ModernDarkSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: ModernDarkSpacing.xl),
              _buildTeamProductivityCard(),
              const SizedBox(height: ModernDarkSpacing.xxl),
              _buildTasksSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()},',
              style: ModernDarkTypography.greeting,
            ),
            Text(
              '$_userName!',
              style: ModernDarkTypography.greeting,
            ),
          ],
        ),
        // Avatar
        Container(
          width: ModernDarkSpacing.avatarLg,
          height: ModernDarkSpacing.avatarLg,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ModernDarkColors.cardElevated,
            border: Border.all(
              color: ModernDarkColors.limeAccent,
              width: 2.0,
            ),
          ),
          child: const Icon(
            Icons.person,
            color: ModernDarkColors.textSecondary,
            size: 24.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamProductivityCard() {
    // Generate sample grid data
    final gridStates = List.generate(35, (index) {
      if (index % 3 == 0) return GridCellState.filled;
      if (index % 5 == 0) return GridCellState.striped;
      return GridCellState.empty;
    });

    return Container(
      padding: const EdgeInsets.all(ModernDarkSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: ModernDarkColors.limeAccent,
        borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team',
                    style: ModernDarkTypography.labelMedium.copyWith(
                      color: ModernDarkColors.textOnLime.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Productivity',
                    style: ModernDarkTypography.headingMedium.copyWith(
                      color: ModernDarkColors.textOnLime,
                    ),
                  ),
                ],
              ),
              // Month selector
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusXs),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: ModernDarkTypography.labelMedium.copyWith(
                        color: ModernDarkColors.textOnLime,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16.0,
                      color: ModernDarkColors.textOnLime,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernDarkSpacing.lg),
          ProductivityGrid(
            rows: 5,
            columns: 7,
            cellStates: gridStates,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_remainingTasksCount More Tasks',
          style: ModernDarkTypography.headingMedium,
        ),
        const SizedBox(height: 4.0),
        Text(
          'to complete today:',
          style: ModernDarkTypography.bodySmall,
        ),
        const SizedBox(height: ModernDarkSpacing.lg),
        ..._todayTasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    // Determine card style based on task properties
    final bool isTeamMeeting = task.tags.contains('team');
    final Color cardColor = isTeamMeeting 
        ? ModernDarkColors.purpleLight.withOpacity(0.15)
        : ModernDarkColors.cardElevated;
    final bool hasPattern = isTeamMeeting;

    return Container(
      margin: const EdgeInsets.only(bottom: ModernDarkSpacing.md),
      height: ModernDarkSpacing.taskCardHeight,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusMd),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusMd),
        child: Stack(
          children: [
            // Pattern overlay if needed
            if (hasPattern)
              Positioned.fill(
                child: StripePattern(
                  stripeColor: ModernDarkColors.purple.withOpacity(0.1),
                  stripeWidth: 1.5,
                  stripeSpacing: 6.0,
                  angle: 45.0,
                  child: Container(),
                ),
              ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(ModernDarkSpacing.cardPadding),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          task.title,
                          style: ModernDarkTypography.taskTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            Text(
                              _formatTaskTime(task),
                              style: ModernDarkTypography.taskTime,
                            ),
                            if (task.estimatedMinutes != null) ...[
                              Text(
                                ' • ${task.estimatedMinutes} min',
                                style: ModernDarkTypography.taskTime,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: ModernDarkSpacing.md),
                  // Tag and avatars
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isTeamMeeting)
                        PillTag.teamMeeting('Team meeting'),
                      const SizedBox(height: 8.0),
                      AvatarGroup(
                        avatarUrls: const ['', '', '', ''],
                        maxVisible: 4,
                        size: ModernDarkSpacing.avatarSm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTaskTime(Task task) {
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, 9, 0); // Default 9 AM
    final endTime = startTime.add(Duration(minutes: task.estimatedMinutes ?? 60));
    
    return '${DateFormat('h a').format(startTime)} - ${DateFormat('h a').format(endTime)}';
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/habit.dart';
import '../models/goal.dart';
import '../models/project.dart';
import '../data/task_repository.dart';
import '../data/habit_repository.dart';
import '../data/goal_repository.dart';
import '../data/project_repository.dart';
import '../data/time_tracking_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/premium_colors.dart';
import '../theme/premium_typography.dart';
import '../theme/premium_spacing.dart';
import '../theme/premium_shadows.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with SingleTickerProviderStateMixin {
  late TaskRepository _taskRepo;
  late HabitRepository _habitRepo;
  late GoalRepository _goalRepo;
  late ProjectRepository _projectRepo;
  late TimeTrackingRepository _timeRepo;
  List<Task> _todayTasks = [];
  List<Habit> _habits = [];
  List<Goal> _activeGoals = [];
  List<Project> _projects = [];
  int _todayMinutes = 0;
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _initRepos();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initRepos() async {
    final storage = HiveStorageService();
    await storage.init();
    
    _taskRepo = TaskRepository(storage);
    _habitRepo = HabitRepository(storage);
    _goalRepo = GoalRepository();
    await _goalRepo.init(storage);
    _projectRepo = ProjectRepository();
    await _projectRepo.init(storage);
    _timeRepo = TimeTrackingRepository();
    await _timeRepo.init(storage);
    
    await _habitRepo.performDailyReset();
    await _loadData();
    _animationController.forward();
  }

  Future<void> _loadData() async {
    final tasks = await _taskRepo.getTasksForDate(DateTime.now());
    final habits = await _habitRepo.loadHabits();
    final goals = await _goalRepo.getActiveGoals();
    final projects = await _projectRepo.loadProjects();
    final minutes = await _timeRepo.getTotalMinutesForDate(DateTime.now());
    
    setState(() {
      _todayTasks = tasks;
      _habits = habits;
      _activeGoals = goals;
      _projects = projects;
      _todayMinutes = minutes;
      _isLoading = false;
    });
  }

  Future<void> _toggleTask(Task task) async {
    task.isDone = !task.isDone;
    await _taskRepo.saveTask(task);
    setState(() {});
  }

  Future<void> _toggleHabit(Habit habit) async {
    habit.toggle(DateTime.now());
    await _habitRepo.saveHabit(habit);
    setState(() {});
  }

  int get _completedTasks => _todayTasks.where((t) => t.isDone).length;
  int get _completedHabits => _habits.where((h) => h.isDoneToday).length;
  int get _totalItems => _todayTasks.length + _habits.length;
  int get _completedItems => _completedTasks + _completedHabits;
  double get _completionRate => _totalItems == 0 ? 0 : _completedItems / _totalItems;
  int get _longestStreak => _habits.isEmpty ? 0 : _habits.map((h) => h.streak).reduce(math.max);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getMotivation() {
    if (_completionRate >= 0.8) return 'Outstanding progress!';
    if (_completionRate >= 0.5) return 'Keep the momentum going!';
    if (_completionRate > 0) return 'You\'re making progress!';
    return 'Let\'s make today count!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF6366F1),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildPremiumHeader(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDailyOverview(),
                          const SizedBox(height: 24),
                          if (_todayTasks.isNotEmpty) ...[
                            _buildTasksSection(),
                            const SizedBox(height: 24),
                          ],
                          if (_habits.isNotEmpty) ...[
                            _buildHabitsSection(),
                            const SizedBox(height: 24),
                          ],
                          if (_todayTasks.isEmpty && _habits.isEmpty) 
                            _buildPremiumEmptyState(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDarkHeader() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF0A0A0A),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('EEEE, MMMM d').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCompactProgress(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD4FF00).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4FF00).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '${(_completionRate * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFFD4FF00),
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Done',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInsight() {
    String insight = _getMotivation();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4FF00).withOpacity(0.15),
            const Color(0xFFD4FF00).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4FF00).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD4FF00),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bolt,
              color: Color(0xFF0A0A0A),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_completedItems of $_totalItems completed',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Tasks',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            Text(
              '$_completedTasks/${_todayTasks.length}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._todayTasks.map((task) => _buildModernTaskCard(task)),
      ],
    );
  }

  Widget _buildModernTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isDone 
              ? const Color(0xFF10B981) 
              : Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleTask(task),
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFFD4FF00).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isDone ? const Color(0xFF10B981) : Colors.transparent,
                    border: Border.all(
                      color: task.isDone 
                          ? const Color(0xFF10B981) 
                          : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: task.isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                      color: task.isDone 
                          ? Colors.white.withOpacity(0.3) 
                          : Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
                if (task.estimatedMinutes != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4FF00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${task.estimatedMinutes}m',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD4FF00),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Habits',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            Text(
              '$_completedHabits/${_habits.length}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._habits.map((habit) => _buildModernHabitCard(habit)),
      ],
    );
  }

  Widget _buildModernHabitCard(Habit habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: habit.isDoneToday 
              ? const Color(0xFF10B981) 
              : Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleHabit(habit),
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFFD4FF00).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: habit.isDoneToday ? const Color(0xFF10B981) : Colors.transparent,
                    border: Border.all(
                      color: habit.isDoneToday 
                          ? const Color(0xFF10B981) 
                          : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: habit.isDoneToday
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: habit.isDoneToday ? TextDecoration.lineThrough : null,
                      color: habit.isDoneToday 
                          ? Colors.white.withOpacity(0.3) 
                          : Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
                if (habit.streak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.streak}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZenEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD4FF00).withOpacity(0.2),
                    const Color(0xFFD4FF00).withOpacity(0.05),
                  ],
                ),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 56,
                color: Color(0xFFD4FF00),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'All Clear',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ready to conquer the day',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return SliverAppBar(
      expandedHeight: 170,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: PremiumColors.primary500,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PremiumColors.primary500,
                PremiumColors.primary400,
                PremiumColors.primary500.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 15, 28, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.8,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMMM d').format(DateTime.now()),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildCompactProgressRing(),
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

  Widget _buildCompactProgressRing() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(70, 70),
            painter: _ProgressRingPainter(_completionRate, 6),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(_completionRate * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeProgressRing() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(110, 110),
            painter: _ProgressRingPainter(_completionRate, 10),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(_completionRate * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'Complete',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeControlPanel() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [PremiumColors.primary500, PremiumColors.primary400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Life Control Center',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PremiumColors.gray900,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCompactMetric(
                  'Goals',
                  '${_activeGoals.length}',
                  Icons.flag_rounded,
                  PremiumColors.primary500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactMetric(
                  'Projects',
                  '${_projects.length}',
                  Icons.folder_rounded,
                  PremiumColors.success500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactMetric(
                  'Time',
                  '${(_todayMinutes / 60).toStringAsFixed(1)}h',
                  Icons.timer_rounded,
                  PremiumColors.warning500,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildCompactMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: PremiumColors.gray600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tasks',
            '$_completedTasks/${_todayTasks.length}',
            Icons.check_circle_rounded,
            PremiumColors.primary500,
            _todayTasks.isEmpty ? 0 : _completedTasks / _todayTasks.length,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _buildStatCard(
            'Habits',
            '$_completedHabits/${_habits.length}',
            Icons.auto_awesome_rounded,
            PremiumColors.success500,
            _habits.isEmpty ? 0 : _completedHabits / _habits.length,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _buildStatCard(
            'Streak',
            '$_longestStreak',
            Icons.local_fire_department_rounded,
            PremiumColors.warning500,
            1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, double progress) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animValue)),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: PremiumColors.gray900,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: PremiumColors.gray600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0.0, end: progress),
              builder: (context, value, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int completed, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: PremiumColors.gray900,
            letterSpacing: -0.8,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [PremiumColors.primary500.withOpacity(0.15), PremiumColors.primary500.withOpacity(0.08)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            '$completed/$total',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: PremiumColors.primary500,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumTaskCard(Task task) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: task.isDone 
                  ? PremiumColors.success500.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: -2,
            ),
          ],
          border: task.isDone 
              ? Border.all(color: PremiumColors.success500.withOpacity(0.4), width: 2)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleTask(task),
            borderRadius: BorderRadius.circular(24),
            splashColor: PremiumColors.primary500.withOpacity(0.1),
            highlightColor: PremiumColors.primary500.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: task.isDone
                          ? LinearGradient(
                              colors: [PremiumColors.primary500, PremiumColors.primary400],
                            )
                          : null,
                      border: task.isDone
                          ? null
                          : Border.all(color: PremiumColors.gray600.withOpacity(0.3), width: 3),
                      boxShadow: task.isDone ? [
                        BoxShadow(
                          color: PremiumColors.primary500.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ] : null,
                    ),
                    child: task.isDone
                        ? const Icon(Icons.check_rounded, size: 22, color: Colors.white)
                        : null,
                  ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          decoration: task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone ? PremiumColors.gray600 : PremiumColors.gray900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          task.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: PremiumColors.gray600.withOpacity(0.8),
                            letterSpacing: 0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (task.estimatedMinutes != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [PremiumColors.primary500.withOpacity(0.15), PremiumColors.primary500.withOpacity(0.08)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: PremiumColors.primary500),
                        const SizedBox(width: 6),
                        Text(
                          '${task.estimatedMinutes}m',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: PremiumColors.primary500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildPremiumHabitCard(Habit habit) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: habit.isDoneToday 
                  ? PremiumColors.success500.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: -2,
            ),
          ],
          border: habit.isDoneToday 
              ? Border.all(color: PremiumColors.success500.withOpacity(0.4), width: 2)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleHabit(habit),
            borderRadius: BorderRadius.circular(24),
            splashColor: PremiumColors.success500.withOpacity(0.1),
            highlightColor: PremiumColors.success500.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: habit.isDoneToday
                          ? const LinearGradient(
                              colors: [PremiumColors.success500, Color(0xFF27AE60)],
                            )
                          : null,
                      border: habit.isDoneToday
                          ? null
                          : Border.all(color: PremiumColors.gray600.withOpacity(0.3), width: 3),
                      boxShadow: habit.isDoneToday ? [
                        BoxShadow(
                          color: PremiumColors.success500.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ] : null,
                    ),
                    child: habit.isDoneToday
                        ? const Icon(Icons.check_rounded, size: 22, color: Colors.white)
                        : null,
                  ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      decoration: habit.isDoneToday ? TextDecoration.lineThrough : null,
                      color: habit.isDoneToday ? PremiumColors.gray600 : PremiumColors.gray900,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PremiumColors.warning500.withOpacity(0.2),
                        PremiumColors.warning500.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 20, color: PremiumColors.warning500),
                      const SizedBox(width: 8),
                      Text(
                        '${habit.streak}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: PremiumColors.warning500,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    PremiumColors.primary500.withOpacity(0.1),
                    PremiumColors.primary400.withOpacity(0.1),
                  ],
                ),
              ),
              child: Icon(
                Icons.wb_sunny_rounded,
                size: 80,
                color: PremiumColors.primary500.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Perfect Day Ahead',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: PremiumColors.gray900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start by adding your first task or habit',
              style: TextStyle(
                fontSize: 16,
                color: PremiumColors.gray600.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: PremiumColors.gray900,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Add Task',
                Icons.add_task_rounded,
                PremiumColors.primary500,
                () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Add Habit',
                Icons.auto_awesome_rounded,
                PremiumColors.success500,
                () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Start Timer',
                Icons.timer_rounded,
                PremiumColors.warning500,
                () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'View Analytics',
                Icons.insights_rounded,
                PremiumColors.primary500,
                () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _ProgressRingPainter(this.progress, [this.strokeWidth = 6]);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white, Colors.white.withOpacity(0.8)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    final progressAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      progressAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

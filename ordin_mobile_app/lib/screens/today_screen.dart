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

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
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
    _goalRepo = GoalRepository();
    await _goalRepo.init(storage);
    _projectRepo = ProjectRepository();
    await _projectRepo.init(storage);
    _timeRepo = TimeTrackingRepository();
    await _timeRepo.init(storage);
    
    await _habitRepo.performDailyReset();
    await _loadData();
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
              color: const Color(0xFF0EA5E9),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildPremiumHeader(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuickStats(),
                          const SizedBox(height: 24),
                          _buildLifeAreasGrid(),
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

  Widget _buildPremiumHeader() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0EA5E9),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0EA5E9), // Sky Blue
                Color(0xFF0284C7), // Deep Sky Blue
                Color(0xFF06B6D4), // Cyan
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMMM d').format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildProgressRing(),
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

  Widget _buildProgressRing() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(60, 60),
            painter: _CircularProgressPainter(_completionRate),
          ),
          Center(
            child: Text(
              '${(_completionRate * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
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
            Icons.check_circle_outline,
            const Color(0xFF0EA5E9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Habits',
            '$_completedHabits/${_habits.length}',
            Icons.auto_awesome_outlined,
            const Color(0xFF06B6D4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Streak',
            '$_longestStreak🔥',
            Icons.local_fire_department_outlined,
            const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifeAreasGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Life Areas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildLifeAreaCard('Goals', Icons.flag_outlined, const Color(0xFF0EA5E9)),
            _buildLifeAreaCard('Projects', Icons.folder_outlined, const Color(0xFF06B6D4)),
            _buildLifeAreaCard('Time', Icons.timer_outlined, const Color(0xFFF59E0B)),
            _buildLifeAreaCard('Calendar', Icons.calendar_today_outlined, const Color(0xFF10B981)),
            _buildLifeAreaCard('Notes', Icons.note_outlined, const Color(0xFF8B5CF6)),
            _buildLifeAreaCard('Journal', Icons.book_outlined, const Color(0xFF06B6D4)),
            _buildLifeAreaCard('Health', Icons.favorite_outline, const Color(0xFFEF4444)),
            _buildLifeAreaCard('Finance', Icons.account_balance_wallet_outlined, const Color(0xFF10B981)),
            _buildLifeAreaCard('People', Icons.people_outline, const Color(0xFFF59E0B)),
            _buildLifeAreaCard('Learning', Icons.school_outlined, const Color(0xFF8B5CF6)),
            _buildLifeAreaCard('Analytics', Icons.insights_outlined, const Color(0xFF0EA5E9)),
            _buildLifeAreaCard('Settings', Icons.settings_outlined, const Color(0xFF64748B)),
          ],
        ),
      ],
    );
  }

  Widget _buildLifeAreaCard(String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to respective screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label - Coming soon'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withOpacity(0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0EA5E9).withOpacity(0.08),
            const Color(0xFF06B6D4).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0EA5E9).withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0EA5E9).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMotivation(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_completedItems of $_totalItems completed today',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
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
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Tasks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.8,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_completedTasks/${_todayTasks.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0EA5E9),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._todayTasks.map((task) => _buildPremiumTaskCard(task)),
      ],
    );
  }

  Widget _buildPremiumTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isDone 
              ? const Color(0xFF10B981) 
              : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: task.isDone
                ? const Color(0xFF10B981).withOpacity(0.1)
                : Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleTask(task),
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFF0EA5E9).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: task.isDone
                        ? const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          )
                        : null,
                    border: Border.all(
                      color: task.isDone 
                          ? Colors.transparent 
                          : const Color(0xFFCBD5E1),
                      width: 2.5,
                    ),
                    boxShadow: task.isDone ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ] : null,
                  ),
                  child: task.isDone
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: task.isDone ? TextDecoration.lineThrough : null,
                          decorationThickness: 2,
                          color: task.isDone 
                              ? const Color(0xFF94A3B8) 
                              : const Color(0xFF0F172A),
                          height: 1.4,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            height: 1.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (task.estimatedMinutes != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0EA5E9).withOpacity(0.1),
                          const Color(0xFF06B6D4).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF0EA5E9).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: Color(0xFF0EA5E9),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task.estimatedMinutes}m',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0EA5E9),
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
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF38BDF8), Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Habits',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.8,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_completedHabits/${_habits.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF06B6D4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._habits.map((habit) => _buildPremiumHabitCard(habit)),
      ],
    );
  }

  Widget _buildPremiumHabitCard(Habit habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: habit.isDoneToday 
              ? const Color(0xFF10B981) 
              : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: habit.isDoneToday
                ? const Color(0xFF10B981).withOpacity(0.1)
                : Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleHabit(habit),
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFF06B6D4).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: habit.isDoneToday
                        ? const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          )
                        : null,
                    border: Border.all(
                      color: habit.isDoneToday 
                          ? Colors.transparent 
                          : const Color(0xFFCBD5E1),
                      width: 2.5,
                    ),
                    boxShadow: habit.isDoneToday ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ] : null,
                  ),
                  child: habit.isDoneToday
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: habit.isDoneToday ? TextDecoration.lineThrough : null,
                      decorationThickness: 2,
                      color: habit.isDoneToday 
                          ? const Color(0xFF94A3B8) 
                          : const Color(0xFF0F172A),
                      height: 1.4,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (habit.streak > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${habit.streak}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
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
    );
  }

  Widget _buildPremiumEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0EA5E9).withOpacity(0.1),
                    const Color(0xFF06B6D4).withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF0EA5E9).withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: Color(0xFF0EA5E9),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'All Clear',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ready to conquer the day',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for circular progress
class _CircularProgressPainter extends CustomPainter {
  final double progress;

  _CircularProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Remove mesh gradient painter - not needed anymore

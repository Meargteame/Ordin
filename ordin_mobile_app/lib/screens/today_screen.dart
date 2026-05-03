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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF2563EB),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDailySummary(),
                          const SizedBox(height: 24),
                          _buildStatsCards(),
                          const SizedBox(height: 24),
                          _buildCircularProgress(),
                          const SizedBox(height: 24),
                          _buildLifeAreasSection(),
                          const SizedBox(height: 24),
                          _buildTodaysFocus(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFFF8F9FA),
      elevation: 0,
      toolbarHeight: 70,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
            child: const Icon(Icons.person, color: Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Good morning, Alex',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF6B7280)),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF6B7280)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildDailySummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your daily summary',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'TASKS',
            '$_completedTasks / ${_todayTasks.length}',
            Icons.check_circle_outline,
            const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'HABITS',
            '$_completedHabits / ${_habits.length}',
            Icons.refresh,
            const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'STREAK',
            '$_longestStreak Days',
            Icons.local_fire_department_outlined,
            const Color(0xFFEF4444),
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress() {
    return Center(
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(160, 160),
              painter: _CircularProgressPainter(_completionRate),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(_completionRate * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const Text(
                    'COMPLETED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.5,
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

  Widget _buildLifeAreasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Life Areas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3,
          children: [
            _buildLifeAreaItem('Goals', Icons.flag_outlined, const Color(0xFF8B5CF6)),
            _buildLifeAreaItem('Projects', Icons.folder_outlined, const Color(0xFFEC4899)),
            _buildLifeAreaItem('Finance', Icons.attach_money, const Color(0xFF10B981)),
            _buildLifeAreaItem('Health', Icons.favorite_outline, const Color(0xFFEF4444)),
            _buildLifeAreaItem('Journal', Icons.book_outlined, const Color(0xFFF59E0B)),
            _buildLifeAreaItem('Notes', Icons.note_outlined, const Color(0xFF6B7280)),
            _buildLifeAreaItem('Learning', Icons.school_outlined, const Color(0xFF3B82F6)),
            _buildLifeAreaItem('Relationships', Icons.people_outline, const Color(0xFFEC4899)),
          ],
        ),
      ],
    );
  }

  Widget _buildLifeAreaItem(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysFocus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Focus',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            Text(
              '${_todayTasks.length} TASKS REMAINING',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_todayTasks.isEmpty)
          _buildEmptyState()
        else
          ..._todayTasks.take(5).map((task) => _buildTaskCard(task)),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isDone ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleTask(task),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isDone ? const Color(0xFF2563EB) : Colors.transparent,
                border: Border.all(
                  color: task.isDone ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: task.isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: task.isDone ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937),
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (task.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: task.tags.take(2).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          if (task.estimatedMinutes != null) ...[
            const SizedBox(width: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(
                  '${task.estimatedMinutes}m',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'All tasks completed!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Great job! You\'re all caught up.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;

  _CircularProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 6, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
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

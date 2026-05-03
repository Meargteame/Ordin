import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/habit.dart';
import '../data/habit_repository.dart';
import '../data/hive_storage_service.dart';
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

  Future<void> _toggleHabit(Habit habit) async {
    habit.toggle(DateTime.now());
    await _habitRepo.saveHabit(habit);
    setState(() {});
  }

  Future<void> _deleteHabit(Habit habit) async {
    await _habitRepo.deleteHabit(habit.id);
    await _loadHabits();
  }

  void _openHabitForm([Habit? habit]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitFormScreen(
          habit: habit,
          onSave: (newHabit) async {
            await _habitRepo.saveHabit(newHabit);
            await _loadHabits();
          },
          onDelete: habit != null
              ? () async {
                  await _deleteHabit(habit);
                  if (context.mounted) Navigator.pop(context);
                }
              : null,
        ),
      ),
    );
  }

  int get _currentStreak {
    if (_habits.isEmpty) return 0;
    return _habits.map((h) => h.streak).reduce(math.max);
  }

  int get _completedToday => _habits.where((h) => h.isDoneToday).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWeeklyConsistency(),
                        const SizedBox(height: 24),
                        _buildTotalCompleted(),
                        const SizedBox(height: 24),
                        _buildPrimaryFocus(),
                        const SizedBox(height: 24),
                        _buildDailyHabitsSection(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openHabitForm(),
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.add, color: Colors.white),
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

  Widget _buildWeeklyConsistency() {
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Consistency',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Current Streak: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    '$_currentStreak',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Days',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((date) {
              final isToday = date.day == now.day && date.month == now.month;
              final hasCompletions = _habits.any((h) {
                final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                return h.completionHistory[dateKey] == true;
              });
              
              return Column(
                children: [
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasCompletions
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                      border: Border.all(
                        color: isToday
                            ? const Color(0xFF2563EB)
                            : (hasCompletions ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB)),
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: hasCompletions
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCompleted() {
    final totalCompletions = _habits.fold<int>(0, (sum, h) => sum + h.totalCompletions);
    
    return Container(
      padding: const EdgeInsets.all(20),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bar_chart, color: Color(0xFF2563EB), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL COMPLETED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$totalCompletions',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'this month',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryFocus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'PRIMARY FOCUS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.rocket_launch, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Deep Work Routine',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Maintain at least 4 hours of focused, distraction-free work every weekday morning.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Monthly Goal Progress',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              const Text(
                '82%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.82,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyHabitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Habits',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_habits.isEmpty)
          _buildEmptyState()
        else
          ..._habits.map((habit) => _buildHabitCard(habit)),
      ],
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final progress = habit.isDoneToday ? 1.0 : 0.0;
    final categoryColor = _getCategoryColor(habit.category);
    
    return GestureDetector(
      onTap: () => _openHabitForm(habit),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _toggleHabit(habit),
              child: SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(50, 50),
                      painter: _HabitProgressPainter(progress, categoryColor),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getCategoryLabel(habit.category).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: categoryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (habit.streak > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department, size: 12, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 2),
                              Text(
                                '${habit.streak}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Text(
                                'Streak',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    habit.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  if (habit.description != null && habit.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      habit.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
              onPressed: () => _toggleHabit(habit),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(HabitCategory category) {
    switch (category) {
      case HabitCategory.morning:
        return const Color(0xFFF59E0B);
      case HabitCategory.afternoon:
        return const Color(0xFF3B82F6);
      case HabitCategory.evening:
        return const Color(0xFF8B5CF6);
      case HabitCategory.health:
        return const Color(0xFFEF4444);
      case HabitCategory.productivity:
        return const Color(0xFF10B981);
      case HabitCategory.personal:
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getCategoryLabel(HabitCategory category) {
    switch (category) {
      case HabitCategory.morning:
        return 'Mindset';
      case HabitCategory.afternoon:
        return 'Afternoon';
      case HabitCategory.evening:
        return 'Evening';
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.personal:
        return 'Personal';
      default:
        return 'Anytime';
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
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
              Icons.auto_awesome,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No habits yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first habit to start building consistency',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _HabitProgressPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius - 2, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 2),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_HabitProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

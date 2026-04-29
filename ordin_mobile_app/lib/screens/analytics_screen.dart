import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/analytics_engine.dart';
import '../data/hive_storage_service.dart';
import '../data/task_repository.dart';
import '../data/habit_repository.dart';
import '../data/goal_repository.dart';
import '../data/time_tracking_repository.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late AnalyticsEngine _analytics;
  late HiveStorageService _storage;
  double _todayScore = 0.0;
  Map<int, double> _weekTrend = {};
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _activeGoals = 0;
  int _totalTimeMinutes = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnalytics();
  }

  Future<void> _initializeAnalytics() async {
    _storage = HiveStorageService();
    await _storage.init();
    
    _analytics = AnalyticsEngine();
    await _analytics.init(_storage);
    
    await _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 7));
    
    final todayScore = await _analytics.calculateProductivityScore(today);
    final weekTrend = await _analytics.getProductivityTrend(weekAgo, today);
    
    final tasks = await TaskRepository(_storage).loadTasks();
    final goals = await GoalRepository(_storage).getActiveGoals();
    final timeEntries = await TimeTrackingRepository(_storage).getEntriesForDateRange(weekAgo, today);
    
    final totalTime = timeEntries.fold(0, (sum, entry) => sum + entry.durationMinutes);
    
    setState(() {
      _todayScore = todayScore;
      _weekTrend = weekTrend;
      _totalTasks = tasks.length;
      _completedTasks = tasks.where((t) => t.isDone).length;
      _activeGoals = goals.length;
      _totalTimeMinutes = totalTime;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Productivity Score Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Today\'s Productivity',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(_todayScore * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _todayScore,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Weekly Trend', style: AppTheme.heading3),
                  const SizedBox(height: 12),
                  
                  // Week Trend Chart
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildWeekChart(),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Overview', style: AppTheme.heading3),
                  const SizedBox(height: 12),
                  
                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Tasks',
                          '$_completedTasks/$_totalTasks',
                          Icons.task_alt_rounded,
                          AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Goals',
                          '$_activeGoals',
                          Icons.flag_rounded,
                          AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Time Tracked',
                          '${(_totalTimeMinutes / 60).toStringAsFixed(1)}h',
                          Icons.schedule_rounded,
                          AppTheme.warningColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Completion',
                          _totalTasks > 0 ? '${((_completedTasks / _totalTasks) * 100).toInt()}%' : '0%',
                          Icons.check_circle_rounded,
                          AppTheme.mediumPriority,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWeekChart() {
    if (_weekTrend.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No data yet', style: AppTheme.caption),
        ),
      );
    }

    final maxScore = _weekTrend.values.reduce((a, b) => a > b ? a : b);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final dayIndex = (index + 1) % 7;
          final score = _weekTrend[dayIndex] ?? 0.0;
          final height = maxScore > 0 ? (score / maxScore) * 120 : 0.0;
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${(score * 100).toInt()}',
                style: AppTheme.caption.copyWith(fontSize: 10),
              ),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: height.clamp(8.0, 120.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: AppTheme.caption.copyWith(fontSize: 11),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(label, style: AppTheme.caption),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.heading3.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

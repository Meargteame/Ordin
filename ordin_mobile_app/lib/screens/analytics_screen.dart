import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/analytics_engine.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late AnalyticsEngine _analytics;
  Map<String, dynamic> _insights = {};
  double _todayScore = 0.0;
  Map<int, double> _weekTrend = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAnalytics();
  }

  Future<void> _initAnalytics() async {
    final storage = HiveStorageService();
    await storage.init();
    _analytics = AnalyticsEngine();
    await _analytics.init(storage);
    await _loadData();
  }

  Future<void> _loadData() async {
    final insights = await _analytics.getCrossAreaInsights();
    final today = DateTime.now();
    final score = await _analytics.calculateProductivityScore(today);
    final weekAgo = today.subtract(const Duration(days: 7));
    final trend = await _analytics.getProductivityTrend(weekAgo, today);

    setState(() {
      _insights = insights;
      _todayScore = score;
      _weekTrend = trend;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Analytics', style: AppTheme.displayMedium),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.borderGray),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildProductivityScore(),
                  const SizedBox(height: 24),
                  _buildInsightsGrid(),
                  const SizedBox(height: 32),
                  Text('Weekly Trend', style: AppTheme.headingLarge),
                  const SizedBox(height: 16),
                  _buildWeeklyTrend(),
                  const SizedBox(height: 32),
                  _buildQuickStats(),
                ],
              ),
            ),
    );
  }

  Widget _buildProductivityScore() {
    final score = (_todayScore * 100).toInt();
    final color = score >= 80
        ? AppTheme.successGreen
        : score >= 50
            ? AppTheme.warningOrange
            : AppTheme.dangerRed;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.insights_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Productivity Score',
                      style: AppTheme.labelLarge.copyWith(color: Colors.white.withOpacity(0.9)),
                    ),
                    Text(
                      DateFormat('EEEE, MMM d').format(DateTime.now()),
                      style: AppTheme.bodySmall.copyWith(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getScoreMessage(score),
            style: AppTheme.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return 'Outstanding performance!';
    if (score >= 80) return 'Excellent work today!';
    if (score >= 70) return 'Great productivity!';
    if (score >= 60) return 'Good progress!';
    if (score >= 50) return 'Keep pushing forward!';
    return 'Room for improvement';
  }

  Widget _buildInsightsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildInsightCard(
            'Week Average',
            '${_insights['weekAverage'] ?? 0}%',
            Icons.trending_up_rounded,
            AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInsightCard(
            'Top Category',
            _insights['topCategory'] ?? 'None',
            Icons.category_rounded,
            AppTheme.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(value, style: AppTheme.headingLarge.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrend() {
    if (_weekTrend.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Center(
          child: Text('No data available', style: AppTheme.bodyMedium),
        ),
      );
    }

    final sortedEntries = _weekTrend.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        children: sortedEntries.map((entry) {
          final date = DateTime.fromMillisecondsSinceEpoch(entry.key);
          final score = (entry.value * 100).toInt();
          final color = score >= 70
              ? AppTheme.successGreen
              : score >= 50
                  ? AppTheme.warningOrange
                  : AppTheme.dangerRed;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('EEE, MMM d').format(date), style: AppTheme.bodyMedium),
                    Text('$score%', style: AppTheme.labelLarge.copyWith(color: color)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value,
                    backgroundColor: AppTheme.borderGray,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Stats', style: AppTheme.headingLarge),
        const SizedBox(height: 16),
        _buildStatRow('Tasks Completed', '${_insights['todayScore'] ?? 0}%', Icons.check_circle_rounded, AppTheme.primaryBlue),
        const SizedBox(height: 12),
        _buildStatRow('Habits Maintained', '${_insights['weekAverage'] ?? 0}%', Icons.auto_awesome_rounded, AppTheme.successGreen),
        const SizedBox(height: 12),
        _buildStatRow('Time Tracked', '0h', Icons.timer_rounded, AppTheme.warningOrange),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: AppTheme.bodyLarge),
          ),
          Text(value, style: AppTheme.headingMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}

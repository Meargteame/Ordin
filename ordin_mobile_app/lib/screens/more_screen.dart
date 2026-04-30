import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';
import 'goals_screen.dart';
import 'projects_screen.dart';
import 'time_tracking_screen.dart';
import 'analytics_screen.dart';
import 'calendar_screen.dart';
import 'notes_screen.dart';
import 'journal_screen.dart';
import 'health_screen.dart';
import 'finance_screen.dart';
import 'relationships_screen.dart';
import 'learning_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: GradientAppBar(
        title: 'More',
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Life Management', style: AppTheme.headingLarge),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Goals',
            'Set and track long-term objectives',
            Icons.flag_rounded,
            AppTheme.primaryBlue,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Projects',
            'Manage complex multi-task projects',
            Icons.folder_rounded,
            AppTheme.infoBlue,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Time Tracking',
            'Track time spent on activities',
            Icons.timer_rounded,
            AppTheme.warningOrange,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeTrackingScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Calendar',
            'Schedule and plan your time',
            Icons.calendar_today_rounded,
            AppTheme.successGreen,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
          ),
          const SizedBox(height: 32),
          Text('Knowledge & Reflection', style: AppTheme.headingLarge),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Notes',
            'Capture ideas and information',
            Icons.note_rounded,
            AppTheme.primaryBlue,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Journal',
            'Daily reflection and gratitude',
            Icons.book_rounded,
            AppTheme.infoBlue,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalScreen())),
          ),
          const SizedBox(height: 32),
          Text('Life Areas', style: AppTheme.headingLarge),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Health',
            'Track workouts, sleep, and nutrition',
            Icons.favorite_rounded,
            AppTheme.dangerRed,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Finance',
            'Manage expenses and budgets',
            Icons.account_balance_wallet_rounded,
            AppTheme.successGreen,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Relationships',
            'Track important people and dates',
            Icons.people_rounded,
            AppTheme.warningOrange,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RelationshipsScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Learning',
            'Track books, courses, and skills',
            Icons.school_rounded,
            AppTheme.primaryBlue,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningScreen())),
          ),
          const SizedBox(height: 32),
          Text('Insights', style: AppTheme.headingLarge),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Analytics',
            'View productivity insights and trends',
            Icons.insights_rounded,
            AppTheme.infoBlue,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
          ),
          const SizedBox(height: 32),
          Text('Settings', style: AppTheme.headingLarge),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Preferences',
            'Customize your experience',
            Icons.settings_rounded,
            AppTheme.textSecondary,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Export Data',
            'Backup your information',
            Icons.download_rounded,
            AppTheme.textSecondary,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTheme.headingMedium),
                      const SizedBox(height: 2),
                      Text(description, style: AppTheme.bodyMedium),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon', style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

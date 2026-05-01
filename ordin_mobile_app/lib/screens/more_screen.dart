import 'package:flutter/material.dart';
import '../theme/premium_colors.dart';
import '../theme/premium_typography.dart';
import '../theme/premium_spacing.dart';
import '../theme/premium_shadows.dart';
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
      backgroundColor: PremiumColors.backgroundColor,
      appBar: GradientAppBar(
        title: 'More',
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Life Management', style: PremiumTypography.headingLarge),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Goals',
            'Set and track long-term objectives',
            Icons.flag_rounded,
            PremiumColors.primary500,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Projects',
            'Manage complex multi-task projects',
            Icons.folder_rounded,
            PremiumColors.info500,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectsScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Time Tracking',
            'Track time spent on activities',
            Icons.timer_rounded,
            PremiumColors.warning500,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeTrackingScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Calendar',
            'Schedule and plan your time',
            Icons.calendar_today_rounded,
            PremiumColors.success500,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
          ),
          const SizedBox(height: 32),
          Text('Knowledge & Reflection', style: PremiumTypography.headingLarge),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Notes',
            'Capture ideas and information',
            Icons.note_rounded,
            PremiumColors.primary500,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Journal',
            'Daily reflection and gratitude',
            Icons.book_rounded,
            PremiumColors.info500,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalScreen())),
          ),
          const SizedBox(height: 32),
          Text('Life Areas', style: PremiumTypography.headingLarge),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Health',
            'Track workouts, sleep, and nutrition',
            Icons.favorite_rounded,
            PremiumColors.error500,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Finance',
            'Manage expenses and budgets',
            Icons.account_balance_wallet_rounded,
            PremiumColors.success500,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Relationships',
            'Track important people and dates',
            Icons.people_rounded,
            PremiumColors.warning500,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RelationshipsScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Learning',
            'Track books, courses, and skills',
            Icons.school_rounded,
            PremiumColors.primary500,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningScreen())),
          ),
          const SizedBox(height: 32),
          Text('Insights', style: PremiumTypography.headingLarge),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Analytics',
            'View productivity insights and trends',
            Icons.insights_rounded,
            PremiumColors.info500,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
          ),
          const SizedBox(height: 32),
          Text('Settings', style: PremiumTypography.headingLarge),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context,
            'Preferences',
            'Customize your experience',
            Icons.settings_rounded,
            PremiumColors.gray600,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            context,
            'Export Data',
            'Backup your information',
            Icons.download_rounded,
            PremiumColors.gray600,
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
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.96 + (0.04 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: PremiumColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PremiumColors.gray300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: color.withOpacity(0.1),
            highlightColor: color.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: PremiumTypography.headingMedium),
                        const SizedBox(height: 2),
                        Text(description, style: PremiumTypography.bodyMedium),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: PremiumColors.gray500),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon', style: PremiumTypography.bodyMedium.copyWith(color: Colors.white)),
        backgroundColor: PremiumColors.primary500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

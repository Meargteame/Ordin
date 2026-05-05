import 'package:flutter/material.dart';
import 'goals_screen.dart';
import 'projects_screen.dart';
import 'time_tracking_screen.dart';
import 'calendar_screen.dart';
import 'notes_screen.dart';
import 'journal_screen.dart';
import 'health_screen.dart';
import 'finance_screen.dart';
import 'relationships_screen.dart';
import 'learning_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import '../theme/theme_helper.dart';
import '../theme/ordin_theme.dart';

class MoreScreen extends StatelessWidget {
  final Function(ThemeMode)? onThemeChanged;
  final ThemeMode? currentThemeMode;
  
  const MoreScreen({
    super.key,
    this.onThemeChanged,
    this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return _buildMainContent(context);
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(context),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildRecentActivity(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: ThemeHelper.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: OrdinTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.apps,
                  color: OrdinTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Ordin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ThemeHelper.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your personal life management hub',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Access all your productivity tools from the drawer menu. Tap the menu icon above to explore Goals, Projects, Time Tracking, and more.',
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelper.textSecondary(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ThemeHelper.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                Icons.add_task,
                'New Task',
                OrdinTheme.primary,
                () => _navigateToTaskForm(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                Icons.note_add,
                'Quick Note',
                const Color(0xFF6B7280),
                () => _navigateToNotes(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                Icons.timer,
                'Start Timer',
                const Color(0xFF3B82F6),
                () => _navigateToTimeTracking(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToTaskForm(BuildContext context) {
    // We'll need to access the MainScreen's task form method
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Switch to Tasks tab and tap + to add a task')),
    );
  }

  void _navigateToNotes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotesScreen()),
    );
  }

  void _navigateToTimeTracking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TimeTrackingScreen()),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ThemeHelper.cardDecoration(context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ThemeHelper.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: ThemeHelper.cardDecoration(context),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: ThemeHelper.textTertiary(context).withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No recent activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeHelper.textSecondary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start using the apps to see your activity here',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeHelper.textTertiary(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget? screen;
  final Function(BuildContext)? onTap;

  _AppItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.screen,
    this.onTap,
  });
}
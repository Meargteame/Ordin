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

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExploreAppsCard(),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Life Management',
                    'NEW',
                    [
                      _AppItem(
                        icon: Icons.flag_outlined,
                        title: 'Goals',
                        subtitle: 'Set long-term objectives and track progress',
                        color: const Color(0xFF8B5CF6),
                        screen: const GoalsScreen(),
                      ),
                      _AppItem(
                        icon: Icons.folder_outlined,
                        title: 'Projects',
                        subtitle: 'Organize and execute multi-step initiatives',
                        color: const Color(0xFFEC4899),
                        screen: const ProjectsScreen(),
                      ),
                      _AppItem(
                        icon: Icons.timer_outlined,
                        title: 'Time Tracking',
                        subtitle: 'Log time on tasks and analyze your productivity',
                        color: const Color(0xFF3B82F6),
                        screen: const TimeTrackingScreen(),
                      ),
                      _AppItem(
                        icon: Icons.calendar_today_outlined,
                        title: 'Calendar',
                        subtitle: 'Schedule events and plan your days',
                        color: const Color(0xFF10B981),
                        screen: const CalendarScreen(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Knowledge & Reflection',
                    null,
                    [
                      _AppItem(
                        icon: Icons.note_outlined,
                        title: 'Notes',
                        subtitle: 'Capture ideas and information for later',
                        color: const Color(0xFF6B7280),
                        screen: const NotesScreen(),
                      ),
                      _AppItem(
                        icon: Icons.book_outlined,
                        title: 'Journal',
                        subtitle: 'Daily entries and accompanying journal',
                        color: const Color(0xFFF59E0B),
                        screen: const JournalScreen(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Life Areas',
                    null,
                    [
                      _AppItem(
                        icon: Icons.favorite_outline,
                        title: 'Health',
                        subtitle: 'Track fitness, diet, and sleep',
                        color: const Color(0xFFEF4444),
                        screen: const HealthScreen(),
                      ),
                      _AppItem(
                        icon: Icons.attach_money,
                        title: 'Finance',
                        subtitle: 'Manage budgets and track expenses',
                        color: const Color(0xFF10B981),
                        screen: const FinanceScreen(),
                      ),
                      _AppItem(
                        icon: Icons.people_outline,
                        title: 'Relationships',
                        subtitle: 'Nurture connections with people',
                        color: const Color(0xFFEC4899),
                        screen: const RelationshipsScreen(),
                      ),
                      _AppItem(
                        icon: Icons.school_outlined,
                        title: 'Learning',
                        subtitle: 'Courses, books, and skills',
                        color: const Color(0xFF3B82F6),
                        screen: const LearningScreen(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    'Insights',
                    null,
                    [
                      _AppItem(
                        icon: Icons.insights_outlined,
                        title: 'Analytics',
                        subtitle: 'Visualize and analyze performance',
                        color: const Color(0xFF2563EB),
                        screen: const AnalyticsScreen(),
                      ),
                      _AppItem(
                        icon: Icons.file_download_outlined,
                        title: 'Export',
                        subtitle: 'Download all data in CSV or JSON format',
                        color: const Color(0xFF6B7280),
                        onTap: (context) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Export feature coming soon')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildGetStartedCard(),
                  const SizedBox(height: 24),
                  _buildFeedbackCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFFF8F9FA),
      elevation: 0,
      toolbarHeight: 70,
      title: const Row(
        children: [
          Text(
            'Explore Apps',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF6B7280)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildExploreAppsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage your ecosystem',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Connect specialized mini-apps to your workspace to build your ideal life management system.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String? badge, List<_AppItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Container(
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
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              
              return Column(
                children: [
                  _buildAppListItem(item),
                  if (!isLast)
                    const Divider(height: 1, indent: 68, color: Color(0xFFF3F4F6)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAppListItem(_AppItem item) {
    return Builder(
      builder: (context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (item.onTap != null) {
              item.onTap!(context);
            } else if (item.screen != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => item.screen!),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          const Text(
            'New to Ordin?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get a tour of our platform, discover what you can do, and learn how to get the most out of your super app.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite_border,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Report an Issue or App',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Can\'t find any app you might use or have a suggestion?',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Submit Idea',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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

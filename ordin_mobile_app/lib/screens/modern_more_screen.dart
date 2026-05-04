import 'package:flutter/material.dart';
import '../theme/modern_dark_colors.dart';
import '../theme/modern_dark_typography.dart';
import '../theme/modern_dark_spacing.dart';
import '../widgets/modern/bottom_action_bar.dart';

class ModernMoreScreen extends StatelessWidget {
  const ModernMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernDarkColors.darkBackground,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: ModernDarkSpacing.screenPadding,
                right: ModernDarkSpacing.screenPadding,
                top: ModernDarkSpacing.screenPadding,
                bottom: 100.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: ModernDarkSpacing.xxl),
                  _buildSection('Productivity', [
                    _FeatureItem(
                      icon: Icons.task_alt_rounded,
                      title: 'Tasks',
                      color: ModernDarkColors.blue,
                      onTap: () {},
                    ),
                    _FeatureItem(
                      icon: Icons.folder_rounded,
                      title: 'Projects',
                      color: ModernDarkColors.purple,
                      onTap: () {},

                    ),
                    _FeatureItem(
                      icon: Icons.flag_rounded,
                      title: 'Goals',
                      color: ModernDarkColors.green,
                      onTap: () {},
                    ),
                    _FeatureItem(
                      icon: Icons.access_time_rounded,
                      title: 'Time Tracking',
                      color: ModernDarkColors.orange,
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: ModernDarkSpacing.xxl),
                  _buildSection('Personal', [
                    _FeatureItem(
                      icon: Icons.book_rounded,
                      title: 'Journal',
                      color: ModernDarkColors.pink,
                      onTap: () {},
                    ),
                    _FeatureItem(
                      icon: Icons.note_rounded,
                      title: 'Notes',
                      color: ModernDarkColors.blue,
                      onTap: () {},
                    ),
                    _FeatureItem(
                      icon: Icons.favorite_rounded,
                      title: 'Health',
                      color: ModernDarkColors.red,
                      onTap: () {},
                    ),
                    _FeatureItem(
                      icon: Icons.people_rounded,
                      title: 'Relationships',
                      color: ModernDarkColors.purple,
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: ModernDarkSpacing.xxl),
                  _buildSection('Growth', [
                    _FeatureItem(
                      icon: Icons.school_rounded,
                      title: 'Learning',
                      color: ModernDarkColors.blue,
                      onTap: () {},
                    ),
                    _FeatureItem(
                      icon: Icons.attach_money_rounded,
                      title: 'Finance',
                      color: ModernDarkColors.green,
                      onTap: () {},
                    ),
                    _FeatureItem(
                      icon: Icons.analytics_rounded,
                      title: 'Analytics',
                      color: ModernDarkColors.orange,
                      onTap: () {},
                    ),
                    _FeatureItem(
                      icon: Icons.settings_rounded,
                      title: 'Settings',
                      color: ModernDarkColors.textSecondary,
                      onTap: () {},
                    ),
                  ]),
                ],
              ),
            ),
            BottomActionBar(
              onMenuTap: () {},
              onAddTap: () {},
              onCalendarTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'More',
          style: ModernDarkTypography.displayMedium,
        ),
        Icon(
          Icons.search_rounded,
          color: ModernDarkColors.textPrimary,
          size: 24.0,
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<_FeatureItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ModernDarkTypography.headingMedium,
        ),
        const SizedBox(height: ModernDarkSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: ModernDarkSpacing.md,
          crossAxisSpacing: ModernDarkSpacing.md,
          childAspectRatio: 1.5,
          children: items,
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ModernDarkSpacing.md),
        decoration: BoxDecoration(
          color: ModernDarkColors.cardElevated,
          borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusXs),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.0,
              ),
            ),
            const SizedBox(height: ModernDarkSpacing.sm),
            Text(
              title,
              style: ModernDarkTypography.taskTitle,
            ),
          ],
        ),
      ),
    );
  }
}

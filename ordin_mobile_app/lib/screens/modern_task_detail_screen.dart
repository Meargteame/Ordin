import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/modern_dark_colors.dart';
import '../theme/modern_dark_typography.dart';
import '../theme/modern_dark_spacing.dart';
import '../widgets/modern/pill_tag.dart';

class ModernTaskDetailScreen extends StatelessWidget {
  final Task task;
  
  const ModernTaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernDarkColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ModernDarkSpacing.screenPadding),
                child: _buildContentCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ModernDarkSpacing.screenPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: ModernDarkColors.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8.0),
              Text(
                '#1283',
                style: ModernDarkTypography.headingSmall,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: ModernDarkColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      padding: const EdgeInsets.all(ModernDarkSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags row
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              PillTag.teamMeeting('Team meeting'),
              PillTag.priority('Normal priority', icon: Icons.flag_outlined),
            ],
          ),
          
          const SizedBox(height: ModernDarkSpacing.md),
          
          // Project
          Text(
            '#PrimaVita Project',
            style: ModernDarkTypography.labelMedium.copyWith(
              color: ModernDarkColors.textTertiary,
            ),
          ),
          
          const SizedBox(height: ModernDarkSpacing.sm),
          
          // Title
          Text(
            task.title,
            style: ModernDarkTypography.displayMedium.copyWith(
              color: Colors.black,
              fontSize: 24.0,
            ),
          ),
          
          const SizedBox(height: ModernDarkSpacing.md),
          
          // Time info
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16.0,
                color: ModernDarkColors.textTertiary,
              ),
              const SizedBox(width: 4.0),
              Text(
                '10 AM - 10:30 AM • 30 m • repeat weekly',
                style: ModernDarkTypography.bodySmall.copyWith(
                  color: ModernDarkColors.textTertiary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8.0),
          
          // Due date
          Text(
            'due Today 10:30',
            style: ModernDarkTypography.labelMedium.copyWith(
              color: ModernDarkColors.red,
            ),
          ),
          
          const SizedBox(height: ModernDarkSpacing.xl),
          
          // Assignees
          Text(
            'ASSIGNEES:',
            style: ModernDarkTypography.labelSmall.copyWith(
              color: ModernDarkColors.textTertiary,
              letterSpacing: 1.0,
            ),
          ),
          
          const SizedBox(height: ModernDarkSpacing.md),
          
          _buildAssignee('You', '', isYou: true),
          const SizedBox(height: ModernDarkSpacing.md),
          _buildAssignee('Sara Perkinson', 'Teamlead'),
          
          const SizedBox(height: ModernDarkSpacing.xl),
          
          // Description
          Text(
            'DESCRIPTION',
            style: ModernDarkTypography.labelSmall.copyWith(
              color: ModernDarkColors.textTertiary,
              letterSpacing: 1.0,
            ),
          ),
          
          const SizedBox(height: ModernDarkSpacing.md),
          
          Text(
            task.description ?? 'Participants, including key team members and the team lead, will collaborate to assess recent design developments, provide constructive feedback, and make necessary adjustments to enhance...',
            style: ModernDarkTypography.bodyMedium.copyWith(
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: ModernDarkSpacing.xxl),
          
          // CTA Button
          SizedBox(
            width: double.infinity,
            height: ModernDarkSpacing.buttonHeightLarge,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusMd),
                ),
                elevation: 0,
              ),
              child: Text(
                'Join meeting • starts in 28 m',
                style: ModernDarkTypography.buttonText.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignee(String name, String role, {bool isYou = false}) {
    return Row(
      children: [
        Container(
          width: 32.0,
          height: 32.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ModernDarkColors.cardElevated,
          ),
          child: const Icon(
            Icons.person,
            size: 18.0,
            color: ModernDarkColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: ModernDarkTypography.bodyMedium.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (role.isNotEmpty)
              Text(
                role,
                style: ModernDarkTypography.labelSmall.copyWith(
                  color: ModernDarkColors.textTertiary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

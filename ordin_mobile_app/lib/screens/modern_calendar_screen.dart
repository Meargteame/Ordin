import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/modern_dark_colors.dart';
import '../theme/modern_dark_typography.dart';
import '../theme/modern_dark_spacing.dart';
import '../widgets/modern/avatar_group.dart';
import '../widgets/modern/pill_tag.dart';

import '../widgets/modern/stripe_pattern.dart';

class ModernCalendarScreen extends StatefulWidget {
  const ModernCalendarScreen({super.key});

  @override
  State<ModernCalendarScreen> createState() => _ModernCalendarScreenState();
}

class _ModernCalendarScreenState extends State<ModernCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernDarkColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildWeekView(),
            Expanded(child: _buildTimeline()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(ModernDarkSpacing.screenPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: ModernDarkTypography.headingMedium,
              ),
              const SizedBox(width: 8.0),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ModernDarkColors.textPrimary,
                size: 20.0,
              ),
            ],
          ),
          Icon(
            Icons.search_rounded,
            color: ModernDarkColors.textPrimary,
            size: 24.0,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    final weekDays = List.generate(7, (index) {
      return _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1 - index));
    });

    return Container(
      height: 80.0,
      padding: const EdgeInsets.symmetric(horizontal: ModernDarkSpacing.screenPadding),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final date = weekDays[index];
          final isSelected = date.day == _selectedDate.day;
          
          return _buildDatePill(date, isSelected);
        },
      ),
    );
  }

  Widget _buildDatePill(DateTime date, bool isSelected) {
    return Container(
      width: 48.0,
      margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? ModernDarkColors.limeAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date.day.toString(),
            style: ModernDarkTypography.headingMedium.copyWith(
              color: isSelected ? ModernDarkColors.textOnLime : ModernDarkColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            DateFormat('E').format(date),
            style: ModernDarkTypography.labelSmall.copyWith(
              color: isSelected ? ModernDarkColors.textOnLime : ModernDarkColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: ModernDarkSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time labels
          Container(
            width: 60.0,
            padding: const EdgeInsets.only(left: ModernDarkSpacing.screenPadding),
            child: Column(
              children: List.generate(12, (index) {
                final hour = 8 + index;
                return Container(
                  height: 60.0,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '$hour ${hour < 12 ? 'AM' : 'PM'}',
                    style: ModernDarkTypography.labelSmall,
                  ),
                );
              }),
            ),
          ),
          
          // Events
          Expanded(
            child: Stack(
              children: [
                // Grid lines
                Column(
                  children: List.generate(12, (index) {
                    return Container(
                      height: 60.0,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: ModernDarkColors.cardElevated,
                            width: 1.0,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                
                // Event cards
                ..._buildEventCards(),
              ],
            ),
          ),
          const SizedBox(width: ModernDarkSpacing.screenPadding),
        ],
      ),
    );
  }

  List<Widget> _buildEventCards() {
    return [
      // Morning Yoga - 8 AM
      _buildEventCard(
        top: 0.0,
        height: 60.0,
        title: 'Morning Yoga',
        time: '9 AM - 10 AM • 1 hr',
        tag: 'Personal',
        tagColor: ModernDarkColors.cardElevated,
        backgroundColor: ModernDarkColors.limeAccent,
        textColor: ModernDarkColors.textOnLime,
        hasPattern: true,
        patternColor: ModernDarkColors.patternDark.withOpacity(0.1),
      ),
      
      // Daily sync - 9 AM
      _buildEventCard(
        top: 60.0,
        height: 60.0,
        title: 'Daily sync',
        time: '9 AM - 10 AM • 1 hr',
        tag: 'Team meeting',
        tagColor: ModernDarkColors.purple,
        backgroundColor: ModernDarkColors.purpleLight,
        textColor: ModernDarkColors.textOnLime,
        hasPattern: true,
        patternColor: ModernDarkColors.purple.withOpacity(0.2),
        avatars: const ['', '', '', ''],
      ),
      
      // Design review - 10 AM
      _buildEventCard(
        top: 120.0,
        height: 40.0,
        title: 'Design review on PrimaVita p...',
        time: '10 AM - 10:30 AM • 30 m',
        backgroundColor: ModernDarkColors.cardDark,
        textColor: ModernDarkColors.textPrimary,
        avatars: const ['', ''],
      ),
      
      // Prepare presentation - 11 AM
      _buildEventCard(
        top: 180.0,
        height: 120.0,
        title: 'Prepare product presentation for PrimaVita Project',
        time: '11 AM - 1 PM • 2 hr',
        backgroundColor: ModernDarkColors.limeAccent,
        textColor: ModernDarkColors.textOnLime,
        avatars: const ['', ''],
      ),
    ];
  }

  Widget _buildEventCard({
    required double top,
    required double height,
    required String title,
    required String time,
    String? tag,
    Color? tagColor,
    required Color backgroundColor,
    required Color textColor,
    bool hasPattern = false,
    Color? patternColor,
    List<String>? avatars,
  }) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: height,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0, right: 8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusMd),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusMd),
          child: Stack(
            children: [
              if (hasPattern && patternColor != null)
                Positioned.fill(
                  child: StripePattern(
                    stripeColor: patternColor,
                    stripeWidth: 1.5,
                    stripeSpacing: 6.0,
                    angle: 45.0,
                    child: Container(),
                  ),
                ),
              
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tag != null) ...[
                      PillTag(
                        text: tag,
                        backgroundColor: tagColor ?? ModernDarkColors.cardElevated,
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 4.0),
                    ],
                    Text(
                      title,
                      style: ModernDarkTypography.taskTitle.copyWith(
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (avatars != null)
                          AvatarGroup(
                            avatarUrls: avatars,
                            size: 24.0,
                            maxVisible: 3,
                          ),
                        Text(
                          time,
                          style: ModernDarkTypography.labelSmall.copyWith(
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

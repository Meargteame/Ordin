import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../theme/app_theme.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: goal.progress >= 1.0
            ? LinearGradient(
                colors: [
                  AppTheme.successColor.withOpacity(0.1),
                  AppTheme.successColor.withOpacity(0.05),
                ],
              )
            : null,
        color: goal.progress >= 1.0 ? null : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildCategoryIcon(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        goal.title,
                        style: AppTheme.heading3.copyWith(
                          decoration: goal.progress >= 1.0 ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    _buildPriorityBadge(),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(goal.progress * 100).toInt()}% complete',
                      style: AppTheme.caption.copyWith(
                        color: _getProgressColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (goal.deadline != null) _buildDeadlineChip(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    String emoji;
    Color color;
    
    switch (goal.category) {
      case GoalCategory.career:
        emoji = '💼';
        color = AppTheme.primaryColor;
        break;
      case GoalCategory.health:
        emoji = '💪';
        color = AppTheme.successColor;
        break;
      case GoalCategory.finance:
        emoji = '💰';
        color = AppTheme.warningColor;
        break;
      case GoalCategory.relationships:
        emoji = '❤️';
        color = AppTheme.highPriority;
        break;
      case GoalCategory.personalGrowth:
        emoji = '🌱';
        color = AppTheme.lowPriority;
        break;
      case GoalCategory.learning:
        emoji = '📚';
        color = AppTheme.mediumPriority;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    if (goal.priority == Priority.low) return const SizedBox.shrink();
    
    Color color;
    IconData icon;
    
    switch (goal.priority) {
      case Priority.high:
        color = AppTheme.errorColor;
        icon = Icons.priority_high_rounded;
        break;
      case Priority.medium:
        color = AppTheme.warningColor;
        icon = Icons.remove_rounded;
        break;
      case Priority.low:
        color = AppTheme.lowPriority;
        icon = Icons.arrow_downward_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }

  Widget _buildDeadlineChip() {
    final deadline = goal.deadline!;
    final daysUntil = deadline.difference(DateTime.now()).inDays;
    
    Color color;
    IconData icon;
    
    if (daysUntil < 0) {
      color = AppTheme.errorColor;
      icon = Icons.warning_rounded;
    } else if (daysUntil < 7) {
      color = AppTheme.errorColor;
      icon = Icons.schedule_rounded;
    } else if (daysUntil < 30) {
      color = AppTheme.warningColor;
      icon = Icons.schedule_rounded;
    } else {
      color = AppTheme.textSecondary;
      icon = Icons.calendar_today_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            _formatDeadline(deadline, daysUntil),
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDeadline(DateTime deadline, int daysUntil) {
    if (daysUntil < 0) {
      return 'Overdue';
    } else if (daysUntil == 0) {
      return 'Today';
    } else if (daysUntil == 1) {
      return 'Tomorrow';
    } else if (daysUntil < 7) {
      return '$daysUntil days';
    } else {
      return '${deadline.day}/${deadline.month}';
    }
  }

  Color _getProgressColor() {
    if (goal.progress < 0.33) {
      return AppTheme.errorColor;
    } else if (goal.progress < 0.67) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.successColor;
    }
  }
}

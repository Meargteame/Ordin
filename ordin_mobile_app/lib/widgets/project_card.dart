import 'package:flutter/material.dart';
import '../models/project.dart';
import '../theme/app_theme.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: project.status == ProjectStatus.completed
            ? LinearGradient(
                colors: [
                  AppTheme.successColor.withOpacity(0.1),
                  AppTheme.successColor.withOpacity(0.05),
                ],
              )
            : null,
        color: project.status == ProjectStatus.completed ? null : AppTheme.cardColor,
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
                    _buildStatusIcon(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        project.title,
                        style: AppTheme.heading3.copyWith(
                          decoration: project.status == ProjectStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                if (project.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      project.description,
                      style: AppTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: project.progress,
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
                      '${(project.progress * 100).toInt()}% complete',
                      style: AppTheme.caption.copyWith(
                        color: _getProgressColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        _buildCategoryChip(),
                        if (project.deadline != null) ...[
                          const SizedBox(width: 8),
                          _buildDeadlineChip(),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    
    switch (project.status) {
      case ProjectStatus.planning:
        icon = Icons.lightbulb_outline_rounded;
        color = AppTheme.warningColor;
        break;
      case ProjectStatus.active:
        icon = Icons.play_circle_outline_rounded;
        color = AppTheme.primaryColor;
        break;
      case ProjectStatus.onHold:
        icon = Icons.pause_circle_outline_rounded;
        color = AppTheme.textSecondary;
        break;
      case ProjectStatus.completed:
        icon = Icons.check_circle_rounded;
        color = AppTheme.successColor;
        break;
      case ProjectStatus.archived:
        icon = Icons.archive_rounded;
        color = AppTheme.textSecondary;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        project.category,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.secondaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDeadlineChip() {
    final deadline = project.deadline!;
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
    if (project.progress < 0.33) {
      return AppTheme.errorColor;
    } else if (project.progress < 0.67) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.successColor;
    }
  }
}

import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class HabitItem extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const HabitItem({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: habit.isDoneToday
            ? LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: habit.isDoneToday ? null : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: habit.isDoneToday
            ? Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
                width: 1,
              )
            : null,
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
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Custom checkbox with animation
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: habit.isDoneToday ? AppTheme.primaryColor : Colors.transparent,
                    border: Border.all(
                      color: habit.isDoneToday ? AppTheme.primaryColor : AppTheme.textSecondary.withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: habit.isDoneToday
                      ? const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                
                // Habit content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: AppTheme.bodyLarge.copyWith(
                          decoration: habit.isDoneToday ? TextDecoration.lineThrough : null,
                          color: habit.isDoneToday ? AppTheme.textSecondary : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 14,
                            color: habit.streak > 0 ? AppTheme.warningColor : AppTheme.textSecondary.withOpacity(0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.streak} day${habit.streak != 1 ? 's' : ''} streak',
                            style: AppTheme.caption.copyWith(
                              color: habit.streak > 0 ? AppTheme.warningColor : AppTheme.textSecondary.withOpacity(0.6),
                              fontWeight: habit.streak > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Streak badge
                if (habit.streak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '🔥 ${habit.streak}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ),
                
                const SizedBox(width: 8),
                
                // Delete button
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

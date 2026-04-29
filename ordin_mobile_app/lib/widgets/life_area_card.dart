import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/life_area.dart';

class LifeAreaCard extends StatelessWidget {
  final LifeArea area;
  final VoidCallback onTap;

  const LifeAreaCard({
    super.key,
    required this.area,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(area.type);
    final icon = _getIconForType(area.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
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
                    Container(
                      width: 48,
                      height: 48,
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
                          Text(
                            area.name,
                            style: AppTheme.heading3.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Health Score: ${(area.healthScore * 100).toInt()}%',
                            style: AppTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: area.healthScore,
                  backgroundColor: AppTheme.textSecondary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForType(LifeAreaType type) {
    switch (type) {
      case LifeAreaType.health:
        return AppTheme.successColor;
      case LifeAreaType.finance:
        return AppTheme.primaryColor;
      case LifeAreaType.relationships:
        return AppTheme.highPriority;
      case LifeAreaType.learning:
        return AppTheme.warningColor;
      case LifeAreaType.custom:
        return AppTheme.mediumPriority;
    }
  }

  IconData _getIconForType(LifeAreaType type) {
    switch (type) {
      case LifeAreaType.health:
        return Icons.favorite_rounded;
      case LifeAreaType.finance:
        return Icons.attach_money_rounded;
      case LifeAreaType.relationships:
        return Icons.people_rounded;
      case LifeAreaType.learning:
        return Icons.school_rounded;
      case LifeAreaType.custom:
        return Icons.star_rounded;
    }
  }
}

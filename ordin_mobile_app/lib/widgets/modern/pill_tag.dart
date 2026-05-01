import 'package:flutter/material.dart';
import '../../theme/modern_dark_colors.dart';
import '../../theme/modern_dark_typography.dart';
import '../../theme/modern_dark_spacing.dart';

/// Pill Tag Widget - rounded tag/badge component
/// Matches reference design pixel-perfect
class PillTag extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final double? iconSize;
  
  const PillTag({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.iconSize,
  });
  
  // Predefined pill styles
  factory PillTag.teamMeeting(String text) {
    return PillTag(
      text: text,
      backgroundColor: ModernDarkColors.purple,
      textColor: Colors.white,
    );
  }
  
  factory PillTag.personal(String text) {
    return PillTag(
      text: text,
      backgroundColor: ModernDarkColors.cardElevated,
      textColor: ModernDarkColors.textSecondary,
    );
  }
  
  factory PillTag.priority(String text, {IconData? icon}) {
    return PillTag(
      text: text,
      backgroundColor: ModernDarkColors.cardElevated,
      textColor: ModernDarkColors.textSecondary,
      icon: icon,
      iconSize: 12.0,
    );
  }
  
  factory PillTag.project(String text) {
    return PillTag(
      text: text,
      backgroundColor: Colors.transparent,
      textColor: ModernDarkColors.textSecondary,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 6.0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize ?? 12.0,
              color: textColor,
            ),
            const SizedBox(width: 4.0),
          ],
          Text(
            text,
            style: ModernDarkTypography.pillText.copyWith(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/modern_dark_colors.dart';
import '../../theme/modern_dark_spacing.dart';

/// Bottom Action Bar - floating action bar with circular buttons
/// Matches reference design pixel-perfect
class BottomActionBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onCalendarTap;
  
  const BottomActionBar({
    super.key,
    this.onMenuTap,
    this.onAddTap,
    this.onCalendarTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: ModernDarkSpacing.bottomBarMargin,
      right: ModernDarkSpacing.bottomBarMargin,
      bottom: ModernDarkSpacing.bottomBarMargin,
      child: Container(
        height: ModernDarkSpacing.bottomBarHeight,
        decoration: BoxDecoration(
          color: ModernDarkColors.limeAccent,
          borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusXl),
          boxShadow: const [
            BoxShadow(
              color: ModernDarkColors.shadowHeavy,
              blurRadius: 20.0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.menu_rounded,
              onTap: onMenuTap,
            ),
            _buildActionButton(
              icon: Icons.add_rounded,
              onTap: onAddTap,
            ),
            _buildActionButton(
              icon: Icons.calendar_today_rounded,
              onTap: onCalendarTap,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ModernDarkSpacing.radiusRound),
        child: Container(
          width: ModernDarkSpacing.bottomBarButtonSize,
          height: ModernDarkSpacing.bottomBarButtonSize,
          decoration: BoxDecoration(
            color: ModernDarkColors.patternDark,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: ModernDarkColors.limeAccent,
            size: ModernDarkSpacing.iconLg,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Ordin Design System - Premium UI Components
/// Apply this across all 16 screens for consistency

class OrdinColors {
  // Primary Gradient - Sky Blue Theme
  static const primary = Color(0xFF0EA5E9); // Sky Blue
  static const primaryDark = Color(0xFF0284C7); // Deep Sky Blue
  static const primaryLight = Color(0xFF38BDF8); // Light Sky Blue
  
  // Accent Colors
  static const accent = Color(0xFF06B6D4); // Cyan
  static const success = Color(0xFF10B981); // Green
  static const successDark = Color(0xFF059669);
  static const warning = Color(0xFFF59E0B); // Orange
  static const warningDark = Color(0xFFEF4444); // Red
  static const error = Color(0xFFEF4444);
  
  // Neutral Colors
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);
  
  // Text Colors
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const textDisabled = Color(0xFFCBD5E1);
  
  // Gradients
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark, accent],
  );
  
  static const taskGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDark],
  );
  
  static const habitGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryLight, accent],
  );
  
  static const successGradient = LinearGradient(
    colors: [success, successDark],
  );
  
  static const streakGradient = LinearGradient(
    colors: [warning, warningDark],
  );
}

class OrdinTypography {
  // Display
  static const displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -1.5,
  );
  
  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -1,
  );
  
  // Headings
  static const headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
  );
  
  static const headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  
  static const headingSmall = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );
  
  // Body
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  // Labels
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
  
  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  
  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}

class OrdinSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  
  static const double cardPadding = 18;
  static const double screenPadding = 20;
  static const double sectionSpacing = 24;
  static const double cardSpacing = 12;
}

class OrdinRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  
  static BorderRadius small = BorderRadius.circular(sm);
  static BorderRadius medium = BorderRadius.circular(md);
  static BorderRadius large = BorderRadius.circular(lg);
  static BorderRadius extraLarge = BorderRadius.circular(xl);
}

class OrdinShadows {
  static List<BoxShadow> subtle = [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> strong = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> colored(Color color, {double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

/// Reusable Premium Header Component
class OrdinPremiumHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final List<Widget>? bottomWidgets;
  final LinearGradient? gradient;
  
  const OrdinPremiumHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.bottomWidgets,
    this.gradient,
  });
  
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: bottomWidgets != null ? 200 : 160,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: OrdinColors.primary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(
          decoration: BoxDecoration(
            gradient: gradient ?? OrdinColors.headerGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: OrdinTypography.displayLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: OrdinTypography.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                  if (bottomWidgets != null) ...[
                    const SizedBox(height: 20),
                    ...bottomWidgets!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable Section Header
class OrdinSectionHeader extends StatelessWidget {
  final String title;
  final String? badge;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  
  const OrdinSectionHeader({
    super.key,
    required this.title,
    this.badge,
    required this.gradient,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: OrdinTypography.headingLarge.copyWith(
            color: OrdinColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: OrdinColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge!,
              style: OrdinTypography.labelLarge.copyWith(
                color: OrdinColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Reusable Premium Card
class OrdinPremiumCard extends StatelessWidget {
  final Widget child;
  final bool isCompleted;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  
  const OrdinPremiumCard({
    super.key,
    required this.child,
    this.isCompleted = false,
    this.onTap,
    this.padding,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: OrdinColors.surface,
        borderRadius: OrdinRadius.large,
        border: Border.all(
          color: isCompleted ? OrdinColors.success : OrdinColors.border,
          width: 1.5,
        ),
        boxShadow: isCompleted
            ? OrdinShadows.colored(OrdinColors.success, opacity: 0.1)
            : OrdinShadows.subtle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: OrdinRadius.large,
          splashColor: OrdinColors.primary.withOpacity(0.05),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(18),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Reusable Checkbox
class OrdinCheckbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback? onTap;
  final double size;
  
  const OrdinCheckbox({
    super.key,
    required this.isChecked,
    this.onTap,
    this.size = 28,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isChecked ? OrdinColors.successGradient : null,
          border: Border.all(
            color: isChecked ? Colors.transparent : OrdinColors.textDisabled,
            width: 2.5,
          ),
          boxShadow: isChecked ? OrdinShadows.colored(OrdinColors.success) : null,
        ),
        child: isChecked
            ? Icon(Icons.check_rounded, size: size * 0.6, color: Colors.white)
            : null,
      ),
    );
  }
}

/// Reusable Badge
class OrdinBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final LinearGradient? gradient;
  final Color? color;
  final bool isGradient;
  
  const OrdinBadge({
    super.key,
    required this.text,
    this.icon,
    this.gradient,
    this.color,
    this.isGradient = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? OrdinColors.primary;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: isGradient ? (gradient ?? OrdinColors.streakGradient) : null,
        color: isGradient ? null : badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: isGradient ? null : Border.all(
          color: badgeColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: isGradient ? OrdinShadows.colored(badgeColor) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isGradient ? Colors.white : badgeColor,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: OrdinTypography.labelLarge.copyWith(
              color: isGradient ? Colors.white : badgeColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular Progress Painter
class OrdinCircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  OrdinCircularProgressPainter({
    required this.progress,
    this.color = Colors.white,
    Color? backgroundColor,
  }) : backgroundColor = backgroundColor ?? color.withOpacity(0.2);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(OrdinCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

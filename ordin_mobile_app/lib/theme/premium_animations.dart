import 'package:flutter/material.dart';

/// Premium animation system with durations and curves
/// Provides consistent, smooth animations across the app
class PremiumAnimations {
  // Duration constants
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 700);

  // Custom curves for premium feel
  static const Curve easeOutExpo = Curves.easeOutExpo;
  static const Curve easeInOutCubic = Curves.easeInOutCubic;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;

  // Micro-interaction durations
  static const Duration checkboxToggle = Duration(milliseconds: 200);
  static const Duration buttonPress = Duration(milliseconds: 100);
  static const Duration cardPress = Duration(milliseconds: 150);
  static const Duration chipTap = Duration(milliseconds: 120);
  static const Duration iconRotate = Duration(milliseconds: 200);

  // Page transition durations
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration modalTransition = Duration(milliseconds: 300);
  static const Duration bottomSheetTransition = Duration(milliseconds: 250);
  static const Duration dialogTransition = Duration(milliseconds: 200);

  // Loading animation durations
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Duration skeletonPulse = Duration(milliseconds: 1200);
  static const Duration spinnerRotation = Duration(milliseconds: 1000);

  // Gesture animation durations
  static const Duration swipeReveal = Duration(milliseconds: 200);
  static const Duration pullToRefresh = Duration(milliseconds: 300);
  static const Duration longPressStart = Duration(milliseconds: 500);

  // Scale values for press animations
  static const double pressScale = 0.96;
  static const double cardPressScale = 0.98;
  static const double iconPressScale = 0.9;

  // Opacity values for hover/press states
  static const double hoverOpacity = 0.08;
  static const double pressOpacity = 0.12;
  static const double disabledOpacity = 0.38;
}

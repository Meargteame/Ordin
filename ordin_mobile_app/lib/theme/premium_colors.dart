import 'package:flutter/material.dart';

/// Premium color palette for Ordin app
/// Inspired by sophisticated, high-end productivity apps
class PremiumColors {
  // Primary Brand Colors (Sky Blue - Fresh and Modern)
  static const primary50 = Color(0xFFF0F9FF);
  static const primary100 = Color(0xFFE0F2FE);
  static const primary200 = Color(0xFFBAE6FD);
  static const primary300 = Color(0xFF7DD3FC);
  static const primary400 = Color(0xFF38BDF8);
  static const primary500 = Color(0xFF0EA5E9); // Main brand color - Sky Blue
  static const primary600 = Color(0xFF0284C7);
  static const primary700 = Color(0xFF0369A1);
  static const primary800 = Color(0xFF075985);
  static const primary900 = Color(0xFF0C4A6E);

  // Neutral Grays (Warm neutrals for premium feel)
  static const gray50 = Color(0xFFFAFAFA);
  static const gray100 = Color(0xFFF5F5F5);
  static const gray200 = Color(0xFFE5E5E5);
  static const gray300 = Color(0xFFD4D4D4);
  static const gray400 = Color(0xFFA3A3A3);
  static const gray500 = Color(0xFF737373);
  static const gray600 = Color(0xFF525252);
  static const gray700 = Color(0xFF404040);
  static const gray800 = Color(0xFF262626);
  static const gray900 = Color(0xFF171717);

  // Semantic Colors - Success (Vibrant Green)
  static const success50 = Color(0xFFECFDF5);
  static const success100 = Color(0xFFD1FAE5);
  static const success500 = Color(0xFF10B981);
  static const success600 = Color(0xFF059669);
  static const success700 = Color(0xFF047857);

  // Semantic Colors - Warning (Warm Orange)
  static const warning50 = Color(0xFFFFF7ED);
  static const warning100 = Color(0xFFFFEDD5);
  static const warning500 = Color(0xFFF59E0B);
  static const warning600 = Color(0xFFD97706);
  static const warning700 = Color(0xFFB45309);

  // Semantic Colors - Error (Bold Red)
  static const error50 = Color(0xFFFEF2F2);
  static const error100 = Color(0xFFFEE2E2);
  static const error500 = Color(0xFFEF4444);
  static const error600 = Color(0xFFDC2626);
  static const error700 = Color(0xFFB91C1C);

  // Semantic Colors - Info (Cyan)
  static const info50 = Color(0xFFECFEFF);
  static const info100 = Color(0xFFCFFAFE);
  static const info500 = Color(0xFF06B6D4);
  static const info600 = Color(0xFF0891B2);
  static const info700 = Color(0xFF0E7490);

  // Dark Mode Colors
  static const darkBackground = Color(0xFF0F0F0F);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkSurfaceElevated = Color(0xFF242424);
  static const darkBorder = Color(0xFF2A2A2A);
  static const darkText = Color(0xFFE5E5E5);
  static const darkTextSecondary = Color(0xFFA3A3A3);

  // Surface Colors (Light Mode)
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const surfaceGray = Color(0xFFF9FAFB);
  static const backgroundColor = Color(0xFFF5F7FA);

  // Gradient Colors
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primary500, primary600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient successGradient = const LinearGradient(
    colors: [success500, success600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient warningGradient = const LinearGradient(
    colors: [warning500, warning600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient errorGradient = const LinearGradient(
    colors: [error500, error600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

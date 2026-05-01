import 'package:flutter/material.dart';
import 'modern_dark_colors.dart';

/// Modern Dark Theme Typography
/// Pixel perfect text styles matching reference design
class ModernDarkTypography {
  // Font family
  static const String fontFamily = 'SF Pro Text';
  static const String fontFamilyDisplay = 'SF Pro Display';
  
  // Display styles
  static const displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: ModernDarkColors.textPrimary,
  );
  
  static const displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.2,
    color: ModernDarkColors.textPrimary,
  );
  
  // Heading styles
  static const headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
    color: ModernDarkColors.textPrimary,
  );
  
  static const headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
    color: ModernDarkColors.textPrimary,
  );
  
  static const headingSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.3,
    color: ModernDarkColors.textPrimary,
  );
  
  // Body styles
  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.4,
    color: ModernDarkColors.textPrimary,
  );
  
  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.4,
    color: ModernDarkColors.textPrimary,
  );
  
  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.4,
    color: ModernDarkColors.textSecondary,
  );
  
  // Label styles
  static const labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.3,
    color: ModernDarkColors.textPrimary,
  );
  
  static const labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
    color: ModernDarkColors.textSecondary,
  );
  
  static const labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
    color: ModernDarkColors.textTertiary,
  );
  
  // Special styles
  static const greeting = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.2,
    color: ModernDarkColors.textPrimary,
  );
  
  static const taskTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
    height: 1.3,
    color: ModernDarkColors.textPrimary,
  );
  
  static const taskTime = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.3,
    color: ModernDarkColors.textSecondary,
  );
  
  static const pillText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
    height: 1.2,
    color: ModernDarkColors.textPrimary,
  );
  
  static const buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.2,
    color: ModernDarkColors.textPrimary,
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Brand Colors
  static const primaryBlue = Color(0xFF0EA5E9); // Sky Blue
  static const darkBlue = Color(0xFF0284C7); // Deep Sky Blue
  static const lightBlue = Color(0xFF38BDF8); // Light Sky Blue
  
  // Semantic Colors
  static const successGreen = Color(0xFF10B981);
  static const warningOrange = Color(0xFFF59E0B);
  static const dangerRed = Color(0xFFEF4444);
  static const infoBlue = Color(0xFF0EA5E9); // Sky Blue
  
  // Neutral Colors
  static const backgroundColor = Color(0xFFF8FAFC);
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const borderGray = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  
  // Legacy aliases for compatibility
  static const primaryColor = primaryBlue;
  static const cardColor = surfaceWhite;
  static const textDark = textPrimary;
  static const textGray = textSecondary;
  static const successColor = successGreen;
  static const warningColor = warningOrange;
  static const errorColor = dangerRed;
  static const highPriority = dangerRed;
  static const mediumPriority = warningOrange;
  static const lowPriority = infoBlue;
  static const streakActive = warningOrange;
  static const streakInactive = borderGray;
  static const secondaryColor = lightBlue;
  
  // Typography Scale
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.8,
    height: 1.2,
  );
  
  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.3,
  );
  
  static TextStyle get headingLarge => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
    height: 1.4,
  );
  
  static TextStyle get headingMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.2,
    height: 1.4,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.2,
    height: 1.4,
  );
  
  // Legacy text styles for compatibility
  static TextStyle get heading1 => displayLarge;
  static TextStyle get heading2 => displayMedium;
  static TextStyle get heading3 => headingLarge;
  static TextStyle get caption => bodySmall;
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: lightBlue,
        surface: surfaceWhite,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderGray, width: 1),
        ),
      ),
    );
  }
}

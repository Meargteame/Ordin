import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdinTheme {
  // Dark Mode Colors
  static const darkBackground = Color(0xFF0A0A0A);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkCard = Color(0xFF1F1F1F);
  static const darkBorder = Color(0xFF2A2A2A);
  static const darkCardElevated = Color(0xFF252525);
  
  // Light Mode Colors
  static const lightBackground = Color(0xFFF5F5F4); // Warm gray
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE7E5E4);
  static const lightCardElevated = Color(0xFFFAFAF9);
  
  // Brand Colors - Professional Blue
  static const primary = Color(0xFF2563EB); // Blue
  static const primaryDark = Color(0xFF1E40AF); // Dark Blue
  static const primaryLight = Color(0xFF3B82F6); // Light Blue
  
  // Semantic Colors
  static const success = Color(0xFF10B981); // Emerald
  static const warning = Color(0xFFF59E0B); // Amber
  static const error = Color(0xFFEF4444); // Red
  static const accent = Color(0xFFFF6B6B); // Coral for critical actions
  
  // Streak/Fire color
  static const streak = Color(0xFFF97316); // Orange
  
  // Text Colors - Dark Mode
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFA0A0A0);
  static const darkTextTertiary = Color(0xFF707070);
  
  // Text Colors - Light Mode
  static const lightTextPrimary = Color(0xFF0A0A0A);
  static const lightTextSecondary = Color(0xFF6B7280);
  static const lightTextTertiary = Color(0xFF9CA3AF);
  
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: primary,
    cardColor: darkCard,
    dividerColor: darkBorder,
    
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: primary,
      surface: darkSurface,
      background: darkBackground,
      error: error,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: darkTextPrimary),
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: darkBorder, width: 1),
      ),
    ),
    
    textTheme: GoogleFonts.dmSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkTextSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkTextTertiary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkTextSecondary,
        ),
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primary,
      unselectedItemColor: darkTextTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
  
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    primaryColor: primary,
    cardColor: lightCard,
    dividerColor: lightBorder,
    
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: primary,
      surface: lightSurface,
      background: lightBackground,
      error: error,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: lightTextPrimary),
      titleTextStyle: TextStyle(
        color: lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: lightBorder, width: 1),
      ),
    ),
    
    textTheme: GoogleFonts.dmSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: lightTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: lightTextSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: lightTextTertiary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: lightTextSecondary,
        ),
      ),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primary,
      unselectedItemColor: lightTextTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'premium_colors.dart';
import 'premium_typography.dart';
import 'premium_spacing.dart';

/// Premium theme configuration for Ordin app
/// Provides light and dark theme with sophisticated styling
class PremiumTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color scheme
    colorScheme: const ColorScheme.light(
      primary: PremiumColors.primary500,
      onPrimary: Colors.white,
      secondary: PremiumColors.primary600,
      onSecondary: Colors.white,
      error: PremiumColors.error500,
      onError: Colors.white,
      surface: PremiumColors.surfaceWhite,
      onSurface: PremiumColors.gray900,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: PremiumColors.backgroundColor,
    
    // App Bar
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: PremiumColors.primary500,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: PremiumTypography.headingMedium.copyWith(
        color: Colors.white,
      ),
    ),
    
    // Card
    cardTheme: CardThemeData(
      elevation: 0,
      color: PremiumColors.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusXXLarge),
      ),
      margin: const EdgeInsets.all(0),
    ),
    
    // Text theme
    textTheme: TextTheme(
      displayLarge: PremiumTypography.displayLarge.copyWith(color: PremiumColors.gray900),
      displayMedium: PremiumTypography.displayMedium.copyWith(color: PremiumColors.gray900),
      displaySmall: PremiumTypography.displaySmall.copyWith(color: PremiumColors.gray900),
      headlineLarge: PremiumTypography.headingLarge.copyWith(color: PremiumColors.gray900),
      headlineMedium: PremiumTypography.headingMedium.copyWith(color: PremiumColors.gray900),
      headlineSmall: PremiumTypography.headingSmall.copyWith(color: PremiumColors.gray900),
      bodyLarge: PremiumTypography.bodyLarge.copyWith(color: PremiumColors.gray700),
      bodyMedium: PremiumTypography.bodyMedium.copyWith(color: PremiumColors.gray700),
      bodySmall: PremiumTypography.bodySmall.copyWith(color: PremiumColors.gray600),
      labelLarge: PremiumTypography.labelLarge.copyWith(color: PremiumColors.gray900),
      labelMedium: PremiumTypography.labelMedium.copyWith(color: PremiumColors.gray700),
      labelSmall: PremiumTypography.labelSmall.copyWith(color: PremiumColors.gray600),
    ),
    
    // Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: PremiumColors.primary500,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, PremiumSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumSpacing.radiusLarge),
        ),
        textStyle: PremiumTypography.labelLarge,
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PremiumColors.gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusMedium),
        borderSide: const BorderSide(color: PremiumColors.gray300, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusMedium),
        borderSide: const BorderSide(color: PremiumColors.gray300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusMedium),
        borderSide: const BorderSide(color: PremiumColors.primary500, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusMedium),
        borderSide: const BorderSide(color: PremiumColors.error500, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PremiumSpacing.lg,
        vertical: PremiumSpacing.md,
      ),
      labelStyle: PremiumTypography.bodyMedium.copyWith(color: PremiumColors.gray600),
      hintStyle: PremiumTypography.bodyMedium.copyWith(color: PremiumColors.gray400),
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: PremiumColors.gray100,
      selectedColor: PremiumColors.primary100,
      labelStyle: PremiumTypography.labelMedium,
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumSpacing.md,
        vertical: PremiumSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusSmall),
      ),
    ),
    
    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: PremiumColors.surfaceWhite,
      selectedItemColor: PremiumColors.primary500,
      unselectedItemColor: PremiumColors.gray400,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    
    // Floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: PremiumColors.primary500,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color scheme
    colorScheme: const ColorScheme.dark(
      primary: PremiumColors.primary400,
      onPrimary: PremiumColors.darkBackground,
      secondary: PremiumColors.primary500,
      onSecondary: PremiumColors.darkBackground,
      error: PremiumColors.error500,
      onError: Colors.white,
      surface: PremiumColors.darkSurface,
      onSurface: PremiumColors.darkText,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: PremiumColors.darkBackground,
    
    // App Bar
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: PremiumColors.darkSurface,
      foregroundColor: PremiumColors.darkText,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: PremiumTypography.headingMedium.copyWith(
        color: PremiumColors.darkText,
      ),
    ),
    
    // Card
    cardTheme: CardThemeData(
      elevation: 0,
      color: PremiumColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusXXLarge),
      ),
      margin: const EdgeInsets.all(0),
    ),
    
    // Text theme
    textTheme: TextTheme(
      displayLarge: PremiumTypography.displayLarge.copyWith(color: PremiumColors.darkText),
      displayMedium: PremiumTypography.displayMedium.copyWith(color: PremiumColors.darkText),
      displaySmall: PremiumTypography.displaySmall.copyWith(color: PremiumColors.darkText),
      headlineLarge: PremiumTypography.headingLarge.copyWith(color: PremiumColors.darkText),
      headlineMedium: PremiumTypography.headingMedium.copyWith(color: PremiumColors.darkText),
      headlineSmall: PremiumTypography.headingSmall.copyWith(color: PremiumColors.darkText),
      bodyLarge: PremiumTypography.bodyLarge.copyWith(color: PremiumColors.darkTextSecondary),
      bodyMedium: PremiumTypography.bodyMedium.copyWith(color: PremiumColors.darkTextSecondary),
      bodySmall: PremiumTypography.bodySmall.copyWith(color: PremiumColors.gray500),
      labelLarge: PremiumTypography.labelLarge.copyWith(color: PremiumColors.darkText),
      labelMedium: PremiumTypography.labelMedium.copyWith(color: PremiumColors.darkTextSecondary),
      labelSmall: PremiumTypography.labelSmall.copyWith(color: PremiumColors.gray500),
    ),
    
    // Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: PremiumColors.primary500,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, PremiumSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumSpacing.radiusLarge),
        ),
        textStyle: PremiumTypography.labelLarge,
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PremiumColors.darkSurfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusMedium),
        borderSide: const BorderSide(color: PremiumColors.darkBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusMedium),
        borderSide: const BorderSide(color: PremiumColors.darkBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusMedium),
        borderSide: const BorderSide(color: PremiumColors.primary400, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusMedium),
        borderSide: const BorderSide(color: PremiumColors.error500, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PremiumSpacing.lg,
        vertical: PremiumSpacing.md,
      ),
      labelStyle: PremiumTypography.bodyMedium.copyWith(color: PremiumColors.gray500),
      hintStyle: PremiumTypography.bodyMedium.copyWith(color: PremiumColors.gray600),
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: PremiumColors.darkSurfaceElevated,
      selectedColor: PremiumColors.primary900,
      labelStyle: PremiumTypography.labelMedium.copyWith(color: PremiumColors.darkText),
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumSpacing.md,
        vertical: PremiumSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumSpacing.radiusSmall),
      ),
    ),
    
    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: PremiumColors.darkSurface,
      selectedItemColor: PremiumColors.primary400,
      unselectedItemColor: PremiumColors.gray600,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    
    // Floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: PremiumColors.primary500,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );
}

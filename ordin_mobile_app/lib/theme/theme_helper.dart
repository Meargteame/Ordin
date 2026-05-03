import 'package:flutter/material.dart';

class ThemeHelper {
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  static Color backgroundColor(BuildContext context) {
    return isDark(context) ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA);
  }
  
  static Color cardColor(BuildContext context) {
    return isDark(context) ? const Color(0xFF1F1F1F) : Colors.white;
  }
  
  static Color surfaceColor(BuildContext context) {
    return isDark(context) ? const Color(0xFF1A1A1A) : Colors.white;
  }
  
  static Color borderColor(BuildContext context) {
    return isDark(context) ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB);
  }
  
  static Color textPrimary(BuildContext context) {
    return isDark(context) ? Colors.white : const Color(0xFF1F2937);
  }
  
  static Color textSecondary(BuildContext context) {
    return isDark(context) ? const Color(0xFFA0A0A0) : const Color(0xFF6B7280);
  }
  
  static Color textTertiary(BuildContext context) {
    return isDark(context) ? const Color(0xFF707070) : const Color(0xFF9CA3AF);
  }
  
  static Color primaryColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }
  
  static BoxShadow cardShadow(BuildContext context) {
    return BoxShadow(
      color: Colors.black.withOpacity(isDark(context) ? 0.3 : 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    );
  }
  
  static BoxDecoration cardDecoration(BuildContext context, {Color? customColor}) {
    return BoxDecoration(
      color: customColor ?? cardColor(context),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor(context)),
      boxShadow: [cardShadow(context)],
    );
  }
}

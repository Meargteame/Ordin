# Sub-Screens Theme Update Guide

## Pattern to Follow

For each sub-screen, make these changes:

### 1. Add Imports
```dart
import '../theme/theme_helper.dart';
import '../theme/ordin_theme.dart';
```

### 2. Replace Common Colors

| Old Color | New Replacement |
|-----------|----------------|
| `const Color(0xFFF8F9FA)` (background) | `ThemeHelper.backgroundColor(context)` |
| `Colors.white` (cards) | `ThemeHelper.cardColor(context)` |
| `const Color(0xFF1F2937)` (primary text) | `ThemeHelper.textPrimary(context)` |
| `const Color(0xFF6B7280)` (secondary text) | `ThemeHelper.textSecondary(context)` |
| `const Color(0xFF9CA3AF)` (tertiary text) | `ThemeHelper.textTertiary(context)` |
| `const Color(0xFFE5E7EB)` (borders) | `ThemeHelper.borderColor(context)` |
| `const Color(0xFF2563EB)` (primary blue) | `OrdinTheme.primary` |
| `const Color(0xFF10B981)` (success green) | `OrdinTheme.success` |
| `const Color(0xFFF59E0B)` (warning amber) | `OrdinTheme.warning` |
| `const Color(0xFFEF4444)` (error red) | `OrdinTheme.error` |

### 3. Replace Card Decorations
```dart
// OLD
decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
),

// NEW
decoration: ThemeHelper.cardDecoration(context),
```

### 4. Replace FAB Colors
```dart
// OLD
FloatingActionButton(
  backgroundColor: const Color(0xFF2563EB),
  ...
)

// NEW
FloatingActionButton(
  backgroundColor: OrdinTheme.primary,
  ...
)
```

## Sub-Screens to Update

1. ✅ goals_screen.dart
2. ✅ projects_screen.dart
3. ✅ notes_screen.dart
4. ✅ time_tracking_screen.dart
5. ✅ calendar_screen.dart
6. ✅ health_screen.dart
7. ✅ finance_screen.dart
8. ✅ relationships_screen.dart
9. ✅ learning_screen.dart
10. ✅ analytics_screen.dart
11. ✅ journal_screen.dart

## Quick Update Commands

For each file, run these replacements in order:
1. Add imports at top
2. Replace all `const Color(0xFFF8F9FA)` with `ThemeHelper.backgroundColor(context)`
3. Replace all `Colors.white` (in cards) with `ThemeHelper.cardColor(context)`
4. Replace all text colors with ThemeHelper equivalents
5. Replace BoxDecoration patterns with `ThemeHelper.cardDecoration(context)`
6. Replace brand colors with OrdinTheme constants

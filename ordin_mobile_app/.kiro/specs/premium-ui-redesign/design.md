# Design Document: Premium UI/UX Redesign

## Overview

This design document specifies the technical implementation for transforming the Ordin mobile app from a generic productivity app into a premium, distinctive product with a unique visual identity. The redesign addresses current overflow issues, establishes a comprehensive design system, and creates a cohesive premium experience inspired by industry-leading apps like Things 3, Notion, Linear, Arc Browser, and Superhuman.

### Design Goals

1. **Premium Visual Identity**: Create a distinctive look that sets Ordin apart from generic productivity apps
2. **Robust Layout System**: Eliminate all overflow errors and ensure graceful handling of edge cases
3. **Delightful Interactions**: Implement smooth animations, micro-interactions, and haptic feedback
4. **Comprehensive Design System**: Establish reusable components, patterns, and guidelines
5. **Dark Mode Excellence**: Provide a premium dark mode experience with proper contrast and aesthetics
6. **Performance**: Maintain 60fps animations and smooth transitions throughout

### Technology Stack

- **Framework**: Flutter 3.x with Material 3
- **Typography**: Google Fonts (Inter family)
- **State Management**: Provider/Riverpod for theme and animation state
- **Animation**: Flutter's built-in animation framework with custom curves
- **Haptics**: flutter_vibrate or haptic_feedback package
- **Icons**: Custom icon set with consistent stroke width (2px)

## Architecture

### Design System Architecture

The design system will be implemented as a centralized theme system with the following structure:

```
lib/theme/
├── app_theme.dart              # Main theme configuration
├── premium_colors.dart         # Color palette definitions
├── premium_typography.dart     # Typography scale
├── premium_shadows.dart        # Shadow and elevation styles
├── premium_spacing.dart        # Spacing constants
├── premium_animations.dart     # Animation curves and durations
└── dark_theme.dart            # Dark mode overrides
```


### Component Architecture

Components will follow a layered architecture:

1. **Atomic Components**: Basic building blocks (buttons, inputs, chips, badges)
2. **Molecular Components**: Combinations of atomic components (card headers, form groups)
3. **Organism Components**: Complex UI sections (stat panels, habit cards, task lists)
4. **Screen Templates**: Full screen layouts with consistent structure

```
lib/widgets/premium/
├── atoms/
│   ├── premium_button.dart
│   ├── premium_input.dart
│   ├── premium_chip.dart
│   └── premium_badge.dart
├── molecules/
│   ├── premium_card.dart
│   ├── premium_stat_card.dart
│   └── premium_empty_state.dart
├── organisms/
│   ├── premium_task_card.dart
│   ├── premium_habit_card.dart
│   └── premium_bottom_nav.dart
└── animations/
    ├── micro_interactions.dart
    ├── page_transitions.dart
    └── loading_animations.dart
```

### Animation System Architecture

Animations will be managed through a centralized system:

- **Animation Controller Pool**: Reusable animation controllers for performance
- **Custom Curves**: Premium easing functions (ease-out-expo, ease-in-out-cubic)
- **Gesture Recognizers**: Custom gesture handlers for swipe, long-press, and pull-to-refresh
- **Haptic Integration**: Coordinated haptic feedback with visual animations

### State Management for Theme

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _hapticsEnabled = true;
  
  ThemeMode get themeMode => _themeMode;
  bool get hapticsEnabled => _hapticsEnabled;
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    notifyListeners();
  }
  
  void setHaptics(bool enabled) {
    _hapticsEnabled = enabled;
    notifyListeners();
  }
}
```


## Components and Interfaces

### 1. Premium Color System

**PremiumColors Class**

```dart
class PremiumColors {
  // Primary Brand Colors (Deep Blue)
  static const primary50 = Color(0xFFEFF6FF);
  static const primary100 = Color(0xFFDBEAFE);
  static const primary200 = Color(0xFFBFDBFE);
  static const primary300 = Color(0xFF93C5FD);
  static const primary400 = Color(0xFF60A5FA);
  static const primary500 = Color(0xFF3B82F6);  // Main brand color
  static const primary600 = Color(0xFF2563EB);
  static const primary700 = Color(0xFF1D4ED8);
  static const primary800 = Color(0xFF1E40AF);
  static const primary900 = Color(0xFF1E3A8A);
  
  // Neutral Grays
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
  
  // Semantic Colors
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFF34D399);
  static const successDark = Color(0xFF059669);
  
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFBBF24);
  static const warningDark = Color(0xFFD97706);
  
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFF87171);
  static const errorDark = Color(0xFFDC2626);
  
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFF60A5FA);
  static const infoDark = Color(0xFF2563EB);
  
  // Dark Mode Colors
  static const darkBackground = Color(0xFF0F0F0F);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkSurfaceElevated = Color(0xFF242424);
  static const darkBorder = Color(0xFF2A2A2A);
}
```

### 2. Premium Typography System

**PremiumTypography Class**

```dart
class PremiumTypography {
  static const String fontFamily = 'Inter';
  
  // Display Styles (Hero text)
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    height: 1.1,
  );
  
  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.2,
  );
  
  static TextStyle displaySmall = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.2,
  );
  
  // Heading Styles
  static TextStyle headingLarge = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
  );
  
  static TextStyle headingMedium = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.4,
  );
  
  static TextStyle headingSmall = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );
  
  // Body Styles
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  // Label Styles (UI elements)
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.4,
  );
  
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.4,
  );
  
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.4,
  );
}
```


### 3. Premium Spacing System

**PremiumSpacing Class**

```dart
class PremiumSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;
  static const double giant = 64.0;
  
  // Semantic spacing
  static const double cardPadding = 24.0;
  static const double screenPadding = 20.0;
  static const double sectionSpacing = 32.0;
  static const double itemSpacing = 12.0;
}
```

### 4. Premium Shadow System

**PremiumShadows Class**

```dart
class PremiumShadows {
  // Elevation Low (Cards at rest)
  static List<BoxShadow> elevationLow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Elevation Medium (Interactive cards)
  static List<BoxShadow> elevationMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Elevation High (Modals, floating elements)
  static List<BoxShadow> elevationHigh = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 30,
      offset: const Offset(0, 15),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Elevation Extra High (Dialogs, overlays)
  static List<BoxShadow> elevationExtraHigh = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 40,
      offset: const Offset(0, 20),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
  
  // Colored shadows for premium effect
  static List<BoxShadow> coloredShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.15),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
  
  // Dark mode shadows (lighter, more subtle)
  static List<BoxShadow> darkElevationLow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> darkElevationMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
```

### 5. Premium Animation System

**PremiumAnimations Class**

```dart
class PremiumAnimations {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  // Custom curves
  static const Curve easeOutExpo = Curves.easeOutExpo;
  static const Curve easeInOutCubic = Curves.easeInOutCubic;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve bounceOut = Curves.bounceOut;
  
  // Micro-interaction animations
  static const Duration checkboxToggle = Duration(milliseconds: 200);
  static const Duration buttonPress = Duration(milliseconds: 100);
  static const Duration cardPress = Duration(milliseconds: 150);
  
  // Page transitions
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration modalTransition = Duration(milliseconds: 300);
  
  // Loading animations
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Duration skeletonPulse = Duration(milliseconds: 1200);
}
```


### 6. Premium Card Component

**Interface**

```dart
class PremiumCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? shadows;
  final Border? border;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool interactive;
  final bool completed;
  
  const PremiumCard({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.shadows,
    this.border,
    this.onTap,
    this.onLongPress,
    this.interactive = false,
    this.completed = false,
  }) : super(key: key);
}
```

**Behavior**
- Default border radius: 20px
- Default padding: 24px
- Interactive cards scale down to 0.98 on press
- Completed cards show success border (2px, success color with 0.3 opacity)
- Non-interactive cards have elevation low, interactive cards have elevation medium
- Press animation duration: 150ms with ease-out-expo curve

### 7. Premium Button Component

**Interface**

```dart
enum PremiumButtonStyle {
  primary,    // Gradient fill, white text
  secondary,  // Outlined, colored text
  ghost,      // No border, colored text
  danger,     // Red gradient fill
}

class PremiumButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final PremiumButtonStyle style;
  final bool loading;
  final bool fullWidth;
  
  const PremiumButton({
    Key? key,
    required this.text,
    this.icon,
    this.onPressed,
    this.style = PremiumButtonStyle.primary,
    this.loading = false,
    this.fullWidth = false,
  }) : super(key: key);
}
```

**Specifications**
- Height: 52px
- Border radius: 16px
- Font: labelLarge (14px, semibold, 0.2 letter-spacing)
- Primary: Linear gradient (primary500 to primary600)
- Press animation: Scale to 0.96, duration 100ms
- Loading state: Spinner replaces text, button disabled
- Haptic feedback: Light impact on press

### 8. Premium Input Component

**Interface**

```dart
class PremiumInput extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  
  const PremiumInput({
    Key? key,
    this.label,
    this.placeholder,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
  }) : super(key: key);
}
```

**Specifications**
- Height: 52px (single line)
- Border radius: 14px
- Border: 1.5px solid gray300 (unfocused), primary500 (focused), error (error state)
- Background: gray50 (light mode), darkSurface (dark mode)
- Padding: 16px horizontal, 14px vertical
- Label: Floating label animation (300ms)
- Focus animation: Border color transition + subtle shadow
- Error state: Red border + error message below (bodySmall, error color)


### 9. Premium Bottom Navigation

**Interface**

```dart
class PremiumBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PremiumNavItem> items;
  
  const PremiumBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);
}

class PremiumNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  
  const PremiumNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
```

**Specifications**
- Height: 72px
- Background: Surface color with blur effect (glassmorphism)
- Top border: 1px solid with 0.1 opacity
- Shadow: Elevation medium
- Active indicator: Pill-shaped background (primary color with 0.12 opacity)
- Icon size: 24px
- Active icon animation: Scale from 1.0 to 1.15 with bounce curve (300ms)
- Label: labelSmall, only shown for active tab
- Tab switch animation: Cross-fade between icons (200ms)

### 10. Premium Empty State Component

**Interface**

```dart
class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? accentColor;
  
  const PremiumEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
    this.accentColor,
  }) : super(key: key);
}
```

**Specifications**
- Icon size: 72px
- Icon container: 120px circle with gradient background (accent color with 0.08-0.12 opacity)
- Title: headingLarge
- Subtitle: bodyMedium with secondary text color
- Spacing: 24px between icon and title, 12px between title and subtitle
- Action button: PremiumButton with primary style
- Overall padding: 48px vertical

### 11. Premium Stat Card Component

**Interface**

```dart
class PremiumStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? progress;
  final String? trend;
  
  const PremiumStatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.progress,
    this.trend,
  }) : super(key: key);
}
```

**Specifications**
- Padding: 22px
- Border radius: 24px
- Background: Surface white
- Shadow: Elevation low
- Icon container: 48px with gradient background (color with 0.12-0.08 opacity), border radius 14px
- Value: displaySmall (28px, bold)
- Label: labelMedium
- Progress bar: 5px height, rounded, color with 0.1 opacity background
- Progress animation: 500ms ease-out-expo when value changes
- Trend indicator: Small arrow icon with percentage (success/error color)


### 12. Premium Task Card Component

**Interface**

```dart
class PremiumTaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool enableSwipeActions;
  
  const PremiumTaskCard({
    Key? key,
    required this.task,
    required this.onToggle,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.enableSwipeActions = true,
  }) : super(key: key);
}
```

**Specifications**
- Border radius: 24px
- Padding: 24px
- Shadow: Elevation medium (completed: colored shadow with success color)
- Border: 2px success color with 0.3 opacity when completed
- Checkbox: 36px circle, gradient fill when checked, 3px border when unchecked
- Checkbox animation: Scale from 0.8 to 1.0 with bounce curve (200ms)
- Title: headingSmall (18px, semibold)
- Description: bodyMedium, max 2 lines with ellipsis
- Time badge: Gradient background, timer icon, labelMedium
- Swipe left: Reveals edit and delete buttons (red background for delete)
- Swipe right: Quick complete action (swipe threshold: 40% of width)
- Haptic feedback: Light impact on toggle, warning impact on delete reveal

### 13. Premium Habit Card Component

**Interface**

```dart
class PremiumHabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  const PremiumHabitCard({
    Key? key,
    required this.habit,
    required this.onToggle,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);
}
```

**Specifications**
- Border radius: 24px
- Padding: 24px
- Shadow: Elevation medium (completed: colored shadow with success color)
- Border: 2px success color with 0.3 opacity when completed
- Checkbox: 36px circle, success gradient when checked
- Streak badge: Gradient background (warning color), fire icon, bold number
- Streak animation: Pulse effect when streak increases (scale 1.0 to 1.2 to 1.0, 400ms)
- Category chips: Small rounded badges with category icon and color
- Long press: Shows detailed stats modal with animations

### 14. Premium Progress Indicator Component

**Interface**

```dart
class PremiumProgressIndicator extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final bool showPercentage;
  final bool animated;
  
  const PremiumProgressIndicator({
    Key? key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.color,
    this.showPercentage = true,
    this.animated = true,
  }) : super(key: key);
}
```

**Specifications**
- Type: Circular progress ring
- Background: Gray with 0.1 opacity
- Foreground: Gradient (primary to secondary) or solid color
- Animation: Progress changes animate over 400ms with ease-out-expo
- Percentage label: displaySmall, centered
- Stroke cap: Round
- Rotation: Starts at -90 degrees (top)


### 15. Premium Loading Skeleton Component

**Interface**

```dart
class PremiumSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool shimmer;
  
  const PremiumSkeleton({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.shimmer = true,
  }) : super(key: key);
}

class PremiumSkeletonCard extends StatelessWidget {
  final int lines;
  final bool showAvatar;
  
  const PremiumSkeletonCard({
    Key? key,
    this.lines = 3,
    this.showAvatar = false,
  }) : super(key: key);
}
```

**Specifications**
- Base color: Gray200 (light mode), darkSurface (dark mode)
- Shimmer gradient: White with 0.0 to 0.5 to 0.0 opacity
- Shimmer animation: 1500ms linear, repeating
- Shimmer direction: Left to right
- Skeleton card: Matches actual card layout with placeholder rectangles
- Fade-in: When real content loads, fade from skeleton to content (300ms)

## Data Models

### Theme Configuration Model

```dart
class ThemeConfig {
  final ThemeMode mode;
  final bool hapticsEnabled;
  final bool systemTheme;
  final String accentColor;
  
  ThemeConfig({
    this.mode = ThemeMode.system,
    this.hapticsEnabled = true,
    this.systemTheme = true,
    this.accentColor = 'blue',
  });
  
  Map<String, dynamic> toJson() => {
    'mode': mode.toString(),
    'hapticsEnabled': hapticsEnabled,
    'systemTheme': systemTheme,
    'accentColor': accentColor,
  };
  
  factory ThemeConfig.fromJson(Map<String, dynamic> json) => ThemeConfig(
    mode: ThemeMode.values.firstWhere(
      (e) => e.toString() == json['mode'],
      orElse: () => ThemeMode.system,
    ),
    hapticsEnabled: json['hapticsEnabled'] ?? true,
    systemTheme: json['systemTheme'] ?? true,
    accentColor: json['accentColor'] ?? 'blue',
  );
}
```

### Animation State Model

```dart
class AnimationState {
  final bool isAnimating;
  final String? currentAnimation;
  final DateTime? startTime;
  
  AnimationState({
    this.isAnimating = false,
    this.currentAnimation,
    this.startTime,
  });
  
  AnimationState copyWith({
    bool? isAnimating,
    String? currentAnimation,
    DateTime? startTime,
  }) => AnimationState(
    isAnimating: isAnimating ?? this.isAnimating,
    currentAnimation: currentAnimation ?? this.currentAnimation,
    startTime: startTime ?? this.startTime,
  );
}
```

### Gesture State Model

```dart
class GestureState {
  final Offset? dragStart;
  final Offset? dragCurrent;
  final double dragDistance;
  final GestureType? activeGesture;
  
  GestureState({
    this.dragStart,
    this.dragCurrent,
    this.dragDistance = 0,
    this.activeGesture,
  });
}

enum GestureType {
  swipeLeft,
  swipeRight,
  longPress,
  pullToRefresh,
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Text Overflow Handling

*For any* text content that exceeds its container width, the UI component SHALL either truncate with ellipsis, wrap to multiple lines, or provide scrolling without causing layout overflow errors.

**Validates: Requirements 3.1, 3.2**

### Property 2: Tag Layout Flexibility

*For any* number of tags or labels in a card component, the layout SHALL either wrap to multiple lines or provide horizontal scrolling without breaking the card layout.

**Validates: Requirements 3.3**

### Property 3: Scrollable Content Handling

*For any* screen where content height exceeds viewport height, the screen SHALL provide smooth scrolling without layout breaks or visual glitches.

**Validates: Requirements 3.4**

### Property 4: Maximum Length Text Field Validation

*For any* text input field with a maximum length constraint, entering text at maximum length SHALL not cause overflow or layout issues.

**Validates: Requirements 3.5**

### Property 5: Responsive Layout Adaptation

*For any* screen size or orientation change, all layouts SHALL adapt gracefully without content overflow or broken layouts.

**Validates: Requirements 3.6**

### Property 6: Interactive Card Feedback

*For any* interactive card component, pressing or hovering SHALL provide immediate visual feedback (scale, opacity, or shadow change).

**Validates: Requirements 4.4**

### Property 7: Status Visual Indication

*For any* card containing status information, different statuses SHALL have visually distinct colored accents or borders.

**Validates: Requirements 4.7**

### Property 8: Checkbox Toggle Animation

*For any* checkbox toggle action, the checkmark SHALL animate with scale and fade effects completing within 150-500ms.

**Validates: Requirements 5.1**

### Property 9: Completion Feedback

*For any* task or habit completion action, the system SHALL provide celebratory visual feedback (scale bounce, color change, or particle effect).

**Validates: Requirements 5.2**

### Property 10: Screen Navigation Transitions

*For any* navigation between two screens, the transition SHALL use smooth fade or slide animations.

**Validates: Requirements 5.3**

### Property 11: Card Press Feedback

*For any* pressable card, pressing SHALL provide immediate visual feedback completing within 150ms.

**Validates: Requirements 5.4**

### Property 12: Loading State Animation

*For any* loading state, the system SHALL display a premium skeleton loader or custom animation.

**Validates: Requirements 5.5**

### Property 13: Micro-Interaction Timing

*For any* micro-interaction animation, the animation SHALL complete within 150ms to 500ms.

**Validates: Requirements 5.6**

### Property 14: Pull-to-Refresh Animation

*For any* pull-to-refresh gesture on a scrollable screen, the system SHALL provide smooth elastic animation.

**Validates: Requirements 5.7**

### Property 15: Toggle Haptic Feedback

*For any* task or habit toggle action, the system SHALL provide light haptic feedback when haptics are enabled.

**Validates: Requirements 6.1**

### Property 16: Destructive Action Haptic

*For any* destructive action (delete, remove), the system SHALL provide warning haptic feedback when haptics are enabled.

**Validates: Requirements 6.3**

### Property 17: Milestone Haptic Feedback

*For any* milestone achievement, the system SHALL provide success haptic feedback when haptics are enabled.

**Validates: Requirements 6.4**

### Property 18: Haptic Settings Control

*For any* haptic feedback trigger, the feedback SHALL only occur when the haptics setting is enabled, and SHALL not occur when disabled.

**Validates: Requirements 6.5**

### Property 19: Empty State Display

*For any* screen with no content, the system SHALL display an empty state with a large styled icon (64-80px).

**Validates: Requirements 7.1**

### Property 20: Empty State Call-to-Action

*For any* empty state where an action is applicable, the empty state SHALL include a clear call-to-action button.

**Validates: Requirements 7.5**

### Property 21: Tab Selection Animation

*For any* bottom navigation tab selection, the icon SHALL animate with scale or color transition.

**Validates: Requirements 8.2**

### Property 22: Active Tab Indicator

*For any* bottom navigation state, the active tab SHALL have a visible floating indicator or background highlight.

**Validates: Requirements 8.3**

### Property 23: Tab Switch Transition

*For any* tab switch action, the bottom navigation SHALL provide smooth transition animations.

**Validates: Requirements 8.6**

### Property 24: Form Input Focus State

*For any* form input receiving focus, the input SHALL display a colored border or shadow.

**Validates: Requirements 9.3**

### Property 25: Form Input Error State

*For any* form input containing an error, the input SHALL display error state with semantic color and error message.

**Validates: Requirements 9.4**

### Property 26: Form Input Focus Animation

*For any* form input focus or blur action, the transition SHALL animate smoothly.

**Validates: Requirements 9.6**


### Property 27: Dark Mode Surface Colors

*For any* surface element when dark mode is enabled, the element SHALL use dark background colors (near-black, not pure black).

**Validates: Requirements 10.2**

### Property 28: Dark Mode Shadow Adjustment

*For any* shadow when dark mode is enabled, the shadow SHALL use lighter colors with reduced opacity compared to light mode.

**Validates: Requirements 10.3**

### Property 29: Dark Mode Semantic Colors

*For any* semantic color (success, warning, error, info) when dark mode is enabled, the color SHALL maintain its semantic meaning with adjusted brightness.

**Validates: Requirements 10.4**

### Property 30: Dark Mode Toggle Functionality

*For any* dark mode toggle action in settings, the app theme SHALL switch between light and dark modes.

**Validates: Requirements 10.5**

### Property 31: System Theme Preference

*For any* system dark mode preference change, the app SHALL respond by updating its theme when system theme is enabled.

**Validates: Requirements 10.6**

### Property 32: Dark Mode Transition Animation

*For any* dark mode toggle action, the theme transition SHALL animate smoothly.

**Validates: Requirements 10.7**

### Property 33: Loading Skeleton Layout Match

*For any* loading state, the skeleton screen SHALL match the layout structure of the loaded content.

**Validates: Requirements 11.1**

### Property 34: Loading Skeleton Spacing Consistency

*For any* loading skeleton, the spacing and structure SHALL match the loaded content.

**Validates: Requirements 11.3**

### Property 35: Progressive Loading Fade-In

*For any* progressively loaded content, the content SHALL fade in smoothly as it becomes available.

**Validates: Requirements 11.4**

### Property 36: Forward Navigation Animation

*For any* forward navigation action, the transition SHALL use slide-from-right or fade animation.

**Validates: Requirements 13.1**

### Property 37: Backward Navigation Animation

*For any* backward navigation action, the transition SHALL use slide-to-right or fade animation.

**Validates: Requirements 13.2**

### Property 38: Screen Transition Timing

*For any* screen transition, the animation SHALL complete within 300ms to 400ms.

**Validates: Requirements 13.3**

### Property 39: Modal Opening Animation

*For any* modal or dialog opening action, the transition SHALL use scale-up and fade animation.

**Validates: Requirements 13.4**

### Property 40: Modal Closing Animation

*For any* modal or dialog closing action, the transition SHALL use scale-down and fade animation.

**Validates: Requirements 13.5**

### Property 41: Transition Performance

*For any* screen or modal transition, the animation SHALL maintain 60fps performance.

**Validates: Requirements 13.6**

### Property 42: Progress Indicator Animation

*For any* progress display, the progress bar SHALL animate smoothly when showing progress.

**Validates: Requirements 14.1**

### Property 43: Progress Change Animation Timing

*For any* progress value change, the animation SHALL transition smoothly over 300ms to 500ms.

**Validates: Requirements 14.3**

### Property 44: Stat Update Animation

*For any* stat card value update, the number SHALL animate with a count-up effect.

**Validates: Requirements 15.6**

### Property 45: Swipe Left Action Reveal

*For any* task or habit card, swiping left SHALL reveal action buttons (edit, delete).

**Validates: Requirements 16.1**

### Property 46: Swipe Right Completion

*For any* task or habit card, swiping right SHALL mark it as complete.

**Validates: Requirements 16.2**

### Property 47: Long Press Context Menu

*For any* card with long-press enabled, long-pressing SHALL show a context menu or detailed view.

**Validates: Requirements 16.3**

### Property 48: Pull-to-Refresh Trigger

*For any* scrollable screen with pull-to-refresh enabled, pulling down SHALL trigger refresh.

**Validates: Requirements 16.4**

### Property 49: Gesture Visual Feedback

*For any* gesture recognition (swipe, long-press, pull), the system SHALL provide visual feedback during the gesture.

**Validates: Requirements 16.5**

### Property 50: Gesture Animation Timing

*For any* gesture animation, the animation SHALL complete within 200ms to 400ms.

**Validates: Requirements 16.6**

### Property 51: Color Contrast Accessibility

*For any* color combination used in the UI, the combination SHALL meet WCAG AA contrast requirements (4.5:1 for normal text, 3:1 for large text).

**Validates: Requirements 17.4**

### Property 52: Responsive Typography Scaling

*For any* device size change, font sizes SHALL scale appropriately to maintain readability.

**Validates: Requirements 18.5**

### Property 53: Interactive Element Shadow Elevation

*For any* interactive element on hover or press, the shadow elevation SHALL increase.

**Validates: Requirements 19.5**

### Property 54: Onboarding Page Transitions

*For any* onboarding page navigation, the transition SHALL be smooth.

**Validates: Requirements 20.2**

### Property 55: Onboarding Screen CTA Buttons

*For any* onboarding screen, the screen SHALL include a clear call-to-action button.

**Validates: Requirements 20.5**


## Error Handling

### Layout Overflow Errors

**Strategy**: Implement defensive layout techniques to prevent overflow

1. **Text Overflow Protection**
   - Use `Flexible` and `Expanded` widgets appropriately
   - Apply `overflow: TextOverflow.ellipsis` to all text widgets that could exceed bounds
   - Set `maxLines` on text widgets where appropriate
   - Use `LayoutBuilder` to calculate available space before rendering

2. **Dynamic Content Handling**
   - Wrap chip/tag lists in `Wrap` widgets with proper spacing
   - Provide horizontal `ListView` for scrollable tag collections
   - Use `SingleChildScrollView` for content that may exceed viewport

3. **Responsive Constraints**
   - Use `ConstrainedBox` with `maxWidth` for cards and containers
   - Implement `MediaQuery` checks for screen size adaptations
   - Test with various screen sizes (small phones to tablets)

### Animation Errors

**Strategy**: Graceful degradation and error recovery

1. **Animation Controller Management**
   - Always dispose animation controllers in `dispose()` method
   - Check `mounted` state before calling `setState()` after animations
   - Use `try-catch` blocks around animation triggers
   - Implement animation controller pooling to prevent memory leaks

2. **Performance Degradation**
   - Monitor frame rates using Flutter DevTools
   - Reduce animation complexity if frame drops detected
   - Provide option to disable animations in accessibility settings
   - Use `RepaintBoundary` to isolate expensive animations

### Theme Switching Errors

**Strategy**: Atomic theme updates with fallback

1. **Theme Transition Safety**
   - Wrap theme changes in `try-catch` blocks
   - Validate theme configuration before applying
   - Provide fallback to system theme if custom theme fails
   - Persist theme preference to prevent loss on app restart

2. **Dark Mode Edge Cases**
   - Ensure all colors have dark mode variants defined
   - Test all screens in both light and dark modes
   - Handle system theme changes while app is running
   - Validate contrast ratios programmatically

### Haptic Feedback Errors

**Strategy**: Silent failure with logging

1. **Platform Compatibility**
   - Check platform support before triggering haptics
   - Wrap haptic calls in `try-catch` blocks
   - Log haptic failures for debugging
   - Provide visual-only feedback as fallback

2. **Permission Handling**
   - Check haptic permissions on Android
   - Handle permission denial gracefully
   - Don't block UI on haptic failures

### Gesture Recognition Errors

**Strategy**: Conflict resolution and priority system

1. **Gesture Conflicts**
   - Define gesture priority hierarchy (e.g., swipe > tap)
   - Use `GestureDetector` with proper `behavior` settings
   - Implement gesture arena resolution for competing gestures
   - Provide visual feedback during gesture recognition

2. **Edge Cases**
   - Handle rapid gesture sequences
   - Prevent gesture triggers during animations
   - Cancel gestures if user navigates away
   - Reset gesture state on screen changes


# Implementation Plan: Premium UI/UX Redesign

## Overview

This implementation plan transforms the Ordin mobile app from a generic productivity app into a premium product with a distinctive visual identity. The plan follows a bottom-up approach: establishing the design system foundation first, then building reusable components, and finally applying them to screen redesigns. Each task builds incrementally to ensure continuous integration and early validation.

## Tasks

- [ ] 1. Establish design system foundation
  - [ ] 1.1 Create premium color system
    - Create `lib/theme/premium_colors.dart` with complete color palette
    - Define primary colors (9 shades), neutral grays (9 shades), semantic colors (success, warning, error, info)
    - Define dark mode color variants
    - _Requirements: 1.1, 1.2, 1.8, 17.1, 17.2, 17.3_
  
  - [ ] 1.2 Create premium typography system
    - Create `lib/theme/premium_typography.dart` with Inter font family
    - Define display styles (large, medium, small), heading styles (large, medium, small)
    - Define body styles (large, medium, small) and label styles (large, medium, small)
    - Configure font weights, letter spacing, and line heights
    - _Requirements: 1.3, 2.4, 18.1, 18.2, 18.3, 18.4, 18.6_
  
  - [ ] 1.3 Create premium spacing system
    - Create `lib/theme/premium_spacing.dart` with spacing scale (4px multiples)
    - Define semantic spacing constants (cardPadding, screenPadding, sectionSpacing, itemSpacing)
    - _Requirements: 1.4_
  
  - [ ] 1.4 Create premium shadow system
    - Create `lib/theme/premium_shadows.dart` with elevation levels
    - Define shadows for low, medium, high, and extra-high elevations
    - Define colored shadow utility function
    - Define dark mode shadow variants
    - _Requirements: 1.6, 19.1, 19.2, 19.3, 19.4, 19.6_
  
  - [ ] 1.5 Create premium animation system
    - Create `lib/theme/premium_animations.dart` with duration constants and curves
    - Define fast (150ms), normal (300ms), slow (500ms) durations
    - Define custom curves (easeOutExpo, easeInOutCubic, elasticOut, bounceOut)
    - Define specific animation durations for micro-interactions
    - _Requirements: 1.7, 5.6_
  
  - [ ] 1.6 Create main theme configuration
    - Update `lib/theme/app_theme.dart` to integrate all design system components
    - Configure Material 3 theme with premium colors, typography, and shadows
    - Define light and dark theme data
    - Set border radius values (small: 8px, medium: 12px, large: 16px, extra-large: 24px)
    - _Requirements: 1.5, 1.9_

- [ ] 2. Implement theme management and dark mode
  - [ ] 2.1 Create theme provider
    - Create `lib/providers/theme_provider.dart` with ChangeNotifier
    - Implement theme mode toggling (light, dark, system)
    - Implement haptics enable/disable setting
    - Add theme persistence using shared_preferences
    - _Requirements: 10.5, 10.6, 6.5_
  
  - [ ] 2.2 Create theme configuration model
    - Create `lib/models/theme_config.dart` with ThemeConfig class
    - Implement toJson and fromJson methods for persistence
    - _Requirements: 10.5_
  
  - [ ] 2.3 Integrate theme provider in main app
    - Update `lib/main.dart` to use ThemeProvider
    - Configure MaterialApp with dynamic theme switching
    - Implement smooth theme transition animation
    - _Requirements: 10.7_
  
  - [ ]* 2.4 Write unit tests for theme provider
    - Test theme mode toggling
    - Test haptics setting persistence
    - Test theme configuration serialization
    - _Requirements: 10.5, 10.6_

- [ ] 3. Create atomic premium components
  - [ ] 3.1 Create premium button component
    - Create `lib/widgets/premium/atoms/premium_button.dart`
    - Implement PremiumButtonStyle enum (primary, secondary, ghost, danger)
    - Implement press animation (scale to 0.96, 100ms)
    - Implement loading state with spinner
    - Add haptic feedback on press
    - _Requirements: 1.9, 5.4, 6.1_
  
  - [ ]* 3.2 Write property test for button press animation
    - **Property 11: Card Press Feedback**
    - **Validates: Requirements 5.4**
  
  - [ ] 3.3 Create premium input component
    - Create `lib/widgets/premium/atoms/premium_input.dart`
    - Implement floating label animation
    - Implement focus state with border color transition
    - Implement error state with error message display
    - Handle text overflow with maxLength constraint
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.6, 3.5_
  
  - [ ]* 3.4 Write property test for input focus state
    - **Property 24: Form Input Focus State**
    - **Validates: Requirements 9.3**
  
  - [ ]* 3.5 Write property test for input error state
    - **Property 25: Form Input Error State**
    - **Validates: Requirements 9.4**
  
  - [ ] 3.6 Create premium chip component
    - Create `lib/widgets/premium/atoms/premium_chip.dart`
    - Implement text overflow handling with ellipsis
    - Implement colored background variants
    - Add icon support
    - _Requirements: 3.1, 3.3_
  
  - [ ] 3.7 Create premium badge component
    - Create `lib/widgets/premium/atoms/premium_badge.dart`
    - Implement small rounded badge with gradient background
    - Support icon and text content
    - _Requirements: 1.9_

- [ ] 4. Create molecular premium components
  - [ ] 4.1 Create premium card component
    - Create `lib/widgets/premium/molecules/premium_card.dart`
    - Implement default styling (20px border radius, 24px padding, elevation low)
    - Implement interactive press animation (scale to 0.98, 150ms)
    - Implement completed state with success border
    - Handle flexible layouts to prevent overflow
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 3.6_
  
  - [ ]* 4.2 Write property test for interactive card feedback
    - **Property 6: Interactive Card Feedback**
    - **Validates: Requirements 4.4**
  
  - [ ]* 4.3 Write property test for status visual indication
    - **Property 7: Status Visual Indication**
    - **Validates: Requirements 4.7**
  
  - [ ] 4.4 Create premium stat card component
    - Create `lib/widgets/premium/molecules/premium_stat_card.dart`
    - Implement large bold number display (28px)
    - Implement icon container with gradient background
    - Implement progress bar with animation
    - Implement count-up animation for value changes
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6_
  
  - [ ]* 4.5 Write property test for stat update animation
    - **Property 44: Stat Update Animation**
    - **Validates: Requirements 15.6**
  
  - [ ] 4.6 Create premium empty state component
    - Create `lib/widgets/premium/molecules/premium_empty_state.dart`
    - Implement large styled icon (72px) with gradient background
    - Implement title and subtitle with proper typography
    - Implement call-to-action button
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_
  
  - [ ]* 4.7 Write property test for empty state display
    - **Property 19: Empty State Display**
    - **Validates: Requirements 7.1**
  
  - [ ] 4.8 Create premium progress indicator component
    - Create `lib/widgets/premium/molecules/premium_progress_indicator.dart`
    - Implement circular progress ring with gradient
    - Implement smooth progress animation (400ms ease-out-expo)
    - Implement percentage label display
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_
  
  - [ ]* 4.9 Write property test for progress animation
    - **Property 42: Progress Indicator Animation**
    - **Validates: Requirements 14.1**
  
  - [ ] 4.10 Create premium loading skeleton component
    - Create `lib/widgets/premium/molecules/premium_skeleton.dart`
    - Implement shimmer animation (1500ms linear)
    - Create PremiumSkeletonCard for common layouts
    - Implement fade-in transition when content loads
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_
  
  - [ ]* 4.11 Write property test for skeleton layout match
    - **Property 33: Loading Skeleton Layout Match**
    - **Validates: Requirements 11.1**

- [ ] 5. Checkpoint - Verify design system and components
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Create organism premium components
  - [ ] 6.1 Create premium task card component
    - Create `lib/widgets/premium/organisms/premium_task_card.dart`
    - Implement 36px circular checkbox with gradient fill animation
    - Implement checkbox toggle animation (scale 0.8 to 1.0, bounce, 200ms)
    - Implement text overflow handling for title and description
    - Implement time badge with gradient background
    - Implement swipe-to-reveal actions (edit, delete)
    - Implement swipe-right-to-complete gesture
    - Add haptic feedback for toggle and delete reveal
    - _Requirements: 3.1, 3.2, 5.1, 5.4, 6.1, 6.3, 16.1, 16.2, 16.5_
  
  - [ ]* 6.2 Write property test for checkbox toggle animation
    - **Property 8: Checkbox Toggle Animation**
    - **Validates: Requirements 5.1**
  
  - [ ]* 6.3 Write property test for swipe left action reveal
    - **Property 45: Swipe Left Action Reveal**
    - **Validates: Requirements 16.1**
  
  - [ ]* 6.4 Write property test for swipe right completion
    - **Property 46: Swipe Right Completion**
    - **Validates: Requirements 16.2**
  
  - [ ] 6.5 Create premium habit card component
    - Create `lib/widgets/premium/organisms/premium_habit_card.dart`
    - Implement 36px circular checkbox with success gradient
    - Implement streak badge with fire icon and gradient background
    - Implement streak pulse animation when streak increases
    - Implement category chips with proper wrapping
    - Implement long-press for detailed stats modal
    - Add haptic feedback for toggle and milestone achievements
    - _Requirements: 3.1, 3.3, 5.1, 5.2, 6.1, 6.4, 16.3_
  
  - [ ]* 6.6 Write property test for completion feedback
    - **Property 9: Completion Feedback**
    - **Validates: Requirements 5.2**
  
  - [ ]* 6.7 Write property test for long press context menu
    - **Property 47: Long Press Context Menu**
    - **Validates: Requirements 16.3**
  
  - [ ] 6.8 Create premium bottom navigation component
    - Create `lib/widgets/premium/organisms/premium_bottom_nav.dart`
    - Implement glassmorphism effect with blur
    - Implement active tab pill-shaped indicator
    - Implement icon scale animation on tab switch (1.0 to 1.15, bounce, 300ms)
    - Implement cross-fade between icons (200ms)
    - Implement smooth tab transition animations
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [ ]* 6.9 Write property test for tab selection animation
    - **Property 21: Tab Selection Animation**
    - **Validates: Requirements 8.2**
  
  - [ ]* 6.10 Write property test for active tab indicator
    - **Property 22: Active Tab Indicator**
    - **Validates: Requirements 8.3**

- [ ] 7. Implement animation and gesture systems
  - [ ] 7.1 Create micro-interactions utility
    - Create `lib/widgets/premium/animations/micro_interactions.dart`
    - Implement checkbox toggle animation helper
    - Implement button press animation helper
    - Implement card press animation helper
    - Implement completion celebration animation
    - _Requirements: 5.1, 5.2, 5.4_
  
  - [ ] 7.2 Create page transition animations
    - Create `lib/widgets/premium/animations/page_transitions.dart`
    - Implement slide-from-right transition for forward navigation
    - Implement slide-to-right transition for backward navigation
    - Implement scale-up fade for modal opening
    - Implement scale-down fade for modal closing
    - Ensure 60fps performance with RepaintBoundary
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6_
  
  - [ ]* 7.3 Write property test for forward navigation animation
    - **Property 36: Forward Navigation Animation**
    - **Validates: Requirements 13.1**
  
  - [ ]* 7.4 Write property test for backward navigation animation
    - **Property 37: Backward Navigation Animation**
    - **Validates: Requirements 13.2**
  
  - [ ]* 7.5 Write property test for modal opening animation
    - **Property 39: Modal Opening Animation**
    - **Validates: Requirements 13.4**
  
  - [ ] 7.6 Create haptic feedback service
    - Create `lib/services/haptic_service.dart`
    - Implement light impact for toggles
    - Implement medium impact for completions
    - Implement warning impact for destructive actions
    - Implement success impact for milestones
    - Check platform support and handle errors gracefully
    - Respect haptics enabled setting from ThemeProvider
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ]* 7.7 Write property test for haptic settings control
    - **Property 18: Haptic Settings Control**
    - **Validates: Requirements 6.5**
  
  - [ ] 7.8 Create gesture recognizer utilities
    - Create `lib/widgets/premium/animations/gesture_recognizers.dart`
    - Implement swipe-to-reveal gesture handler
    - Implement swipe-to-complete gesture handler
    - Implement long-press gesture handler
    - Implement pull-to-refresh gesture handler
    - Add visual feedback during gesture recognition
    - _Requirements: 16.1, 16.2, 16.3, 16.4, 16.5, 16.6_
  
  - [ ]* 7.9 Write property test for pull-to-refresh trigger
    - **Property 48: Pull-to-Refresh Trigger**
    - **Validates: Requirements 16.4**

- [ ] 8. Checkpoint - Verify animations and gestures
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Redesign Today screen
  - [ ] 9.1 Update Today screen layout
    - Update `lib/screens/today_screen.dart` with premium design
    - Replace existing cards with PremiumTaskCard and PremiumHabitCard
    - Implement PremiumStatCard for daily progress metrics
    - Implement PremiumEmptyState for no tasks/habits
    - Implement PremiumSkeleton for loading states
    - Add pull-to-refresh with premium animation
    - Ensure all content is scrollable without overflow
    - _Requirements: 3.4, 5.7, 7.1, 7.2, 7.3, 11.1, 16.4_
  
  - [ ]* 9.2 Write property test for scrollable content handling
    - **Property 3: Scrollable Content Handling**
    - **Validates: Requirements 3.4**
  
  - [ ]* 9.3 Write property test for pull-to-refresh animation
    - **Property 14: Pull-to-Refresh Animation**
    - **Validates: Requirements 5.7**

- [ ] 10. Redesign Tasks screen
  - [ ] 10.1 Update Tasks screen layout
    - Update `lib/screens/tasks_screen.dart` with premium design
    - Replace task cards with PremiumTaskCard
    - Implement swipe gestures for task actions
    - Implement PremiumEmptyState for no tasks
    - Implement PremiumProgressIndicator for task completion
    - Add smooth screen transitions
    - Ensure text overflow handling in all task cards
    - _Requirements: 3.1, 3.2, 5.3, 7.1, 14.1, 16.1, 16.2_
  
  - [ ]* 10.2 Write property test for text overflow handling
    - **Property 1: Text Overflow Handling**
    - **Validates: Requirements 3.1, 3.2**
  
  - [ ]* 10.3 Write property test for screen navigation transitions
    - **Property 10: Screen Navigation Transitions**
    - **Validates: Requirements 5.3**

- [ ] 11. Redesign Habits screen
  - [ ] 11.1 Update Habits screen layout
    - Update `lib/screens/habits_screen.dart` with premium design
    - Replace habit cards with PremiumHabitCard
    - Implement streak animations and milestone celebrations
    - Implement PremiumEmptyState for no habits
    - Implement category filter chips with proper wrapping
    - Add haptic feedback for habit completions and milestones
    - _Requirements: 3.3, 5.2, 6.1, 6.4, 7.1_
  
  - [ ]* 11.2 Write property test for tag layout flexibility
    - **Property 2: Tag Layout Flexibility**
    - **Validates: Requirements 3.3**
  
  - [ ]* 11.3 Write property test for milestone haptic feedback
    - **Property 17: Milestone Haptic Feedback**
    - **Validates: Requirements 6.4**

- [ ] 12. Redesign More screen
  - [ ] 12.1 Update More screen layout
    - Update `lib/screens/more_screen.dart` with premium design
    - Implement premium list items with icons and arrows
    - Add dark mode toggle with smooth transition
    - Add haptics toggle setting
    - Implement PremiumCard for grouped settings sections
    - Add premium dividers and spacing
    - _Requirements: 10.5, 10.7, 6.5_
  
  - [ ]* 12.2 Write property test for dark mode toggle
    - **Property 30: Dark Mode Toggle Functionality**
    - **Validates: Requirements 10.5**
  
  - [ ]* 12.3 Write property test for dark mode transition
    - **Property 32: Dark Mode Transition Animation**
    - **Validates: Requirements 10.7**

- [ ] 13. Update bottom navigation
  - [ ] 13.1 Replace bottom navigation with PremiumBottomNav
    - Update `lib/main.dart` or navigation wrapper
    - Replace existing BottomNavigationBar with PremiumBottomNav
    - Configure custom icons for all tabs
    - Implement smooth tab switching animations
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  
  - [ ]* 13.2 Write property test for tab switch transition
    - **Property 23: Tab Switch Transition**
    - **Validates: Requirements 8.6**

- [ ] 14. Update form screens with premium inputs
  - [ ] 14.1 Update task form screen
    - Update `lib/widgets/task_form_screen.dart` with PremiumInput components
    - Replace all text fields with PremiumInput
    - Implement focus state animations
    - Implement error state handling
    - Add PremiumButton for submit action
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.6_
  
  - [ ] 14.2 Update habit form screen
    - Update `lib/widgets/habit_form_screen.dart` with PremiumInput components
    - Replace all text fields with PremiumInput
    - Implement category selection with PremiumChip
    - Add PremiumButton for submit action
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.6_
  
  - [ ]* 14.3 Write property test for form input focus animation
    - **Property 26: Form Input Focus Animation**
    - **Validates: Requirements 9.6**

- [ ] 15. Implement dark mode support across all screens
  - [ ] 15.1 Verify dark mode colors in all components
    - Test all atomic components in dark mode
    - Test all molecular components in dark mode
    - Test all organism components in dark mode
    - Ensure proper contrast ratios (WCAG AA)
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 17.4_
  
  - [ ]* 15.2 Write property test for dark mode surface colors
    - **Property 27: Dark Mode Surface Colors**
    - **Validates: Requirements 10.2**
  
  - [ ]* 15.3 Write property test for dark mode shadow adjustment
    - **Property 28: Dark Mode Shadow Adjustment**
    - **Validates: Requirements 10.3**
  
  - [ ]* 15.4 Write property test for dark mode semantic colors
    - **Property 29: Dark Mode Semantic Colors**
    - **Validates: Requirements 10.4**
  
  - [ ]* 15.5 Write property test for color contrast accessibility
    - **Property 51: Color Contrast Accessibility**
    - **Validates: Requirements 17.4**

- [ ] 16. Fix overflow and layout issues
  - [ ] 16.1 Audit all screens for overflow errors
    - Test all screens with maximum length text
    - Test all screens with numerous tags/chips
    - Test all screens on small devices (iPhone SE size)
    - Fix any remaining overflow issues with Flexible/Expanded widgets
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_
  
  - [ ]* 16.2 Write property test for maximum length text field validation
    - **Property 4: Maximum Length Text Field Validation**
    - **Validates: Requirements 3.5**
  
  - [ ]* 16.3 Write property test for responsive layout adaptation
    - **Property 5: Responsive Layout Adaptation**
    - **Validates: Requirements 3.6**

- [ ] 17. Implement custom iconography
  - [ ] 17.1 Create custom icon set
    - Create `lib/theme/premium_icons.dart` with custom IconData
    - Define icons with consistent 2px stroke width
    - Provide icons in multiple sizes (16px, 20px, 24px, 32px)
    - Create custom icons for primary actions (add, complete, delete, edit)
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_
  
  - [ ] 17.2 Replace all icons with custom iconography
    - Update all screens to use custom icons
    - Update all components to use custom icons
    - Ensure icon style consistency across app
    - _Requirements: 12.5_

- [ ] 18. Polish and performance optimization
  - [ ] 18.1 Optimize animation performance
    - Add RepaintBoundary to expensive animations
    - Profile animations with Flutter DevTools
    - Ensure all animations maintain 60fps
    - Implement animation controller pooling
    - _Requirements: 13.6_
  
  - [ ]* 18.2 Write property test for transition performance
    - **Property 41: Transition Performance**
    - **Validates: Requirements 13.6**
  
  - [ ] 18.3 Optimize loading states
    - Ensure skeleton screens match content layout exactly
    - Implement progressive loading with fade-in
    - Test loading states on slow network
    - _Requirements: 11.1, 11.3, 11.4_
  
  - [ ] 18.4 Test responsive typography
    - Test font scaling on different device sizes
    - Test with system font size adjustments
    - Ensure readability across all sizes
    - _Requirements: 18.5_
  
  - [ ]* 18.5 Write property test for responsive typography scaling
    - **Property 52: Responsive Typography Scaling**
    - **Validates: Requirements 18.5**

- [ ] 19. Final checkpoint - Comprehensive testing
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 20. Create onboarding experience (optional enhancement)
  - [ ] 20.1 Create onboarding screens
    - Create `lib/screens/onboarding_screen.dart`
    - Implement 3-4 onboarding pages with illustrations
    - Implement smooth page transitions
    - Implement progress indicator
    - Implement premium typography and spacing
    - Add celebratory animation on completion
    - _Requirements: 20.1, 20.2, 20.3, 20.4, 20.5, 20.6_
  
  - [ ]* 20.2 Write property test for onboarding page transitions
    - **Property 54: Onboarding Page Transitions**
    - **Validates: Requirements 20.2**
  
  - [ ]* 20.3 Write property test for onboarding CTA buttons
    - **Property 55: Onboarding Screen CTA Buttons**
    - **Validates: Requirements 20.5**

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation and allow for user feedback
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The implementation follows a bottom-up approach: design system → components → screens
- All components are designed to be reusable and maintainable
- Dark mode support is integrated throughout, not added as an afterthought
- Performance is prioritized with 60fps animation targets and optimization tasks

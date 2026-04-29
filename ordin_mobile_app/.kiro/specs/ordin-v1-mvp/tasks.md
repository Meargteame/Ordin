# Implementation Plan: Ordin v1 MVP

## Overview

This implementation plan follows a phased build strategy to deliver the Ordin v1 MVP incrementally. Each phase builds on the previous one, ensuring that the app remains functional and testable at every step. The approach prioritizes getting a working skeleton early, then adding core functionality layer by layer.

The implementation uses Flutter/Dart with a simple state management approach (setState), Hive for local storage, and follows the architecture defined in the design document. All tasks reference specific requirements for traceability.

## Build Strategy Phases

1. **UI Skeleton**: Navigation structure and empty screens
2. **Tasks System**: Full CRUD operations for tasks
3. **Habit System**: Habit tracking with toggle and streak logic
4. **Today System**: Merge tasks and habits into dashboard
5. **Persistence**: Local storage with Hive

## Tasks

- [x] 1. Set up project structure and dependencies
  - Create folder structure: lib/screens, lib/models, lib/state, lib/data, lib/widgets
  - Add dependencies to pubspec.yaml: hive, hive_flutter, uuid, provider (optional)
  - Initialize Hive in main.dart
  - _Requirements: 4.4, 15.1, 15.3_

- [x] 2. Create data models
  - [x] 2.1 Implement Task model with serialization
    - Create lib/models/task.dart with Task class
    - Implement toJson() and fromJson() methods
    - Add isScheduledFor() helper method for date comparison
    - _Requirements: 2.2, 7.1, 7.5_
  
  - [ ]* 2.2 Write property test for Task model
    - **Property 5: Task creation stores required properties**
    - **Property 20: Task serialization contains exactly four properties**
    - **Validates: Requirements 2.2, 2.5, 7.1**
  
  - [x] 2.3 Implement Habit model with serialization
    - Create lib/models/habit.dart with Habit class
    - Implement toJson() and fromJson() methods
    - Add toggle() method for completion and streak logic
    - _Requirements: 3.2, 8.4_
  
  - [ ]* 2.4 Write property test for Habit model
    - **Property 9: Habit creation stores required properties**
    - **Property 10: Habit toggle flips completion status**
    - **Property 11: Habit completion increments streak**
    - **Validates: Requirements 3.2, 3.3, 3.4, 8.1, 8.4**

- [x] 3. Phase 1: UI Skeleton - Navigation and empty screens
  - [x] 3.1 Create main app structure with bottom navigation
    - Create lib/main.dart with MaterialApp and bottom navigation bar
    - Set up three tabs: Today (index 0), Tasks (index 1), Habits (index 2)
    - Implement tab switching logic with PageView or IndexedStack
    - _Requirements: 1.4, 5.1, 5.2, 5.3_
  
  - [x] 3.2 Create empty screen scaffolds
    - Create lib/screens/today_screen.dart with placeholder content
    - Create lib/screens/tasks_screen.dart with placeholder content
    - Create lib/screens/habits_screen.dart with placeholder content
    - _Requirements: 1.1, 2.1, 3.1_
  
  - [ ]* 3.3 Write unit tests for navigation
    - Test default screen is Today on app launch
    - Test tab switching changes displayed screen
    - Test active tab highlighting
    - _Requirements: 1.4, 5.2, 5.4_

- [x] 4. Checkpoint - Verify navigation works
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement storage layer
  - [x] 5.1 Create StorageService abstraction
    - Create lib/data/storage_service.dart with abstract class
    - Define methods: init(), saveString(), getString(), saveList(), getList(), delete()
    - _Requirements: 4.4_
  
  - [x] 5.2 Implement Hive storage service
    - Create lib/data/hive_storage_service.dart implementing StorageService
    - Initialize Hive boxes for tasks, habits, and focus text
    - Handle initialization errors with try-catch
    - _Requirements: 4.4, 4.6_
  
  - [x] 5.3 Create TaskRepository
    - Create lib/data/task_repository.dart
    - Implement loadTasks(), saveTask(), deleteTask(), getTasksForDate()
    - Use StorageService for persistence
    - _Requirements: 4.1, 4.3_
  
  - [x] 5.4 Create HabitRepository
    - Create lib/data/habit_repository.dart
    - Implement loadHabits(), saveHabit(), deleteHabit(), performDailyReset()
    - Use StorageService for persistence
    - Store lastCheckDate for daily reset logic
    - _Requirements: 4.2, 4.3, 9.1, 9.3_
  
  - [ ]* 5.5 Write property tests for persistence
    - **Property 14: Task persistence round-trip**
    - **Property 15: Habit persistence round-trip**
    - **Property 24: Focus text persistence round-trip**
    - **Validates: Requirements 4.1, 4.2, 6.4, 11.2, 12.2, 13.2, 13.3, 13.4**

- [ ] 6. Phase 2: Tasks System - CRUD operations
  - [x] 6.1 Implement task creation UI
    - Add FloatingActionButton to tasks_screen.dart
    - Create dialog or bottom sheet for task title input
    - Validate non-empty title before creation
    - Generate UUID for new task, set date to current date, isDone to false
    - _Requirements: 2.2, 2.5, 7.4, 7.5_
  
  - [x] 6.2 Implement task list display
    - Create lib/widgets/task_item.dart widget
    - Display task title and completion checkbox
    - Show visual difference between completed and incomplete tasks
    - Load tasks from TaskRepository on screen init
    - _Requirements: 2.1, 6.2, 6.3_
  
  - [x] 6.3 Implement task toggle functionality
    - Add onTap handler to task checkbox
    - Toggle isDone status in Task model
    - Persist change via TaskRepository
    - Update UI with setState
    - _Requirements: 2.3, 6.1, 6.4, 6.5_
  
  - [ ]* 6.4 Write property test for task toggle
    - **Property 6: Task toggle is idempotent**
    - **Property 19: Task visual state matches completion status**
    - **Validates: Requirements 2.3, 6.1, 6.2, 6.3**
  
  - [x] 6.5 Implement task deletion
    - Add swipe-to-delete gesture or delete button to task_item.dart
    - Call TaskRepository.deleteTask() on delete action
    - Show confirmation snackbar
    - Update UI with setState
    - _Requirements: 2.4, 11.1, 11.2, 11.3, 11.4, 11.5_
  
  - [ ]* 6.6 Write property test for task deletion
    - **Property 7: Task deletion removes from storage**
    - **Validates: Requirements 2.4, 11.1, 11.5**
  
  - [ ]* 6.7 Write unit tests for task system
    - Test empty title validation shows error
    - Test task creation with valid title succeeds
    - Test task list displays in creation order
    - _Requirements: 7.4, 14.4_

- [ ] 7. Checkpoint - Verify task system works end-to-end
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Phase 3: Habit System - Toggle and streak tracking
  - [ ] 8.1 Implement habit creation UI
    - Add FloatingActionButton to habits_screen.dart
    - Create dialog or bottom sheet for habit name input
    - Validate non-empty name before creation
    - Generate UUID for new habit, set isDoneToday to false, streak to 0
    - _Requirements: 3.2, 8.4_
  
  - [ ] 8.2 Implement habit list display
    - Create lib/widgets/habit_item.dart widget
    - Display habit name, completion checkbox, and streak counter
    - Show visual difference between completed and incomplete habits
    - Load habits from HabitRepository on screen init
    - _Requirements: 3.1, 8.3_
  
  - [ ] 8.3 Implement habit toggle functionality
    - Add onTap handler to habit checkbox
    - Call habit.toggle() method to update isDoneToday and streak
    - Persist change via HabitRepository
    - Update UI with setState
    - _Requirements: 3.3, 3.4, 3.7_
  
  - [ ]* 8.4 Write property test for habit toggle
    - **Property 10: Habit toggle flips completion status**
    - **Property 11: Habit completion increments streak**
    - **Property 22: Habit display shows correct streak**
    - **Validates: Requirements 3.3, 3.4, 8.1, 8.3**
  
  - [ ] 8.5 Implement daily reset logic
    - Add checkAndResetDaily() method to HabitRepository
    - Call on app launch (main.dart) and app resume (WidgetsBindingObserver)
    - Compare lastCheckDate with current date
    - Reset isDoneToday to false for all habits
    - Reset streak to 0 for habits not completed yesterday
    - _Requirements: 3.5, 3.6, 8.2, 9.1, 9.2, 9.3, 9.4, 9.5_
  
  - [ ]* 8.6 Write property test for daily reset
    - **Property 12: Date change resets habit completion status**
    - **Property 13: Date change resets streak for incomplete habits**
    - **Validates: Requirements 3.5, 3.6, 8.2, 9.1, 9.5**
  
  - [ ] 8.7 Implement habit deletion
    - Add swipe-to-delete gesture or delete button to habit_item.dart
    - Call HabitRepository.deleteHabit() on delete action
    - Show confirmation snackbar
    - Update UI with setState
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_
  
  - [ ]* 8.8 Write property test for habit deletion
    - **Property 23: Habit deletion removes from storage**
    - **Validates: Requirements 12.1, 12.5**
  
  - [ ]* 8.9 Write unit tests for habit system
    - Test empty name validation shows error
    - Test habit creation with valid name succeeds
    - Test streak never goes negative
    - _Requirements: 8.4_

- [ ] 9. Checkpoint - Verify habit system works end-to-end
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Phase 4: Today System - Dashboard integration
  - [ ] 10.1 Implement today's task filtering
    - Load all tasks from TaskRepository in today_screen.dart
    - Filter tasks using isScheduledFor(DateTime.now())
    - Display filtered tasks using task_item.dart widget
    - Show empty state message if no tasks for today
    - _Requirements: 1.1, 14.1, 14.2, 14.3, 14.4, 14.5_
  
  - [ ]* 10.2 Write property test for task filtering
    - **Property 1: Today screen filters tasks by current date**
    - **Property 3: Date change triggers today screen refresh**
    - **Property 25: Tasks display in creation order**
    - **Validates: Requirements 1.1, 1.5, 14.1, 14.2, 14.3, 14.4**
  
  - [ ] 10.3 Implement today's habit display
    - Load all habits from HabitRepository in today_screen.dart
    - Display all habits using habit_item.dart widget
    - Show completion status and streak for each habit
    - _Requirements: 1.2_
  
  - [ ]* 10.4 Write property test for habit display
    - **Property 2: Today screen displays all habits**
    - **Validates: Requirements 1.2**
  
  - [ ] 10.5 Implement focus text field
    - Create lib/widgets/focus_text_field.dart widget
    - Add TextField with single line or short paragraph limit
    - Save focus text to storage on change (debounced)
    - Load focus text from storage on screen init
    - _Requirements: 1.3, 13.1, 13.2, 13.3, 13.4, 13.5_
  
  - [ ]* 10.6 Write unit tests for today screen
    - Test empty state displays when no tasks for today
    - Test screen refreshes on navigation
    - Test focus text persists across app restarts
    - _Requirements: 14.5, 13.4_
  
  - [ ] 10.7 Wire task and habit toggles on today screen
    - Ensure task toggle on today screen updates TaskRepository
    - Ensure habit toggle on today screen updates HabitRepository
    - Ensure changes persist and reflect on other screens
    - _Requirements: 2.3, 3.3, 6.4_

- [ ] 11. Phase 5: Polish and error handling
  - [x] 11.1 Implement storage error handling
    - Add try-catch blocks in all repository methods
    - Display snackbar on save failures: "Failed to save changes. Please try again."
    - Display dialog on initialization failures: "Unable to initialize storage. Please restart the app."
    - Implement automatic retry for save operations (one retry)
    - _Requirements: 4.6_
  
  - [ ]* 11.2 Write property test for error handling
    - **Property 16: Storage failure displays error**
    - **Validates: Requirements 4.6**
  
  - [x] 11.3 Add input validation
    - Prevent task creation with empty or whitespace-only title
    - Prevent habit creation with empty or whitespace-only name
    - Display snackbar: "Task title cannot be empty" or "Habit name cannot be empty"
    - _Requirements: 7.4_
  
  - [ ] 11.4 Optimize performance
    - Ensure task/habit toggle completes within 100ms (use Stopwatch to measure)
    - Ensure screen navigation completes within 300ms
    - Ensure app launch displays Today screen within 2 seconds
    - Profile with Flutter DevTools if needed
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_
  
  - [ ]* 11.5 Write unit tests for validation
    - Test empty task title shows error and prevents creation
    - Test empty habit name shows error and prevents creation
    - Test whitespace-only input is treated as empty
    - _Requirements: 7.4_

- [ ] 12. Final checkpoint - End-to-end verification
  - [ ] 12.1 Verify all requirements are met
    - Test complete task creation flow: create → display → toggle → delete
    - Test complete habit flow: create → display → toggle → daily reset → delete
    - Test today screen aggregates tasks and habits correctly
    - Test data persists across app restarts
    - Test navigation between all three screens
    - _Requirements: All_
  
  - [ ]* 12.2 Run all property-based tests
    - Execute all property tests with minimum 100 iterations each
    - Verify all properties pass
    - Fix any failing properties before completion
  
  - [ ]* 12.3 Run all unit tests
    - Execute complete unit test suite
    - Verify all tests pass
    - Achieve reasonable code coverage (aim for >80% on business logic)

- [ ] 13. Final polish and documentation
  - [ ] 13.1 Add code comments
    - Document complex logic (daily reset, streak calculation)
    - Add doc comments to public methods
    - Explain non-obvious design decisions
  
  - [ ] 13.2 Update README
    - Add project description
    - Document how to run the app
    - List dependencies and setup instructions
    - _Requirements: 15.3, 15.4_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties across all inputs
- Unit tests validate specific examples, edge cases, and error conditions
- The build strategy follows five phases: UI Skeleton → Tasks → Habits → Today → Persistence
- All code should be written in Dart for Flutter
- Use Hive for local storage (recommended over SharedPreferences)
- Use setState for state management (simplest approach for MVP)
- Ensure all interactions meet performance requirements (100ms for toggles, 300ms for navigation)

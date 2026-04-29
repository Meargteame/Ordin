# Design Document: Ordin v1 MVP

## Overview

Ordin v1 MVP is a local-first Flutter mobile application that provides a minimal daily execution system. The app helps users focus on what matters today through three core modules: Today System, Task System, and Habit System. All data is stored locally with no backend dependencies, ensuring fast interactions and offline-first operation.

The design prioritizes execution speed and simplicity. Task toggling completes within 100ms, navigation within 300ms, and the entire app launches within 2 seconds. The architecture uses minimal state management (setState or Provider) to keep the codebase simple and maintainable.

### Design Goals

- **Speed**: All interactions complete within 100-300ms
- **Simplicity**: Minimal properties, no complex features
- **Local-First**: No network dependencies, all data stored locally
- **Focus**: Single-day view, no future planning
- **Consistency**: Daily habit tracking with automatic resets

## Architecture

The application follows a layered architecture with clear separation between UI, business logic, and data persistence.

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation Layer                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Today Screen │  │ Tasks Screen │  │ Habits Screen│  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                   Bottom Navigation Bar                  │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                      State Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Today State  │  │  Task State  │  │ Habit State  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                     Business Logic Layer                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Today System │  │ Task System  │  │ Habit System │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Task Storage │  │ Habit Storage│  │ Focus Storage│  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│              Local Storage (Hive/SharedPreferences)      │
└─────────────────────────────────────────────────────────┘
```

### Core Modules

**Today System**: Aggregates and displays today's tasks and habits. Filters tasks by current date and shows all habits with their completion status. Manages focus text display and editing.

**Task System**: Handles task CRUD operations (create, read, update, delete). Manages task completion toggling and date assignment. Persists all changes immediately to local storage.

**Habit System**: Manages habit tracking, daily resets, and streak calculations. Checks for date changes on app launch and resume. Resets isDoneToday flags at midnight and updates streaks based on previous day completion.

### Flutter Folder Structure

```
lib/
├── main.dart                    # App entry point, navigation setup
├── screens/
│   ├── today_screen.dart        # Today dashboard
│   ├── tasks_screen.dart        # Task list and creation
│   └── habits_screen.dart       # Habit list and creation
├── models/
│   ├── task.dart                # Task data model
│   └── habit.dart               # Habit data model
├── state/
│   ├── task_state.dart          # Task state management
│   ├── habit_state.dart         # Habit state management
│   └── today_state.dart         # Today screen state
├── data/
│   ├── storage_service.dart     # Storage abstraction
│   ├── task_repository.dart     # Task persistence
│   └── habit_repository.dart    # Habit persistence
└── widgets/
    ├── task_item.dart           # Task list item widget
    ├── habit_item.dart          # Habit list item widget
    └── focus_text_field.dart    # Focus text input widget
```

### State Management Approach

The app uses a simple state management approach to minimize complexity:

**Option 1: setState (Recommended for MVP)**
- Use StatefulWidget with setState for each screen
- Pass callbacks for cross-screen updates
- Simplest approach, no external dependencies
- Sufficient for the limited scope of this MVP

**Option 2: Provider (If cross-screen updates become complex)**
- Use ChangeNotifier classes for Task, Habit, and Today state
- Provides reactive updates across screens
- Minimal boilerplate compared to other solutions
- Easy migration path from setState

For the MVP, setState is recommended. Each screen manages its own state and calls repository methods directly. The Today screen rebuilds when navigated to, fetching fresh data from repositories.

## Components and Interfaces

### Task System

**TaskRepository**
```dart
class TaskRepository {
  Future<List<Task>> loadTasks();
  Future<void> saveTask(Task task);
  Future<void> deleteTask(String id);
  Future<List<Task>> getTasksForDate(DateTime date);
}
```

**Task Operations**
- `createTask(String title)`: Creates task with auto-generated id, current date, isDone=false
- `toggleTask(String id)`: Flips isDone status and persists immediately
- `deleteTask(String id)`: Removes task from storage
- `getTasksForToday()`: Filters tasks where date equals current date

### Habit System

**HabitRepository**
```dart
class HabitRepository {
  Future<List<Habit>> loadHabits();
  Future<void> saveHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<void> performDailyReset(DateTime currentDate);
}
```

**Habit Operations**
- `createHabit(String name)`: Creates habit with auto-generated id, isDoneToday=false, streak=0
- `toggleHabit(String id)`: Flips isDoneToday status, increments/decrements streak, persists immediately
- `deleteHabit(String id)`: Removes habit from storage
- `checkAndResetDaily()`: Called on app launch/resume, resets habits if date changed

**Daily Reset Logic**
```dart
void performDailyReset(DateTime lastCheckDate, DateTime currentDate) {
  if (lastCheckDate.day != currentDate.day || 
      lastCheckDate.month != currentDate.month || 
      lastCheckDate.year != currentDate.year) {
    
    for (habit in allHabits) {
      if (!habit.isDoneToday) {
        habit.streak = 0;  // Reset streak if not completed yesterday
      }
      habit.isDoneToday = false;  // Reset completion status
    }
    
    saveLastCheckDate(currentDate);
    persistAllHabits();
  }
}
```

### Storage System

**StorageService Interface**
```dart
abstract class StorageService {
  Future<void> init();
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveList(String key, List<String> values);
  Future<List<String>> getList(String key);
  Future<void> delete(String key);
}
```

**Implementation Options**

**Hive (Recommended)**
- Fast, lightweight NoSQL database
- Type-safe with generated adapters
- Better performance for list operations
- Supports complex objects natively

**SharedPreferences (Alternative)**
- Simpler API, no setup required
- Sufficient for small data volumes
- Requires manual JSON serialization
- Slightly slower for large lists

For the MVP, Hive is recommended for better performance and cleaner code when handling Task and Habit lists.

### Navigation Structure

**Bottom Navigation Bar**
- Three tabs: Today (index 0), Tasks (index 1), Habits (index 2)
- Default tab: Today (index 0)
- Uses Flutter's BottomNavigationBar widget
- Transitions use default Flutter animations (< 300ms)

**Screen Lifecycle**
- Today Screen: Refreshes data on every navigation (didChangeDependencies or initState)
- Tasks Screen: Loads tasks once, updates on local changes
- Habits Screen: Loads habits once, updates on local changes, checks for daily reset

## Data Models

### Task Model

```dart
class Task {
  final String id;           // UUID v4 generated on creation
  final String title;        // User-provided task description
  bool isDone;               // Completion status
  final DateTime date;       // Date task is scheduled for (date only, no time)
  
  Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.date,
  });
  
  // Serialization for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'date': date.toIso8601String(),
    };
  }
  
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isDone: json['isDone'],
      date: DateTime.parse(json['date']),
    );
  }
  
  // Date comparison helper (ignores time component)
  bool isScheduledFor(DateTime targetDate) {
    return date.year == targetDate.year &&
           date.month == targetDate.month &&
           date.day == targetDate.day;
  }
}
```

**Task Properties**
- `id`: Unique identifier (UUID v4), immutable
- `title`: Task description, required, non-empty string
- `isDone`: Boolean completion status, mutable
- `date`: DateTime representing the scheduled date (time component ignored)

### Habit Model

```dart
class Habit {
  final String id;           // UUID v4 generated on creation
  final String name;         // User-provided habit name
  bool isDoneToday;          // Today's completion status
  int streak;                // Consecutive days completed
  
  Habit({
    required this.id,
    required this.name,
    required this.isDoneToday,
    required this.streak,
  });
  
  // Serialization for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isDoneToday': isDoneToday,
      'streak': streak,
    };
  }
  
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      isDoneToday: json['isDoneToday'],
      streak: json['streak'],
    );
  }
  
  // Toggle completion and update streak
  void toggle() {
    isDoneToday = !isDoneToday;
    if (isDoneToday) {
      streak++;
    } else {
      streak = streak > 0 ? streak - 1 : 0;
    }
  }
}
```

**Habit Properties**
- `id`: Unique identifier (UUID v4), immutable
- `name`: Habit description, required, non-empty string
- `isDoneToday`: Boolean indicating completion for current day, mutable
- `streak`: Integer count of consecutive days completed, mutable, minimum 0

### Focus Text Model

Focus text is stored as a simple string in local storage with key `focus_text`. No complex model needed.


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Today screen filters tasks by current date

*For any* list of tasks with various dates, the Today screen should display only those tasks where the date equals the current date, excluding all past and future dated tasks.

**Validates: Requirements 1.1, 14.1, 14.2**

### Property 2: Today screen displays all habits

*For any* list of habits, the Today screen should display all habits with their current completion status.

**Validates: Requirements 1.2**

### Property 3: Date change triggers today screen refresh

*For any* task list, when the system date changes to a new day, the Today screen should automatically update to display only tasks matching the new current date.

**Validates: Requirements 1.5, 14.3**

### Property 4: Tasks screen displays all tasks

*For any* list of tasks, the Tasks screen should display all existing tasks regardless of their date.

**Validates: Requirements 2.1**

### Property 5: Task creation stores required properties

*For any* task creation with a title, the stored task should contain exactly four properties: a unique id, the provided title, isDone set to false, and date set to the current date.

**Validates: Requirements 2.2, 2.5**

### Property 6: Task toggle is idempotent

*For any* task, toggling its completion status twice should return it to its original state (isDone value should be unchanged after two toggles).

**Validates: Requirements 2.3, 6.1**

### Property 7: Task deletion removes from storage

*For any* task, after deletion, reloading the task list from storage should not include the deleted task.

**Validates: Requirements 2.4, 11.1, 11.5**

### Property 8: Habits screen displays all habits

*For any* list of habits, the Habits screen should display all existing habits with their current status.

**Validates: Requirements 3.1**

### Property 9: Habit creation stores required properties

*For any* habit creation with a name, the stored habit should contain exactly four properties: a unique id, the provided name, isDoneToday set to false, and streak set to 0.

**Validates: Requirements 3.2, 8.4**

### Property 10: Habit toggle flips completion status

*For any* habit, toggling should flip the isDoneToday value from false to true or true to false.

**Validates: Requirements 3.3**

### Property 11: Habit completion increments streak

*For any* habit with isDoneToday false, marking it done should increment the streak by exactly 1.

**Validates: Requirements 3.4, 8.1**

### Property 12: Date change resets habit completion status

*For any* list of habits, when the system date changes to a new day, all habits should have their isDoneToday value reset to false.

**Validates: Requirements 3.5, 9.1**

### Property 13: Date change resets streak for incomplete habits

*For any* habit where isDoneToday is false, when the system date changes to a new day, the habit's streak should be reset to 0.

**Validates: Requirements 3.6, 8.2, 9.5**

### Property 14: Task persistence round-trip

*For any* task operation (create, toggle, or delete), persisting the change and then reloading from storage should reflect the exact state after the operation.

**Validates: Requirements 4.1, 6.4, 11.2**

### Property 15: Habit persistence round-trip

*For any* habit operation (create, toggle, or delete), persisting the change and then reloading from storage should reflect the exact state after the operation.

**Validates: Requirements 4.2, 12.2**

### Property 16: Storage failure displays error

*For any* storage operation that fails, the app should display an error message to the user.

**Validates: Requirements 4.6**

### Property 17: Tab navigation switches screens

*For any* tab in the navigation bar (Today, Tasks, or Habits), tapping that tab should display the corresponding screen.

**Validates: Requirements 5.2**

### Property 18: Active tab is highlighted

*For any* currently displayed screen, the corresponding tab in the navigation bar should be highlighted.

**Validates: Requirements 5.4**

### Property 19: Task visual state matches completion status

*For any* task, the visual appearance should correctly indicate whether isDone is true (completed appearance) or false (incomplete appearance).

**Validates: Requirements 6.2, 6.3**

### Property 20: Task serialization contains exactly four properties

*For any* task, the JSON serialization should contain exactly four keys: id, title, isDone, and date.

**Validates: Requirements 7.1**

### Property 21: Task IDs are unique

*For any* set of created tasks, all task IDs should be unique (no two tasks should have the same id).

**Validates: Requirements 7.5**

### Property 22: Habit display shows correct streak

*For any* habit, the displayed streak value should match the stored streak property.

**Validates: Requirements 8.3**

### Property 23: Habit deletion removes from storage

*For any* habit, after deletion, reloading the habit list from storage should not include the deleted habit.

**Validates: Requirements 12.1, 12.5**

### Property 24: Focus text persistence round-trip

*For any* focus text string, saving it to storage and then reloading should return the exact same text.

**Validates: Requirements 13.2, 13.3, 13.4**

### Property 25: Tasks display in creation order

*For any* list of tasks, the display order on any screen should match the order in which the tasks were created (first created appears first).

**Validates: Requirements 14.4**

## Error Handling

### Storage Errors

**Initialization Failure**
- If Hive/SharedPreferences fails to initialize on app launch, display error dialog: "Unable to initialize storage. Please restart the app."
- Prevent further operations until storage is available
- Log error details for debugging

**Save Operation Failure**
- If a save operation fails, display snackbar: "Failed to save changes. Please try again."
- Revert UI state to previous value
- Retry save operation once automatically
- Log error details

**Load Operation Failure**
- If loading tasks/habits fails on app launch, display error dialog: "Unable to load data. Please restart the app."
- Initialize with empty lists as fallback
- Log error details

### Data Validation Errors

**Empty Task Title**
- Prevent task creation if title is empty or only whitespace
- Display snackbar: "Task title cannot be empty"
- Keep input field focused for correction

**Empty Habit Name**
- Prevent habit creation if name is empty or only whitespace
- Display snackbar: "Habit name cannot be empty"
- Keep input field focused for correction

**Invalid Date**
- If task date parsing fails, use current date as fallback
- Log warning for debugging

### Daily Reset Errors

**Date Check Failure**
- If date comparison fails, assume no date change occurred
- Log error and continue normal operation
- Retry on next app launch/resume

**Streak Calculation Error**
- If streak calculation produces negative value, reset to 0
- Log error for debugging
- Continue operation with corrected value

### General Error Handling Strategy

- All errors should be logged with context (operation, timestamp, error message)
- User-facing errors should be clear and actionable
- Critical errors (storage init failure) should prevent further operations
- Non-critical errors (single save failure) should allow retry
- Never crash the app due to data errors; use safe fallbacks

## Testing Strategy

### Dual Testing Approach

The testing strategy employs both unit tests and property-based tests to ensure comprehensive coverage:

**Unit Tests**: Verify specific examples, edge cases, and error conditions. Focus on:
- Specific examples that demonstrate correct behavior (e.g., first app launch with empty data)
- Integration points between components (e.g., screen navigation)
- Edge cases (e.g., empty task lists, empty focus text)
- Error conditions (e.g., storage failures, invalid input)

**Property-Based Tests**: Verify universal properties across all inputs through randomization. Focus on:
- Universal properties that hold for all inputs (e.g., task toggle idempotence)
- Comprehensive input coverage through random generation
- Round-trip properties (e.g., save then load returns same data)
- Invariants (e.g., streak never negative, IDs always unique)

Both approaches are complementary and necessary. Unit tests catch concrete bugs in specific scenarios, while property tests verify general correctness across the input space.

### Property-Based Testing Configuration

**Library**: Use the `test` package with custom property test helpers, or consider `dart_check` for property-based testing in Dart/Flutter.

**Test Configuration**:
- Minimum 100 iterations per property test (due to randomization)
- Each property test must reference its design document property
- Tag format: `// Feature: ordin-v1-mvp, Property {number}: {property_text}`

**Example Property Test Structure**:
```dart
// Feature: ordin-v1-mvp, Property 6: Task toggle is idempotent
test('task toggle twice returns to original state', () {
  for (int i = 0; i < 100; i++) {
    final task = generateRandomTask();
    final originalState = task.isDone;
    
    task.toggle();
    task.toggle();
    
    expect(task.isDone, equals(originalState));
  }
});
```

### Test Coverage Requirements

**Task System**:
- Unit tests: Empty title validation, deletion confirmation, date assignment
- Property tests: Properties 5, 6, 7, 14, 19, 20, 21, 25

**Habit System**:
- Unit tests: Empty name validation, streak initialization, daily reset timing
- Property tests: Properties 9, 10, 11, 12, 13, 15, 22, 23

**Today System**:
- Unit tests: Empty state display, first launch initialization
- Property tests: Properties 1, 2, 3

**Storage System**:
- Unit tests: Initialization failure, save failure, load failure
- Property tests: Properties 14, 15, 24

**Navigation System**:
- Unit tests: Default screen on launch, navigation bar structure
- Property tests: Properties 17, 18

### Test Data Generators

For property-based tests, implement random data generators:

**Task Generator**:
```dart
Task generateRandomTask() {
  return Task(
    id: Uuid().v4(),
    title: generateRandomString(1, 100),
    isDone: Random().nextBool(),
    date: generateRandomDate(),
  );
}
```

**Habit Generator**:
```dart
Habit generateRandomHabit() {
  return Habit(
    id: Uuid().v4(),
    name: generateRandomString(1, 100),
    isDoneToday: Random().nextBool(),
    streak: Random().nextInt(1000),
  );
}
```

### Integration Testing

While the focus is on unit and property tests, key integration tests should verify:
- End-to-end task creation flow (UI → state → storage → reload)
- End-to-end habit tracking flow (UI → state → storage → daily reset)
- Navigation flow between all three screens
- App launch and data loading flow

### Performance Testing

While not part of correctness properties, performance should be validated:
- Task/habit toggle operations complete within 100ms
- Screen navigation completes within 300ms
- App launch completes within 2 seconds
- Storage operations complete within 100ms

These can be measured with Flutter's performance profiling tools rather than automated tests.


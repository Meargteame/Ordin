# Ordin v1 MVP

A minimal daily execution system mobile app built with Flutter.

## Overview

Ordin helps you decide what matters today and complete it consistently. It's a focused daily control system with three core modules:

- **Today Screen**: Central dashboard showing today's tasks, habits, and focus text
- **Tasks System**: Create and manage actionable tasks for today
- **Habit System**: Track daily habits with automatic streak counting

## Features

✅ Task management (create, toggle, delete)
✅ Habit tracking with streaks
✅ Daily habit reset at midnight
✅ Focus text for daily intention
✅ Local-only storage (no cloud, no auth)
✅ Fast interactions (< 100ms toggles)
✅ Bottom navigation (Today | Tasks | Habits)

## Tech Stack

- Flutter/Dart
- Hive (local storage)
- Material Design 3
- Simple state management (setState)

## Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)

### Installation

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── screens/
│   ├── today_screen.dart        # Today dashboard
│   ├── tasks_screen.dart        # Task management
│   └── habits_screen.dart       # Habit tracking
├── models/
│   ├── task.dart                # Task data model
│   └── habit.dart               # Habit data model
├── data/
│   ├── storage_service.dart     # Storage abstraction
│   ├── hive_storage_service.dart # Hive implementation
│   ├── task_repository.dart     # Task persistence
│   └── habit_repository.dart    # Habit persistence
└── widgets/
    ├── task_item.dart           # Task list item
    ├── habit_item.dart          # Habit list item
    └── focus_text_field.dart    # Focus text input
```

## Usage

### Today Screen
- View all tasks scheduled for today
- See all habits with completion status
- Set your daily focus text

### Tasks Screen
- Tap + to create a new task
- Tap checkbox to mark complete/incomplete
- Swipe left to delete

### Habits Screen
- Tap + to create a new habit
- Tap checkbox to mark done for today
- View streak counter
- Swipe left to delete

## Design Principles

1. **Clarity > Features**: Everything must improve daily execution clarity
2. **Speed**: All interactions complete within 100-300ms
3. **Simplicity**: Minimal properties, no complex features
4. **Local-First**: No network dependencies
5. **Focus**: Single-day view, no future planning

## Success Metric

Ordin v1 is successful if you use it daily for at least 7 consecutive days.

## Future Roadmap

- v2: Goals system
- v3: Notes / thinking layer
- v4: Journal system
- v5: Insight system (behavior patterns)

## License

MIT

# Requirements Document

## Introduction

Ordin v1 is a personal execution system mobile app designed to help users decide what matters today and complete it consistently. It is a focused daily control system that prioritizes execution clarity over feature complexity. The system operates entirely locally without cloud sync, authentication, or backend services.

## Glossary

- **Ordin_App**: The mobile application system built with Flutter
- **Today_Screen**: The central dashboard displaying today's tasks, habits, and focus text
- **Task**: An actionable item with properties: id, title, isDone, date
- **Habit**: A daily repetition behavior with properties: id, name, isDoneToday, streak
- **Task_System**: The subsystem managing task creation, completion, and display
- **Habit_System**: The subsystem managing habit tracking, daily reset, and streak calculation
- **Storage_System**: The local persistence layer using Hive or SharedPreferences
- **Navigation_Bar**: The bottom navigation component with three tabs: Today, Tasks, Habits

## Requirements

### Requirement 1: Display Today's Execution Dashboard

**User Story:** As a user, I want to see all my tasks and habits for today in one place, so that I can quickly understand what I need to execute today.

#### Acceptance Criteria

1. THE Today_Screen SHALL display all tasks scheduled for the current date
2. THE Today_Screen SHALL display all habits with their current completion status
3. THE Today_Screen SHALL display a simple focus text area
4. WHEN the user opens the Ordin_App, THE Today_Screen SHALL be the default screen displayed
5. THE Today_Screen SHALL refresh automatically when the date changes to a new day

### Requirement 2: Create and Manage Tasks

**User Story:** As a user, I want to create and manage actionable tasks, so that I can track what I need to complete today.

#### Acceptance Criteria

1. WHEN the user navigates to the Tasks tab, THE Task_System SHALL display all existing tasks
2. WHEN the user creates a new task, THE Task_System SHALL store it with properties: id, title, isDone, date
3. WHEN the user taps a task, THE Task_System SHALL toggle its isDone status
4. WHEN the user deletes a task, THE Task_System SHALL remove it from storage
5. THE Task_System SHALL assign the current date to newly created tasks
6. THE Task_System SHALL complete task creation within 2 taps maximum

### Requirement 3: Track Daily Habits

**User Story:** As a user, I want to track daily habits and see my streaks, so that I can build consistent behavior patterns.

#### Acceptance Criteria

1. WHEN the user navigates to the Habits tab, THE Habit_System SHALL display all habits with their current status
2. WHEN the user creates a new habit, THE Habit_System SHALL store it with properties: id, name, isDoneToday, streak
3. WHEN the user taps a habit, THE Habit_System SHALL toggle its isDoneToday status
4. WHEN a habit is marked done, THE Habit_System SHALL increment the streak by 1
5. WHEN the date changes to a new day, THE Habit_System SHALL reset all isDoneToday values to false
6. WHEN the date changes and a habit was not completed the previous day, THE Habit_System SHALL reset its streak to 0
7. THE Habit_System SHALL complete habit toggling within 1 tap

### Requirement 4: Persist Data Locally

**User Story:** As a user, I want my tasks and habits to be saved automatically, so that I don't lose my data when I close the app.

#### Acceptance Criteria

1. WHEN a task is created, modified, or deleted, THE Storage_System SHALL persist the change to local storage
2. WHEN a habit is created, modified, or deleted, THE Storage_System SHALL persist the change to local storage
3. WHEN the Ordin_App launches, THE Storage_System SHALL load all tasks and habits from local storage
4. THE Storage_System SHALL use either Hive or SharedPreferences for persistence
5. THE Storage_System SHALL complete save operations within 100ms
6. IF storage operations fail, THEN THE Ordin_App SHALL display an error message to the user

### Requirement 5: Provide Simple Navigation

**User Story:** As a user, I want to quickly switch between Today, Tasks, and Habits screens, so that I can efficiently manage my daily execution.

#### Acceptance Criteria

1. THE Navigation_Bar SHALL display three tabs: Today, Tasks, and Habits
2. WHEN the user taps a tab, THE Navigation_Bar SHALL switch to the corresponding screen
3. THE Navigation_Bar SHALL be positioned at the bottom of the screen
4. THE Navigation_Bar SHALL highlight the currently active tab
5. THE Navigation_Bar SHALL complete screen transitions within 300ms

### Requirement 6: Handle Task Completion

**User Story:** As a user, I want to mark tasks as complete, so that I can track my daily progress.

#### Acceptance Criteria

1. WHEN the user taps a task, THE Task_System SHALL toggle its completion status
2. WHEN a task is marked complete, THE Task_System SHALL update its visual appearance to indicate completion
3. WHEN a task is marked incomplete, THE Task_System SHALL restore its original visual appearance
4. THE Task_System SHALL persist completion status changes immediately
5. THE Task_System SHALL provide visual feedback within 100ms of the tap

### Requirement 7: Maintain Minimal Task Properties

**User Story:** As a user, I want tasks to be simple and focused, so that I can quickly add and complete them without complexity.

#### Acceptance Criteria

1. THE Task_System SHALL store only four properties per task: id, title, isDone, date
2. THE Task_System SHALL NOT support categories, priorities, tags, or subtasks
3. THE Task_System SHALL NOT support future date planning beyond today
4. WHEN creating a task, THE Task_System SHALL require only a title input
5. THE Task_System SHALL auto-generate unique ids for new tasks

### Requirement 8: Calculate Habit Streaks

**User Story:** As a user, I want to see my habit streaks, so that I can stay motivated to maintain consistency.

#### Acceptance Criteria

1. WHEN a habit is completed, THE Habit_System SHALL increment its streak counter
2. WHEN a habit is not completed by end of day, THE Habit_System SHALL reset its streak to 0
3. THE Habit_System SHALL display the current streak value for each habit
4. WHEN a habit is newly created, THE Habit_System SHALL initialize its streak to 0
5. THE Habit_System SHALL calculate streak changes at midnight local time

### Requirement 9: Reset Habits Daily

**User Story:** As a user, I want habits to reset each day, so that I can track daily completion without manual intervention.

#### Acceptance Criteria

1. WHEN the system date changes to a new day, THE Habit_System SHALL reset all isDoneToday values to false
2. THE Habit_System SHALL perform the daily reset automatically without user action
3. THE Habit_System SHALL check for date changes when the app launches
4. THE Habit_System SHALL check for date changes when the app returns from background
5. WHEN performing daily reset, THE Habit_System SHALL update streak values based on previous day completion

### Requirement 10: Provide Fast Interaction

**User Story:** As a user, I want all actions to complete quickly, so that the app doesn't slow down my execution flow.

#### Acceptance Criteria

1. THE Ordin_App SHALL complete task toggle actions within 100ms
2. THE Ordin_App SHALL complete habit toggle actions within 100ms
3. THE Ordin_App SHALL complete screen navigation within 300ms
4. THE Ordin_App SHALL launch and display the Today_Screen within 2 seconds
5. THE Ordin_App SHALL complete data persistence operations within 100ms

### Requirement 11: Support Task Deletion

**User Story:** As a user, I want to delete tasks I no longer need, so that I can keep my task list clean and relevant.

#### Acceptance Criteria

1. WHEN the user performs a delete gesture on a task, THE Task_System SHALL remove the task
2. THE Task_System SHALL persist the deletion immediately
3. THE Task_System SHALL provide visual confirmation of deletion
4. THE Task_System SHALL complete deletion within 2 taps or gestures maximum
5. IF a task is deleted, THEN THE Task_System SHALL remove it from all screens

### Requirement 12: Support Habit Deletion

**User Story:** As a user, I want to delete habits I no longer track, so that I can focus on relevant behaviors.

#### Acceptance Criteria

1. WHEN the user performs a delete gesture on a habit, THE Habit_System SHALL remove the habit
2. THE Habit_System SHALL persist the deletion immediately
3. THE Habit_System SHALL provide visual confirmation of deletion
4. THE Habit_System SHALL complete deletion within 2 taps or gestures maximum
5. IF a habit is deleted, THEN THE Habit_System SHALL remove it from all screens including Today_Screen

### Requirement 13: Display Focus Text

**User Story:** As a user, I want to see simple focus text on the Today screen, so that I can remind myself of my daily intention.

#### Acceptance Criteria

1. THE Today_Screen SHALL display a focus text area
2. THE Today_Screen SHALL allow the user to edit the focus text
3. THE Storage_System SHALL persist focus text changes
4. THE Today_Screen SHALL display the most recently saved focus text on launch
5. THE Today_Screen SHALL limit focus text to a single line or short paragraph

### Requirement 14: Filter Today's Tasks

**User Story:** As a user, I want to see only today's tasks on the Today screen, so that I can focus on what matters now.

#### Acceptance Criteria

1. THE Today_Screen SHALL display only tasks where the date equals the current date
2. THE Today_Screen SHALL NOT display tasks from past or future dates
3. WHEN the date changes, THE Today_Screen SHALL automatically update to show the new day's tasks
4. THE Today_Screen SHALL display tasks in the order they were created
5. IF there are no tasks for today, THEN THE Today_Screen SHALL display an empty state message

### Requirement 15: Initialize App State

**User Story:** As a user, I want the app to work correctly on first launch, so that I can start using it immediately.

#### Acceptance Criteria

1. WHEN the Ordin_App launches for the first time, THE Storage_System SHALL initialize empty task and habit lists
2. WHEN the Ordin_App launches for the first time, THE Storage_System SHALL initialize empty focus text
3. THE Ordin_App SHALL NOT require any setup or configuration on first launch
4. THE Ordin_App SHALL NOT require internet connectivity to function
5. THE Ordin_App SHALL NOT require user authentication or account creation


# Requirements Document

## Introduction

Ordin v2 transforms the application from a simple task and habit tracker into a comprehensive life control system. Building on the solid v1 foundation (Today screen, Tasks, Habits, local storage), v2 adds six major feature modules that give users total control over every aspect of their life: Goals System (strategic planning), Projects System (execution management), Time Tracking & Analytics (productivity insights), Calendar Integration (scheduling), Notes & Journal System (reflection and documentation), and Life Areas Dashboard (holistic life management). The system maintains the local-first architecture, ensuring fast performance and offline operation while dramatically expanding functionality.

## Glossary

- **Ordin_App**: The complete mobile application system built with Flutter
- **Goals_System**: The strategic planning subsystem managing long-term goals, milestones, and progress tracking
- **Goal**: A long-term objective with properties: id, title, description, category, status, priority, deadline, successMetrics, progress, linkedTaskIds, linkedProjectIds, createdDate
- **Goal_Category**: Classification of goals: Career, Health, Finance, Relationships, Personal_Growth, Learning
- **Goal_Status**: State of a goal: Active, Completed, Archived, On_Hold
- **Milestone**: A significant checkpoint within a goal with properties: id, goalId, title, targetDate, isCompleted
- **Projects_System**: The execution management subsystem handling multi-task projects with deadlines and dependencies
- **Project**: A collection of related tasks with properties: id, title, description, status, category, deadline, linkedGoalId, progress, createdDate, completedDate
- **Project_Status**: State of a project: Planning, Active, On_Hold, Completed, Archived
- **Project_Template**: A reusable project structure with predefined tasks and configuration
- **Task_Dependency**: A relationship where one task must be completed before another can start
- **Time_Tracking_System**: The productivity measurement subsystem tracking time spent on activities
- **Time_Entry**: A record of time spent with properties: id, taskId, startTime, endTime, duration, category, notes
- **Productivity_Score**: A calculated metric representing overall productivity based on time tracking and completion data
- **Calendar_System**: The scheduling subsystem managing task scheduling, recurring tasks, and time blocking
- **Recurring_Task**: A task that repeats on a schedule with properties: id, baseTaskId, recurrencePattern, nextOccurrence
- **Recurrence_Pattern**: Schedule definition: Daily, Weekly, Monthly, Custom
- **Time_Block**: A scheduled time slot with properties: id, startTime, endTime, taskId, title
- **Notes_System**: The documentation and reflection subsystem managing notes, journal entries, and attachments
- **Note**: A text entry with properties: id, title, content, tags, linkedEntityType, linkedEntityId, createdDate, modifiedDate
- **Journal_Entry**: A daily reflection with properties: id, date, content, mood, gratitudeItems, reflectionPrompts
- **Mood**: Emotional state tracking: Great, Good, Neutral, Bad, Terrible
- **Life_Areas_System**: The holistic management subsystem tracking health, finance, relationships, learning, and custom areas
- **Life_Area**: A domain of life with properties: id, name, type, metrics, healthScore, lastUpdated
- **Life_Area_Type**: Classification: Health, Finance, Relationships, Learning, Custom
- **Health_Metric**: Tracking data for health area: workouts, waterIntake, sleep, weight, meals
- **Finance_Metric**: Tracking data for finance area: expenses, income, budget, savings
- **Relationship_Contact**: A person with properties: id, name, importantDates, lastInteraction, notes
- **Learning_Item**: Educational content with properties: id, title, type (Book, Course, Skill, Certification), status, progress, completedDate
- **Storage_System**: The local persistence layer using Hive for all data models
- **Analytics_Engine**: The calculation subsystem generating insights, trends, and reports from tracked data
- **Navigation_System**: The app navigation structure using drawer and bottom navigation

## Requirements

### Requirement 1: Manage Long-Term Goals

**User Story:** As a user, I want to create and track long-term goals with categories and deadlines, so that I can maintain strategic focus on what matters most in my life.

#### Acceptance Criteria

1. WHEN the user creates a goal, THE Goals_System SHALL store it with properties: id, title, description, category, status, priority, deadline, successMetrics, progress, linkedTaskIds, linkedProjectIds, createdDate
2. THE Goals_System SHALL support six goal categories: Career, Health, Finance, Relationships, Personal_Growth, Learning
3. THE Goals_System SHALL support four goal statuses: Active, Completed, Archived, On_Hold
4. THE Goals_System SHALL support three priority levels: High, Medium, Low
5. WHEN the user views goals, THE Goals_System SHALL display them grouped by category
6. WHEN the user updates goal progress, THE Goals_System SHALL recalculate the progress percentage
7. THE Goals_System SHALL persist all goal changes within 100ms

### Requirement 2: Break Down Goals into Milestones

**User Story:** As a user, I want to break goals into smaller milestones, so that I can track incremental progress toward large objectives.

#### Acceptance Criteria

1. WHEN the user creates a milestone, THE Goals_System SHALL store it with properties: id, goalId, title, targetDate, isCompleted
2. WHEN the user completes a milestone, THE Goals_System SHALL update the parent goal's progress
3. THE Goals_System SHALL display all milestones for a goal in chronological order by targetDate
4. WHEN all milestones for a goal are completed, THE Goals_System SHALL suggest marking the goal as completed
5. THE Goals_System SHALL allow deletion of milestones without deleting the parent goal

### Requirement 3: Link Tasks to Goals

**User Story:** As a user, I want to link tasks to goals, so that I can see how my daily actions contribute to long-term objectives.

#### Acceptance Criteria

1. WHEN the user links a task to a goal, THE Goals_System SHALL add the task ID to the goal's linkedTaskIds list
2. WHEN the user views a goal, THE Goals_System SHALL display all linked tasks
3. WHEN a linked task is completed, THE Goals_System SHALL update the goal's progress calculation
4. WHEN a linked task is deleted, THE Goals_System SHALL remove it from the goal's linkedTaskIds list
5. THE Goals_System SHALL allow a task to be linked to multiple goals

### Requirement 4: Track Goal Progress Visually

**User Story:** As a user, I want to see visual progress charts for my goals, so that I can quickly understand how close I am to achieving them.

#### Acceptance Criteria

1. WHEN the user views a goal, THE Goals_System SHALL display a progress bar showing completion percentage
2. THE Goals_System SHALL calculate progress based on completed milestones and linked tasks
3. WHEN the user views the goals overview, THE Goals_System SHALL display progress charts for all active goals
4. THE Goals_System SHALL use different colors for different progress levels: 0-33% (red), 34-66% (yellow), 67-100% (green)
5. THE Goals_System SHALL update progress visualizations within 200ms of data changes

### Requirement 5: Create and Manage Projects

**User Story:** As a user, I want to create projects that contain multiple related tasks, so that I can organize complex work into manageable units.

#### Acceptance Criteria

1. WHEN the user creates a project, THE Projects_System SHALL store it with properties: id, title, description, status, category, deadline, linkedGoalId, progress, createdDate, completedDate
2. THE Projects_System SHALL support five project statuses: Planning, Active, On_Hold, Completed, Archived
3. WHEN the user adds a task to a project, THE Projects_System SHALL link the task to the project
4. WHEN the user views a project, THE Projects_System SHALL display all associated tasks
5. THE Projects_System SHALL calculate project progress as percentage of completed tasks
6. THE Projects_System SHALL allow linking a project to a goal

### Requirement 6: Use Project Templates

**User Story:** As a user, I want to create projects from templates, so that I can quickly set up common project structures without manual repetition.

#### Acceptance Criteria

1. WHEN the user creates a project template, THE Projects_System SHALL store the template structure with predefined tasks
2. WHEN the user creates a project from a template, THE Projects_System SHALL generate all predefined tasks automatically
3. THE Projects_System SHALL allow users to modify template-generated projects after creation
4. THE Projects_System SHALL provide default templates for common project types
5. THE Projects_System SHALL allow users to save custom projects as templates

### Requirement 7: Manage Task Dependencies

**User Story:** As a user, I want to define task dependencies within projects, so that I can ensure tasks are completed in the correct order.

#### Acceptance Criteria

1. WHEN the user creates a task dependency, THE Projects_System SHALL store the relationship between tasks
2. WHEN a task has incomplete dependencies, THE Projects_System SHALL mark it as blocked
3. WHEN the user views a project, THE Projects_System SHALL display task dependencies visually
4. WHEN all dependencies for a task are completed, THE Projects_System SHALL automatically unblock the task
5. THE Projects_System SHALL prevent circular dependencies

### Requirement 8: Track Time on Tasks

**User Story:** As a user, I want to track time spent on tasks using a start/stop timer, so that I can measure how I spend my time.

#### Acceptance Criteria

1. WHEN the user starts a timer for a task, THE Time_Tracking_System SHALL create a time entry with startTime
2. WHEN the user stops the timer, THE Time_Tracking_System SHALL record endTime and calculate duration
3. THE Time_Tracking_System SHALL allow only one active timer at a time
4. WHEN a timer is running, THE Time_Tracking_System SHALL display elapsed time updating every second
5. THE Time_Tracking_System SHALL persist time entries immediately upon stopping the timer
6. THE Time_Tracking_System SHALL allow adding notes to time entries

### Requirement 9: Enter Time Manually

**User Story:** As a user, I want to manually enter time spent on tasks, so that I can record time when I forget to use the timer.

#### Acceptance Criteria

1. WHEN the user manually creates a time entry, THE Time_Tracking_System SHALL store it with taskId, startTime, endTime, duration, category, notes
2. THE Time_Tracking_System SHALL validate that endTime is after startTime
3. THE Time_Tracking_System SHALL calculate duration automatically from startTime and endTime
4. THE Time_Tracking_System SHALL allow editing existing time entries
5. THE Time_Tracking_System SHALL allow deleting time entries

### Requirement 10: Generate Time Reports

**User Story:** As a user, I want to see daily, weekly, and monthly time reports, so that I can understand my time allocation patterns.

#### Acceptance Criteria

1. WHEN the user requests a time report, THE Analytics_Engine SHALL generate a report for the specified period
2. THE Analytics_Engine SHALL support three report periods: Daily, Weekly, Monthly
3. THE Analytics_Engine SHALL display total time tracked per category
4. THE Analytics_Engine SHALL display total time tracked per goal
5. THE Analytics_Engine SHALL display total time tracked per project
6. THE Analytics_Engine SHALL allow exporting reports as text or CSV

### Requirement 11: Display Productivity Insights

**User Story:** As a user, I want to see productivity insights and trends, so that I can identify patterns and improve my effectiveness.

#### Acceptance Criteria

1. WHEN the user views analytics, THE Analytics_Engine SHALL display productivity trends over time
2. THE Analytics_Engine SHALL calculate a daily productivity score based on tasks completed and time tracked
3. THE Analytics_Engine SHALL identify most productive hours of the day
4. THE Analytics_Engine SHALL identify most productive days of the week
5. THE Analytics_Engine SHALL display habit completion heatmap showing daily completion patterns
6. THE Analytics_Engine SHALL display streak statistics for all habits

### Requirement 12: View Habit Completion Heatmap

**User Story:** As a user, I want to see a calendar heatmap of habit completions, so that I can visualize my consistency over time.

#### Acceptance Criteria

1. WHEN the user views habit analytics, THE Analytics_Engine SHALL display a calendar heatmap for each habit
2. THE Analytics_Engine SHALL use color intensity to represent completion frequency
3. THE Analytics_Engine SHALL display the heatmap for the past 365 days
4. WHEN the user taps a date on the heatmap, THE Analytics_Engine SHALL display details for that day
5. THE Analytics_Engine SHALL update the heatmap within 200ms when new data is added

### Requirement 13: Schedule Tasks for Future Dates

**User Story:** As a user, I want to schedule tasks for specific future dates, so that I can plan ahead beyond just today.

#### Acceptance Criteria

1. WHEN the user creates or edits a task, THE Calendar_System SHALL allow selecting any future date
2. WHEN the user views the calendar, THE Calendar_System SHALL display all scheduled tasks on their respective dates
3. THE Calendar_System SHALL support week view and month view
4. WHEN the user drags a task to a different date, THE Calendar_System SHALL update the task's scheduled date
5. THE Calendar_System SHALL display tasks on the Today screen only when their date matches the current date

### Requirement 14: Create Recurring Tasks

**User Story:** As a user, I want to create tasks that repeat on a schedule, so that I don't have to manually recreate regular tasks.

#### Acceptance Criteria

1. WHEN the user creates a recurring task, THE Calendar_System SHALL store the recurrence pattern
2. THE Calendar_System SHALL support four recurrence patterns: Daily, Weekly, Monthly, Custom
3. WHEN a recurring task's date arrives, THE Calendar_System SHALL automatically create a new task instance
4. WHEN the user completes a recurring task instance, THE Calendar_System SHALL schedule the next occurrence
5. THE Calendar_System SHALL allow editing or deleting individual instances without affecting the recurrence pattern
6. THE Calendar_System SHALL allow stopping a recurrence pattern

### Requirement 15: Implement Time Blocking

**User Story:** As a user, I want to assign specific time slots to tasks, so that I can plan my day with dedicated focus periods.

#### Acceptance Criteria

1. WHEN the user creates a time block, THE Calendar_System SHALL store it with startTime, endTime, taskId, title
2. THE Calendar_System SHALL display time blocks in the calendar view
3. THE Calendar_System SHALL prevent overlapping time blocks
4. WHEN the user drags a time block, THE Calendar_System SHALL update its time slot
5. THE Calendar_System SHALL allow creating time blocks without linking to a task
6. WHEN a time block's time arrives, THE Calendar_System SHALL send a notification reminder

### Requirement 16: Display Week and Month Calendar Views

**User Story:** As a user, I want to view my schedule in week and month formats, so that I can see my commitments at different time scales.

#### Acceptance Criteria

1. THE Calendar_System SHALL provide a week view showing 7 days with hourly time slots
2. THE Calendar_System SHALL provide a month view showing all days of the month
3. WHEN the user switches between views, THE Calendar_System SHALL maintain the selected date
4. THE Calendar_System SHALL display task count badges on dates in month view
5. THE Calendar_System SHALL allow navigation to previous and next weeks/months
6. THE Calendar_System SHALL highlight the current date in both views

### Requirement 17: Create and Organize Notes

**User Story:** As a user, I want to create notes with tags and categories, so that I can capture and organize information.

#### Acceptance Criteria

1. WHEN the user creates a note, THE Notes_System SHALL store it with properties: id, title, content, tags, linkedEntityType, linkedEntityId, createdDate, modifiedDate
2. THE Notes_System SHALL support rich text formatting: bold, italic, bullet lists, numbered lists
3. THE Notes_System SHALL allow adding multiple tags to a note
4. WHEN the user searches notes, THE Notes_System SHALL search both title and content
5. THE Notes_System SHALL display notes sorted by modifiedDate (most recent first)
6. THE Notes_System SHALL allow linking notes to tasks, goals, or projects

### Requirement 18: Write Daily Journal Entries

**User Story:** As a user, I want to write daily journal entries with reflection prompts, so that I can maintain a practice of self-reflection.

#### Acceptance Criteria

1. WHEN the user creates a journal entry, THE Notes_System SHALL store it with properties: id, date, content, mood, gratitudeItems, reflectionPrompts
2. THE Notes_System SHALL allow only one journal entry per date
3. THE Notes_System SHALL provide daily reflection prompts to guide writing
4. THE Notes_System SHALL allow tracking mood with five levels: Great, Good, Neutral, Bad, Terrible
5. THE Notes_System SHALL allow adding gratitude items as a list
6. WHEN the user views journal history, THE Notes_System SHALL display entries in reverse chronological order

### Requirement 19: Attach Photos to Notes

**User Story:** As a user, I want to attach photos to notes and journal entries, so that I can capture visual information.

#### Acceptance Criteria

1. WHEN the user adds a photo to a note, THE Notes_System SHALL store the photo in local storage
2. THE Notes_System SHALL support multiple photos per note
3. THE Notes_System SHALL display photo thumbnails within the note
4. WHEN the user taps a photo, THE Notes_System SHALL display it in full screen
5. THE Notes_System SHALL allow deleting photos from notes
6. THE Notes_System SHALL compress photos to optimize storage space

### Requirement 20: Use Note Templates

**User Story:** As a user, I want to create notes from templates, so that I can quickly capture structured information.

#### Acceptance Criteria

1. WHEN the user creates a note template, THE Notes_System SHALL store the template structure
2. WHEN the user creates a note from a template, THE Notes_System SHALL populate the note with template content
3. THE Notes_System SHALL provide default templates for common note types
4. THE Notes_System SHALL allow users to create custom templates
5. THE Notes_System SHALL allow editing template-generated notes after creation

### Requirement 21: Track Health Metrics

**User Story:** As a user, I want to track health metrics like workouts, water intake, sleep, and weight, so that I can monitor my physical wellbeing.

#### Acceptance Criteria

1. WHEN the user logs a health metric, THE Life_Areas_System SHALL store it with date, type, value, and notes
2. THE Life_Areas_System SHALL support tracking: workouts (type, duration), water intake (amount), sleep (hours), weight (value), meals (description)
3. WHEN the user views health area, THE Life_Areas_System SHALL display trends and charts for each metric
4. THE Life_Areas_System SHALL calculate a health score based on metric consistency and targets
5. THE Life_Areas_System SHALL allow setting daily targets for each metric
6. WHEN a target is met, THE Life_Areas_System SHALL provide positive feedback

### Requirement 22: Track Finance Metrics

**User Story:** As a user, I want to track expenses, income, budget, and savings, so that I can manage my financial health.

#### Acceptance Criteria

1. WHEN the user logs a financial transaction, THE Life_Areas_System SHALL store it with date, type, category, amount, and description
2. THE Life_Areas_System SHALL support two transaction types: Expense, Income
3. THE Life_Areas_System SHALL allow setting monthly budgets per category
4. WHEN the user views finance area, THE Life_Areas_System SHALL display spending by category
5. THE Life_Areas_System SHALL calculate remaining budget for each category
6. WHEN spending exceeds budget, THE Life_Areas_System SHALL display a warning
7. THE Life_Areas_System SHALL track savings goals with target amounts and deadlines

### Requirement 23: Manage Relationships

**User Story:** As a user, I want to track important people, dates, and interactions, so that I can maintain meaningful relationships.

#### Acceptance Criteria

1. WHEN the user adds a contact, THE Life_Areas_System SHALL store it with properties: id, name, importantDates, lastInteraction, notes
2. THE Life_Areas_System SHALL allow adding multiple important dates per contact (birthdays, anniversaries)
3. WHEN an important date approaches, THE Life_Areas_System SHALL send a reminder notification
4. WHEN the user logs an interaction, THE Life_Areas_System SHALL update lastInteraction date
5. THE Life_Areas_System SHALL display contacts sorted by lastInteraction (least recent first)
6. THE Life_Areas_System SHALL suggest reaching out to contacts not interacted with recently

### Requirement 24: Track Learning Progress

**User Story:** As a user, I want to track books, courses, skills, and certifications, so that I can manage my continuous learning journey.

#### Acceptance Criteria

1. WHEN the user adds a learning item, THE Life_Areas_System SHALL store it with properties: id, title, type, status, progress, completedDate
2. THE Life_Areas_System SHALL support four learning types: Book, Course, Skill, Certification
3. THE Life_Areas_System SHALL support four learning statuses: Not_Started, In_Progress, Completed, Paused
4. WHEN the user updates learning progress, THE Life_Areas_System SHALL store the progress percentage
5. WHEN a learning item is completed, THE Life_Areas_System SHALL record the completedDate
6. THE Life_Areas_System SHALL display learning items grouped by type and status

### Requirement 25: Create Custom Life Areas

**User Story:** As a user, I want to create custom life areas beyond the default categories, so that I can track aspects of life unique to my situation.

#### Acceptance Criteria

1. WHEN the user creates a custom life area, THE Life_Areas_System SHALL store it with properties: id, name, type (Custom), metrics, healthScore, lastUpdated
2. THE Life_Areas_System SHALL allow defining custom metrics for the life area
3. THE Life_Areas_System SHALL allow logging data for custom metrics
4. THE Life_Areas_System SHALL calculate a health score for custom areas based on metric consistency
5. THE Life_Areas_System SHALL allow editing and deleting custom life areas

### Requirement 26: Display Life Areas Dashboard

**User Story:** As a user, I want to see an overview dashboard of all my life areas, so that I can quickly assess my overall life balance.

#### Acceptance Criteria

1. WHEN the user views the life areas dashboard, THE Life_Areas_System SHALL display all life areas with their health scores
2. THE Life_Areas_System SHALL use color coding for health scores: 0-33% (red), 34-66% (yellow), 67-100% (green)
3. THE Life_Areas_System SHALL display key metrics for each life area
4. THE Life_Areas_System SHALL calculate an overall life balance score based on all area health scores
5. THE Life_Areas_System SHALL identify areas needing attention (lowest health scores)
6. THE Life_Areas_System SHALL display trends showing improvement or decline over time

### Requirement 27: Generate Cross-Area Insights

**User Story:** As a user, I want to see insights that connect different life areas, so that I can understand how different aspects of my life influence each other.

#### Acceptance Criteria

1. WHEN the user views analytics, THE Analytics_Engine SHALL identify correlations between life areas
2. THE Analytics_Engine SHALL display how time spent on goals relates to life area health scores
3. THE Analytics_Engine SHALL identify patterns between habit completion and productivity scores
4. THE Analytics_Engine SHALL suggest actions to improve underperforming life areas
5. THE Analytics_Engine SHALL display a holistic view combining goals, projects, habits, and life areas

### Requirement 28: Extend Storage for New Data Models

**User Story:** As a developer, I want to extend the storage system to support all new data models, so that all v2 features persist correctly.

#### Acceptance Criteria

1. THE Storage_System SHALL create Hive boxes for: goals, milestones, projects, projectTemplates, timeEntries, recurringTasks, timeBlocks, notes, journalEntries, lifeAreas, healthMetrics, financeTransactions, contacts, learningItems
2. THE Storage_System SHALL provide type adapters for all new data models
3. THE Storage_System SHALL maintain backward compatibility with v1 data (tasks, habits, focus text)
4. THE Storage_System SHALL complete all save operations within 100ms
5. THE Storage_System SHALL complete all load operations within 500ms
6. IF storage initialization fails, THEN THE Storage_System SHALL display an error and prevent app usage

### Requirement 29: Implement Repository Pattern for All Modules

**User Story:** As a developer, I want repositories for each module, so that data access is consistent and testable.

#### Acceptance Criteria

1. THE Ordin_App SHALL implement repositories for: GoalsRepository, ProjectsRepository, TimeTrackingRepository, CalendarRepository, NotesRepository, LifeAreasRepository
2. WHEN any repository performs a data operation, THE repository SHALL use the Storage_System
3. WHEN any repository loads data, THE repository SHALL return the data within 500ms
4. WHEN any repository saves data, THE repository SHALL persist changes within 100ms
5. THE repositories SHALL provide methods for all CRUD operations (create, read, update, delete)

### Requirement 30: Update Navigation Structure

**User Story:** As a user, I want intuitive navigation to access all six new modules, so that I can efficiently move between different parts of the app.

#### Acceptance Criteria

1. THE Navigation_System SHALL use a drawer menu for primary navigation to modules
2. THE Navigation_System SHALL maintain bottom navigation for frequently accessed screens: Today, Tasks, Habits
3. THE Navigation_System SHALL include drawer menu items for: Goals, Projects, Calendar, Time Tracking, Notes, Journal, Life Areas, Analytics
4. WHEN the user opens the drawer, THE Navigation_System SHALL display all available modules
5. THE Navigation_System SHALL highlight the currently active module
6. THE Navigation_System SHALL complete navigation transitions within 300ms

### Requirement 31: Maintain Performance Standards

**User Story:** As a user, I want the app to remain fast despite added features, so that my workflow stays efficient.

#### Acceptance Criteria

1. THE Ordin_App SHALL complete all tap interactions within 100ms
2. THE Ordin_App SHALL complete screen navigation within 300ms
3. THE Ordin_App SHALL load the Today screen within 2 seconds on app launch
4. THE Ordin_App SHALL load any module screen within 1 second
5. THE Ordin_App SHALL update visualizations (charts, progress bars) within 200ms
6. THE Ordin_App SHALL maintain smooth scrolling at 60fps for all list views

### Requirement 32: Preserve v1 Data and Functionality

**User Story:** As a user upgrading from v1, I want all my existing tasks and habits to work exactly as before, so that I don't lose any data or functionality.

#### Acceptance Criteria

1. WHEN the app upgrades from v1 to v2, THE Storage_System SHALL migrate all existing tasks without data loss
2. WHEN the app upgrades from v1 to v2, THE Storage_System SHALL migrate all existing habits without data loss
3. WHEN the app upgrades from v1 to v2, THE Storage_System SHALL migrate focus text without data loss
4. THE Ordin_App SHALL maintain all v1 functionality: task creation, task completion, habit tracking, habit streaks, daily habit reset
5. THE Today_Screen SHALL continue to display today's tasks and habits exactly as in v1
6. THE Ordin_App SHALL complete the migration process within 5 seconds

### Requirement 33: Provide Module-Specific Settings

**User Story:** As a user, I want to customize settings for each module, so that I can tailor the app to my preferences.

#### Acceptance Criteria

1. THE Ordin_App SHALL provide a settings screen accessible from the drawer menu
2. THE Ordin_App SHALL allow customizing notification preferences per module
3. THE Ordin_App SHALL allow customizing default values (e.g., default goal category, default project status)
4. THE Ordin_App SHALL allow customizing visual preferences (e.g., chart colors, calendar start day)
5. THE Ordin_App SHALL persist all settings changes immediately
6. THE Ordin_App SHALL provide a reset to defaults option for all settings

### Requirement 34: Implement Onboarding for New Features

**User Story:** As a user upgrading from v1, I want to learn about new features through onboarding, so that I can quickly understand how to use them.

#### Acceptance Criteria

1. WHEN the app launches for the first time after v2 upgrade, THE Ordin_App SHALL display an onboarding flow
2. THE Ordin_App SHALL explain each of the six new modules with examples
3. THE Ordin_App SHALL allow users to skip onboarding
4. THE Ordin_App SHALL allow users to replay onboarding from settings
5. THE Ordin_App SHALL complete onboarding within 2 minutes if user views all screens
6. THE Ordin_App SHALL mark onboarding as completed after the user finishes or skips it

### Requirement 35: Link Entities Across Modules

**User Story:** As a user, I want to link related items across modules (tasks to goals, projects to goals, notes to tasks), so that I can see connections between different aspects of my life.

#### Acceptance Criteria

1. WHEN the user links entities, THE Ordin_App SHALL store bidirectional references
2. WHEN the user views an entity, THE Ordin_App SHALL display all linked entities
3. THE Ordin_App SHALL support linking: tasks to goals, tasks to projects, projects to goals, notes to tasks, notes to goals, notes to projects, time entries to tasks
4. WHEN a linked entity is deleted, THE Ordin_App SHALL remove all references to it
5. THE Ordin_App SHALL allow unlinking entities without deleting them
6. THE Ordin_App SHALL display link indicators in list views

### Requirement 36: Calculate and Display Productivity Score

**User Story:** As a user, I want to see a daily productivity score, so that I can quantify my effectiveness.

#### Acceptance Criteria

1. THE Analytics_Engine SHALL calculate a daily productivity score from 0 to 100
2. THE Analytics_Engine SHALL base the score on: tasks completed, habits completed, time tracked, goals progressed
3. THE Analytics_Engine SHALL weight different factors: tasks (30%), habits (25%), time tracked (25%), goals progressed (20%)
4. WHEN the user views the Today screen, THE Analytics_Engine SHALL display today's productivity score
5. WHEN the user views analytics, THE Analytics_Engine SHALL display productivity score trends over time
6. THE Analytics_Engine SHALL recalculate the score within 200ms when data changes

### Requirement 37: Support Data Export

**User Story:** As a user, I want to export my data, so that I can back it up or analyze it externally.

#### Acceptance Criteria

1. WHEN the user requests data export, THE Ordin_App SHALL generate export files for all data
2. THE Ordin_App SHALL support exporting to JSON format
3. THE Ordin_App SHALL support exporting time reports to CSV format
4. THE Ordin_App SHALL include all data: tasks, habits, goals, projects, time entries, notes, journal entries, life areas data
5. THE Ordin_App SHALL save export files to the device's downloads folder
6. THE Ordin_App SHALL complete export within 10 seconds for typical data volumes

### Requirement 38: Handle Deadline Notifications

**User Story:** As a user, I want to receive notifications for upcoming deadlines, so that I don't miss important dates.

#### Acceptance Criteria

1. WHEN a goal deadline is within 7 days, THE Ordin_App SHALL send a notification reminder
2. WHEN a project deadline is within 3 days, THE Ordin_App SHALL send a notification reminder
3. WHEN a time block is starting, THE Ordin_App SHALL send a notification reminder
4. WHEN an important date for a contact is within 7 days, THE Ordin_App SHALL send a notification reminder
5. THE Ordin_App SHALL allow users to customize notification timing in settings
6. THE Ordin_App SHALL allow users to disable notifications per module

### Requirement 39: Display Upcoming View

**User Story:** As a user, I want to see what's coming up in the next 7 days, so that I can prepare for upcoming commitments.

#### Acceptance Criteria

1. WHEN the user views the upcoming screen, THE Calendar_System SHALL display all items scheduled for the next 7 days
2. THE Calendar_System SHALL include: tasks, time blocks, goal deadlines, project deadlines, important dates
3. THE Calendar_System SHALL group items by date
4. THE Calendar_System SHALL display item counts per day
5. THE Calendar_System SHALL allow tapping items to view details
6. THE Calendar_System SHALL update the upcoming view within 200ms when data changes

### Requirement 40: Provide Quick Actions

**User Story:** As a user, I want quick actions for common operations, so that I can work efficiently without navigating through multiple screens.

#### Acceptance Criteria

1. THE Ordin_App SHALL provide a floating action button on the Today screen
2. WHEN the user taps the floating action button, THE Ordin_App SHALL display quick actions: Add Task, Add Habit, Start Timer, Add Note, Log Health Metric
3. THE Ordin_App SHALL complete quick actions within 2 taps maximum
4. THE Ordin_App SHALL return to the previous screen after completing a quick action
5. THE Ordin_App SHALL allow customizing which quick actions appear in settings

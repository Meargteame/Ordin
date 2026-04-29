# Design Document: Ordin v2 - Life Control System

## Overview

Ordin v2 transforms the application from a simple task and habit tracker into a comprehensive life management system. Building on the solid v1 foundation (Today, Tasks, Habits screens with local storage), v2 adds six major feature modules that provide complete control over every aspect of life: Goals System, Projects System, Time Tracking & Analytics, Calendar Integration, Notes & Journal System, and Life Areas Dashboard.

The design maintains the local-first architecture from v1, ensuring fast performance and offline operation. All new data models use Hive for persistence, following the same patterns established in v1. The navigation structure expands from bottom navigation to include a drawer menu for accessing the new modules while preserving the core v1 experience.

### Design Goals

- **Comprehensive**: Cover all major life domains (goals, projects, time, calendar, notes, health, finance, relationships, learning)
- **Integrated**: Link entities across modules (tasks to goals, projects to goals, notes to tasks)
- **Fast**: Maintain v1 performance standards (100ms interactions, 300ms navigation)
- **Local-First**: No backend dependencies, all data stored locally with Hive
- **Backward Compatible**: Preserve all v1 data and functionality
- **Scalable**: Architecture supports future expansion

## Architecture

The application extends the v1 layered architecture with six new feature modules, each following the same pattern: Screen → Repository → Storage.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          Presentation Layer                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐     │
│  │  Today   │ │  Tasks   │ │  Habits  │ │  Goals   │ │ Projects │ ... │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘     │
│         Bottom Nav (v1)              Drawer Menu (v2)                    │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────────────┐
│                         Repository Layer                                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐     │
│  │   Task   │ │  Habit   │ │   Goal   │ │ Project  │ │TimeTrack │ ... │
│  │   Repo   │ │   Repo   │ │   Repo   │ │   Repo   │ │   Repo   │     │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘     │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────────────┐
│                          Storage Layer (Hive)                            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐     │
│  │  tasks   │ │  habits  │ │  goals   │ │ projects │ │timeEntries│ ... │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘     │
└─────────────────────────────────────────────────────────────────────────┘
```

### Module Overview

**v1 Modules (Preserved)**:
- Today System: Aggregates today's tasks, habits, focus text, productivity score
- Task System: Task CRUD, completion toggling, date assignment
- Habit System: Habit tracking, daily resets, streak calculation

**v2 New Modules**:
- Goals System: Long-term goals, milestones, progress tracking, goal-task linking
- Projects System: Multi-task projects, templates, dependencies, project-goal linking
- Time Tracking System: Timer, manual time entry, time reports, productivity insights
- Calendar System: Week/month views, recurring tasks, time blocking, scheduling
- Notes System: Notes with tags, daily journal, mood tracking, photo attachments
- Life Areas System: Health, Finance, Relationships, Learning, Custom areas with metrics

### Flutter Folder Structure

```
lib/
├── main.dart                           # App entry, navigation, drawer setup
├── theme/
│   └── app_theme.dart                  # v1 theme (preserved)
├── screens/
│   ├── today_screen.dart               # v1 (enhanced with productivity score)
│   ├── tasks_screen.dart               # v1 (enhanced with goal linking)
│   ├── habits_screen.dart              # v1 (preserved)
│   ├── goals_screen.dart               # NEW: Goals list and creation
│   ├── goal_detail_screen.dart         # NEW: Goal details, milestones, progress
│   ├── projects_screen.dart            # NEW: Projects list and creation
│   ├── project_detail_screen.dart      # NEW: Project details, tasks, dependencies
│   ├── calendar_screen.dart            # NEW: Week/month views, time blocks
│   ├── time_tracking_screen.dart       # NEW: Timer, time entries, reports
│   ├── notes_screen.dart               # NEW: Notes list, search, tags
│   ├── journal_screen.dart             # NEW: Daily journal entries
│   ├── life_areas_dashboard_screen.dart # NEW: Life areas overview
│   ├── health_screen.dart              # NEW: Health metrics tracking
│   ├── finance_screen.dart             # NEW: Finance tracking
│   ├── relationships_screen.dart       # NEW: Contacts, important dates
│   └── learning_screen.dart            # NEW: Books, courses, skills
├── models/
│   ├── task.dart                       # v1 (enhanced with projectId, goalIds)
│   ├── habit.dart                      # v1 (preserved)
│   ├── goal.dart                       # NEW
│   ├── milestone.dart                  # NEW
│   ├── project.dart                    # NEW
│   ├── project_template.dart           # NEW
│   ├── time_entry.dart                 # NEW
│   ├── recurring_task.dart             # NEW
│   ├── time_block.dart                 # NEW
│   ├── note.dart                       # NEW
│   ├── journal_entry.dart              # NEW
│   ├── life_area.dart                  # NEW
│   ├── health_metric.dart              # NEW
│   ├── finance_transaction.dart        # NEW
│   ├── contact.dart                    # NEW
│   └── learning_item.dart              # NEW
├── data/
│   ├── storage_service.dart            # v1 (preserved)
│   ├── hive_storage_service.dart       # v1 (enhanced with new boxes)
│   ├── task_repository.dart            # v1 (enhanced)
│   ├── habit_repository.dart           # v1 (preserved)
│   ├── goal_repository.dart            # NEW
│   ├── project_repository.dart         # NEW
│   ├── time_tracking_repository.dart   # NEW
│   ├── calendar_repository.dart        # NEW
│   ├── notes_repository.dart           # NEW
│   └── life_areas_repository.dart      # NEW
├── services/
│   ├── analytics_engine.dart           # NEW: Productivity calculations
│   ├── notification_service.dart       # NEW: Deadline reminders
│   └── export_service.dart             # NEW: Data export
└── widgets/
    ├── task_item.dart                  # v1 (preserved)
    ├── habit_item.dart                 # v1 (preserved)
    ├── focus_text_field.dart           # v1 (preserved)
    ├── goal_card.dart                  # NEW
    ├── milestone_item.dart             # NEW
    ├── project_card.dart               # NEW
    ├── time_entry_item.dart            # NEW
    ├── calendar_day_cell.dart          # NEW
    ├── time_block_widget.dart          # NEW
    ├── note_card.dart                  # NEW
    ├── journal_entry_card.dart         # NEW
    └── life_area_card.dart             # NEW
```

## Data Models

### Enhanced v1 Models

**Task Model (Enhanced)**
```dart
@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  bool isDone;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  String? projectId;              // NEW: Link to project
  
  @HiveField(5)
  List<String> goalIds;           // NEW: Link to goals
  
  @HiveField(6)
  String? description;            // NEW: Optional details
  
  @HiveField(7)
  int? estimatedMinutes;          // NEW: Time estimate
}
```

**Habit Model (Unchanged)**
```dart
@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  bool isDoneToday;
  
  @HiveField(3)
  int streak;
}
```

### Goals System Models

**Goal Model**
```dart
@HiveType(typeId: 10)
class Goal extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  GoalCategory category;          // Career, Health, Finance, Relationships, Personal_Growth, Learning
  
  @HiveField(4)
  GoalStatus status;              // Active, Completed, Archived, On_Hold
  
  @HiveField(5)
  Priority priority;              // High, Medium, Low
  
  @HiveField(6)
  DateTime? deadline;
  
  @HiveField(7)
  String successMetrics;
  
  @HiveField(8)
  double progress;                // 0.0 to 1.0
  
  @HiveField(9)
  List<String> linkedTaskIds;
  
  @HiveField(10)
  List<String> linkedProjectIds;
  
  @HiveField(11)
  final DateTime createdDate;
}

@HiveType(typeId: 11)
enum GoalCategory {
  @HiveField(0)
  career,
  @HiveField(1)
  health,
  @HiveField(2)
  finance,
  @HiveField(3)
  relationships,
  @HiveField(4)
  personalGrowth,
  @HiveField(5)
  learning,
}

@HiveType(typeId: 12)
enum GoalStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  completed,
  @HiveField(2)
  archived,
  @HiveField(3)
  onHold,
}

@HiveType(typeId: 13)
enum Priority {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low,
}
```

**Milestone Model**
```dart
@HiveType(typeId: 14)
class Milestone extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String goalId;
  
  @HiveField(2)
  String title;
  
  @HiveField(3)
  DateTime targetDate;
  
  @HiveField(4)
  bool isCompleted;
  
  @HiveField(5)
  DateTime? completedDate;
}
```

### Projects System Models

**Project Model**
```dart
@HiveType(typeId: 20)
class Project extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  ProjectStatus status;           // Planning, Active, On_Hold, Completed, Archived
  
  @HiveField(4)
  String category;
  
  @HiveField(5)
  DateTime? deadline;
  
  @HiveField(6)
  String? linkedGoalId;
  
  @HiveField(7)
  double progress;                // 0.0 to 1.0 (calculated from tasks)
  
  @HiveField(8)
  final DateTime createdDate;
  
  @HiveField(9)
  DateTime? completedDate;
}

@HiveType(typeId: 21)
enum ProjectStatus {
  @HiveField(0)
  planning,
  @HiveField(1)
  active,
  @HiveField(2)
  onHold,
  @HiveField(3)
  completed,
  @HiveField(4)
  archived,
}
```

**Project Template Model**
```dart
@HiveType(typeId: 22)
class ProjectTemplate extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  List<TaskTemplate> taskTemplates;
}

@HiveType(typeId: 23)
class TaskTemplate {
  @HiveField(0)
  String title;
  
  @HiveField(1)
  String? description;
  
  @HiveField(2)
  int? estimatedMinutes;
  
  @HiveField(3)
  List<String> dependsOnTitles;   // Task titles this depends on
}
```

**Task Dependency Model**
```dart
@HiveType(typeId: 24)
class TaskDependency extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String taskId;            // Dependent task
  
  @HiveField(2)
  final String dependsOnTaskId;   // Task that must be completed first
}
```

### Time Tracking Models

**Time Entry Model**
```dart
@HiveType(typeId: 30)
class TimeEntry extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String? taskId;
  
  @HiveField(2)
  DateTime startTime;
  
  @HiveField(3)
  DateTime? endTime;              // null if timer is running
  
  @HiveField(4)
  int durationMinutes;            // Calculated or manual
  
  @HiveField(5)
  String category;
  
  @HiveField(6)
  String notes;
}
```

### Calendar Models

**Recurring Task Model**
```dart
@HiveType(typeId: 40)
class RecurringTask extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  RecurrencePattern pattern;
  
  @HiveField(3)
  DateTime startDate;
  
  @HiveField(4)
  DateTime? endDate;              // null for infinite recurrence
  
  @HiveField(5)
  DateTime nextOccurrence;
}

@HiveType(typeId: 41)
enum RecurrencePattern {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  custom,
}
```

**Time Block Model**
```dart
@HiveType(typeId: 42)
class TimeBlock extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  DateTime startTime;
  
  @HiveField(2)
  DateTime endTime;
  
  @HiveField(3)
  String? taskId;
  
  @HiveField(4)
  String title;
  
  @HiveField(5)
  String? description;
}
```

### Notes System Models

**Note Model**
```dart
@HiveType(typeId: 50)
class Note extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String content;
  
  @HiveField(3)
  List<String> tags;
  
  @HiveField(4)
  String? linkedEntityType;       // 'task', 'goal', 'project', null
  
  @HiveField(5)
  String? linkedEntityId;
  
  @HiveField(6)
  final DateTime createdDate;
  
  @HiveField(7)
  DateTime modifiedDate;
  
  @HiveField(8)
  List<String> photoUrls;         // Local file paths
}
```

**Journal Entry Model**
```dart
@HiveType(typeId: 51)
class JournalEntry extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime date;            // One entry per date
  
  @HiveField(2)
  String content;
  
  @HiveField(3)
  Mood? mood;
  
  @HiveField(4)
  List<String> gratitudeItems;
  
  @HiveField(5)
  List<String> photoUrls;
}

@HiveType(typeId: 52)
enum Mood {
  @HiveField(0)
  great,
  @HiveField(1)
  good,
  @HiveField(2)
  neutral,
  @HiveField(3)
  bad,
  @HiveField(4)
  terrible,
}
```

### Life Areas Models

**Life Area Model**
```dart
@HiveType(typeId: 60)
class LifeArea extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  LifeAreaType type;
  
  @HiveField(3)
  double healthScore;             // 0.0 to 1.0
  
  @HiveField(4)
  DateTime lastUpdated;
}

@HiveType(typeId: 61)
enum LifeAreaType {
  @HiveField(0)
  health,
  @HiveField(1)
  finance,
  @HiveField(2)
  relationships,
  @HiveField(3)
  learning,
  @HiveField(4)
  custom,
}
```

**Health Metric Model**
```dart
@HiveType(typeId: 62)
class HealthMetric extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime date;
  
  @HiveField(2)
  HealthMetricType type;
  
  @HiveField(3)
  double value;
  
  @HiveField(4)
  String? notes;
}

@HiveType(typeId: 63)
enum HealthMetricType {
  @HiveField(0)
  workout,
  @HiveField(1)
  waterIntake,
  @HiveField(2)
  sleep,
  @HiveField(3)
  weight,
  @HiveField(4)
  meals,
}
```

**Finance Transaction Model**
```dart
@HiveType(typeId: 64)
class FinanceTransaction extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime date;
  
  @HiveField(2)
  TransactionType type;           // Expense, Income
  
  @HiveField(3)
  String category;
  
  @HiveField(4)
  double amount;
  
  @HiveField(5)
  String description;
}

@HiveType(typeId: 65)
enum TransactionType {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
}
```

**Contact Model**
```dart
@HiveType(typeId: 66)
class Contact extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  List<ImportantDate> importantDates;
  
  @HiveField(3)
  DateTime? lastInteraction;
  
  @HiveField(4)
  String notes;
}

@HiveType(typeId: 67)
class ImportantDate {
  @HiveField(0)
  String label;                   // "Birthday", "Anniversary", etc.
  
  @HiveField(1)
  DateTime date;
}
```

**Learning Item Model**
```dart
@HiveType(typeId: 68)
class LearningItem extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  LearningType type;
  
  @HiveField(3)
  LearningStatus status;
  
  @HiveField(4)
  double progress;                // 0.0 to 1.0
  
  @HiveField(5)
  DateTime? completedDate;
}

@HiveType(typeId: 69)
enum LearningType {
  @HiveField(0)
  book,
  @HiveField(1)
  course,
  @HiveField(2)
  skill,
  @HiveField(3)
  certification,
}

@HiveType(typeId: 70)
enum LearningStatus {
  @HiveField(0)
  notStarted,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  paused,
}
```



## Components and Interfaces

### Goals System

**GoalRepository**
```dart
class GoalRepository {
  Future<List<Goal>> loadGoals();
  Future<void> saveGoal(Goal goal);
  Future<void> deleteGoal(String id);
  Future<List<Goal>> getGoalsByCategory(GoalCategory category);
  Future<List<Goal>> getActiveGoals();
  Future<void> updateGoalProgress(String goalId);
  
  Future<List<Milestone>> loadMilestones(String goalId);
  Future<void> saveMilestone(Milestone milestone);
  Future<void> deleteMilestone(String id);
  Future<void> completeMilestone(String id);
}
```

**Goal Operations**
- `createGoal()`: Creates goal with auto-generated id, current date, progress=0
- `updateGoalProgress()`: Recalculates progress based on completed milestones and linked tasks
- `linkTaskToGoal()`: Adds task ID to goal's linkedTaskIds list
- `linkProjectToGoal()`: Adds project ID to goal's linkedProjectIds list
- `createMilestone()`: Creates milestone linked to goal
- `completeMilestone()`: Marks milestone complete, updates goal progress

**Progress Calculation**
```dart
double calculateGoalProgress(Goal goal) {
  final milestones = getMilestonesForGoal(goal.id);
  final linkedTasks = getTasksForGoal(goal.id);
  
  final milestoneProgress = milestones.isEmpty ? 0.0 :
    milestones.where((m) => m.isCompleted).length / milestones.length;
  
  final taskProgress = linkedTasks.isEmpty ? 0.0 :
    linkedTasks.where((t) => t.isDone).length / linkedTasks.length;
  
  // Weight: 60% milestones, 40% tasks
  return (milestoneProgress * 0.6) + (taskProgress * 0.4);
}
```

### Projects System

**ProjectRepository**
```dart
class ProjectRepository {
  Future<List<Project>> loadProjects();
  Future<void> saveProject(Project project);
  Future<void> deleteProject(String id);
  Future<List<Project>> getProjectsByStatus(ProjectStatus status);
  Future<void> updateProjectProgress(String projectId);
  
  Future<List<ProjectTemplate>> loadTemplates();
  Future<void> saveTemplate(ProjectTemplate template);
  Future<Project> createProjectFromTemplate(String templateId);
  
  Future<List<TaskDependency>> loadDependencies(String projectId);
  Future<void> saveDependency(TaskDependency dependency);
  Future<bool> isTaskBlocked(String taskId);
}
```

**Project Operations**
- `createProject()`: Creates project with auto-generated id, current date, progress=0
- `createProjectFromTemplate()`: Generates project with all template tasks
- `updateProjectProgress()`: Calculates progress as completed tasks / total tasks
- `addTaskDependency()`: Creates dependency relationship, validates no circular deps
- `checkTaskBlocked()`: Returns true if task has incomplete dependencies

**Dependency Validation**
```dart
bool hasCircularDependency(String taskId, String dependsOnTaskId) {
  final visited = <String>{};
  final stack = [dependsOnTaskId];
  
  while (stack.isNotEmpty) {
    final current = stack.removeLast();
    if (current == taskId) return true;
    if (visited.contains(current)) continue;
    
    visited.add(current);
    final deps = getDependenciesForTask(current);
    stack.addAll(deps.map((d) => d.dependsOnTaskId));
  }
  
  return false;
}
```

### Time Tracking System

**TimeTrackingRepository**
```dart
class TimeTrackingRepository {
  Future<List<TimeEntry>> loadTimeEntries();
  Future<void> saveTimeEntry(TimeEntry entry);
  Future<void> deleteTimeEntry(String id);
  Future<TimeEntry?> getActiveTimer();
  Future<void> startTimer(String? taskId, String category);
  Future<void> stopTimer();
  
  Future<List<TimeEntry>> getEntriesForDateRange(DateTime start, DateTime end);
  Future<Map<String, int>> getTimeByCategory(DateTime start, DateTime end);
  Future<Map<String, int>> getTimeByGoal(DateTime start, DateTime end);
}
```

**Timer Operations**
- `startTimer()`: Creates time entry with startTime, endTime=null
- `stopTimer()`: Sets endTime, calculates duration, persists entry
- `getActiveTimer()`: Returns entry where endTime is null
- `addManualEntry()`: Creates entry with both startTime and endTime

**Time Report Generation**
```dart
Map<String, int> generateTimeReport(DateTime start, DateTime end) {
  final entries = getEntriesForDateRange(start, end);
  final report = <String, int>{};
  
  for (final entry in entries) {
    final category = entry.category;
    report[category] = (report[category] ?? 0) + entry.durationMinutes;
  }
  
  return report;
}
```

### Calendar System

**CalendarRepository**
```dart
class CalendarRepository {
  Future<List<Task>> getTasksForDateRange(DateTime start, DateTime end);
  Future<List<TimeBlock>> getTimeBlocksForDate(DateTime date);
  Future<void> saveTimeBlock(TimeBlock block);
  Future<void> deleteTimeBlock(String id);
  Future<bool> hasOverlappingTimeBlock(DateTime start, DateTime end, String? excludeId);
  
  Future<List<RecurringTask>> loadRecurringTasks();
  Future<void> saveRecurringTask(RecurringTask task);
  Future<void> deleteRecurringTask(String id);
  Future<void> generateNextOccurrence(String recurringTaskId);
}
```

**Calendar Operations**
- `scheduleTask()`: Sets task date to specific future date
- `createTimeBlock()`: Creates time block, validates no overlap
- `createRecurringTask()`: Creates recurring task with pattern
- `generateNextOccurrence()`: Creates new task instance, updates nextOccurrence date

**Recurrence Logic**
```dart
DateTime calculateNextOccurrence(RecurringTask task) {
  final current = task.nextOccurrence;
  
  switch (task.pattern) {
    case RecurrencePattern.daily:
      return current.add(Duration(days: 1));
    case RecurrencePattern.weekly:
      return current.add(Duration(days: 7));
    case RecurrencePattern.monthly:
      return DateTime(current.year, current.month + 1, current.day);
    case RecurrencePattern.custom:
      // Custom logic based on additional fields
      return current;
  }
}
```

### Notes System

**NotesRepository**
```dart
class NotesRepository {
  Future<List<Note>> loadNotes();
  Future<void> saveNote(Note note);
  Future<void> deleteNote(String id);
  Future<List<Note>> searchNotes(String query);
  Future<List<Note>> getNotesByTag(String tag);
  Future<List<Note>> getNotesForEntity(String entityType, String entityId);
  
  Future<JournalEntry?> getJournalEntryForDate(DateTime date);
  Future<void> saveJournalEntry(JournalEntry entry);
  Future<List<JournalEntry>> loadJournalEntries();
}
```

**Notes Operations**
- `createNote()`: Creates note with auto-generated id, current date
- `linkNoteToEntity()`: Sets linkedEntityType and linkedEntityId
- `addPhotoToNote()`: Saves photo to local storage, adds path to photoUrls
- `searchNotes()`: Searches title and content fields
- `createJournalEntry()`: Creates entry for specific date (one per date)

### Life Areas System

**LifeAreasRepository**
```dart
class LifeAreasRepository {
  Future<List<LifeArea>> loadLifeAreas();
  Future<void> saveLifeArea(LifeArea area);
  Future<void> deleteLifeArea(String id);
  Future<void> updateHealthScore(String areaId);
  
  // Health
  Future<List<HealthMetric>> loadHealthMetrics();
  Future<void> saveHealthMetric(HealthMetric metric);
  
  // Finance
  Future<List<FinanceTransaction>> loadTransactions();
  Future<void> saveTransaction(FinanceTransaction transaction);
  Future<Map<String, double>> getSpendingByCategory(DateTime start, DateTime end);
  
  // Relationships
  Future<List<Contact>> loadContacts();
  Future<void> saveContact(Contact contact);
  Future<List<Contact>> getContactsNeedingAttention();
  
  // Learning
  Future<List<LearningItem>> loadLearningItems();
  Future<void> saveLearningItem(LearningItem item);
}
```

**Life Area Operations**
- `createLifeArea()`: Creates life area with auto-generated id, healthScore=0
- `logHealthMetric()`: Saves health metric, updates life area health score
- `logTransaction()`: Saves finance transaction
- `logInteraction()`: Updates contact's lastInteraction date
- `updateHealthScore()`: Recalculates health score based on recent activity

**Health Score Calculation**
```dart
double calculateHealthScore(LifeArea area) {
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(Duration(days: 30));
  
  switch (area.type) {
    case LifeAreaType.health:
      final metrics = getHealthMetricsForDateRange(thirtyDaysAgo, now);
      final daysWithActivity = metrics.map((m) => m.date.day).toSet().length;
      return daysWithActivity / 30.0;
      
    case LifeAreaType.finance:
      final transactions = getTransactionsForDateRange(thirtyDaysAgo, now);
      return transactions.isNotEmpty ? 1.0 : 0.5;
      
    case LifeAreaType.relationships:
      final contacts = getContacts();
      final recentInteractions = contacts.where((c) =>
        c.lastInteraction != null &&
        c.lastInteraction!.isAfter(thirtyDaysAgo)
      ).length;
      return contacts.isEmpty ? 1.0 : recentInteractions / contacts.length;
      
    case LifeAreaType.learning:
      final items = getLearningItems();
      final activeItems = items.where((i) =>
        i.status == LearningStatus.inProgress
      ).length;
      return items.isEmpty ? 1.0 : activeItems / items.length;
      
    default:
      return 0.5;
  }
}
```

### Analytics Engine

**AnalyticsEngine**
```dart
class AnalyticsEngine {
  double calculateProductivityScore(DateTime date);
  Map<int, double> getProductivityTrend(DateTime start, DateTime end);
  Map<int, int> getMostProductiveHours();
  Map<int, double> getMostProductiveDays();
  Map<DateTime, int> getHabitCompletionHeatmap(String habitId, int days);
  Map<String, dynamic> getCrossAreaInsights();
}
```

**Productivity Score Calculation**
```dart
double calculateProductivityScore(DateTime date) {
  final tasks = getTasksForDate(date);
  final completedTasks = tasks.where((t) => t.isDone).length;
  final taskScore = tasks.isEmpty ? 0.0 : completedTasks / tasks.length;
  
  final habits = getHabits();
  final completedHabits = habits.where((h) => h.isDoneToday).length;
  final habitScore = habits.isEmpty ? 0.0 : completedHabits / habits.length;
  
  final timeEntries = getTimeEntriesForDate(date);
  final totalMinutes = timeEntries.fold(0, (sum, e) => sum + e.durationMinutes);
  final timeScore = (totalMinutes / 480.0).clamp(0.0, 1.0); // 8 hours = 100%
  
  final goals = getActiveGoals();
  final goalsProgressed = goals.where((g) {
    final previousProgress = getPreviousProgress(g.id, date);
    return g.progress > previousProgress;
  }).length;
  final goalScore = goals.isEmpty ? 0.0 : goalsProgressed / goals.length;
  
  // Weighted: tasks 30%, habits 25%, time 25%, goals 20%
  return (taskScore * 0.3) + (habitScore * 0.25) + (timeScore * 0.25) + (goalScore * 0.2);
}
```

### Storage System

**Enhanced HiveStorageService**
```dart
class HiveStorageService extends StorageService {
  late Box<Task> tasksBox;
  late Box<Habit> habitsBox;
  late Box<Goal> goalsBox;
  late Box<Milestone> milestonesBox;
  late Box<Project> projectsBox;
  late Box<ProjectTemplate> templatesBox;
  late Box<TaskDependency> dependenciesBox;
  late Box<TimeEntry> timeEntriesBox;
  late Box<RecurringTask> recurringTasksBox;
  late Box<TimeBlock> timeBlocksBox;
  late Box<Note> notesBox;
  late Box<JournalEntry> journalEntriesBox;
  late Box<LifeArea> lifeAreasBox;
  late Box<HealthMetric> healthMetricsBox;
  late Box<FinanceTransaction> transactionsBox;
  late Box<Contact> contactsBox;
  late Box<LearningItem> learningItemsBox;
  
  @override
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register v1 adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(HabitAdapter());
    
    // Register v2 adapters
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(GoalCategoryAdapter());
    Hive.registerAdapter(GoalStatusAdapter());
    Hive.registerAdapter(PriorityAdapter());
    Hive.registerAdapter(MilestoneAdapter());
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(ProjectStatusAdapter());
    Hive.registerAdapter(ProjectTemplateAdapter());
    Hive.registerAdapter(TaskTemplateAdapter());
    Hive.registerAdapter(TaskDependencyAdapter());
    Hive.registerAdapter(TimeEntryAdapter());
    Hive.registerAdapter(RecurringTaskAdapter());
    Hive.registerAdapter(RecurrencePatternAdapter());
    Hive.registerAdapter(TimeBlockAdapter());
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(JournalEntryAdapter());
    Hive.registerAdapter(MoodAdapter());
    Hive.registerAdapter(LifeAreaAdapter());
    Hive.registerAdapter(LifeAreaTypeAdapter());
    Hive.registerAdapter(HealthMetricAdapter());
    Hive.registerAdapter(HealthMetricTypeAdapter());
    Hive.registerAdapter(FinanceTransactionAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(ContactAdapter());
    Hive.registerAdapter(ImportantDateAdapter());
    Hive.registerAdapter(LearningItemAdapter());
    Hive.registerAdapter(LearningTypeAdapter());
    Hive.registerAdapter(LearningStatusAdapter());
    
    // Open all boxes
    tasksBox = await Hive.openBox<Task>('tasks');
    habitsBox = await Hive.openBox<Habit>('habits');
    goalsBox = await Hive.openBox<Goal>('goals');
    milestonesBox = await Hive.openBox<Milestone>('milestones');
    projectsBox = await Hive.openBox<Project>('projects');
    templatesBox = await Hive.openBox<ProjectTemplate>('templates');
    dependenciesBox = await Hive.openBox<TaskDependency>('dependencies');
    timeEntriesBox = await Hive.openBox<TimeEntry>('timeEntries');
    recurringTasksBox = await Hive.openBox<RecurringTask>('recurringTasks');
    timeBlocksBox = await Hive.openBox<TimeBlock>('timeBlocks');
    notesBox = await Hive.openBox<Note>('notes');
    journalEntriesBox = await Hive.openBox<JournalEntry>('journalEntries');
    lifeAreasBox = await Hive.openBox<LifeArea>('lifeAreas');
    healthMetricsBox = await Hive.openBox<HealthMetric>('healthMetrics');
    transactionsBox = await Hive.openBox<FinanceTransaction>('transactions');
    contactsBox = await Hive.openBox<Contact>('contacts');
    learningItemsBox = await Hive.openBox<LearningItem>('learningItems');
  }
}
```

### Navigation System

**Drawer Menu Structure**
```dart
Drawer(
  child: ListView(
    children: [
      DrawerHeader(
        child: Text('Ordin'),
      ),
      // v1 Core (also in bottom nav)
      ListTile(title: Text('Today'), onTap: () => navigate(TodayScreen())),
      ListTile(title: Text('Tasks'), onTap: () => navigate(TasksScreen())),
      ListTile(title: Text('Habits'), onTap: () => navigate(HabitsScreen())),
      
      Divider(),
      
      // v2 Modules
      ListTile(title: Text('Goals'), onTap: () => navigate(GoalsScreen())),
      ListTile(title: Text('Projects'), onTap: () => navigate(ProjectsScreen())),
      ListTile(title: Text('Calendar'), onTap: () => navigate(CalendarScreen())),
      ListTile(title: Text('Time Tracking'), onTap: () => navigate(TimeTrackingScreen())),
      ListTile(title: Text('Notes'), onTap: () => navigate(NotesScreen())),
      ListTile(title: Text('Journal'), onTap: () => navigate(JournalScreen())),
      ListTile(title: Text('Life Areas'), onTap: () => navigate(LifeAreasDashboardScreen())),
      ListTile(title: Text('Analytics'), onTap: () => navigate(AnalyticsScreen())),
      
      Divider(),
      
      ListTile(title: Text('Settings'), onTap: () => navigate(SettingsScreen())),
    ],
  ),
)
```

**Bottom Navigation (Preserved from v1)**
```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
    BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'Tasks'),
    BottomNavigationBarItem(icon: Icon(Icons.repeat), label: 'Habits'),
  ],
  onTap: (index) => setState(() => _selectedIndex = index),
)
```

## Screen Designs

### Enhanced Today Screen

**Layout**
```
┌─────────────────────────────────────┐
│ ☰  Today                         ⚙  │
├─────────────────────────────────────┤
│ Good morning, User!                 │
│ Productivity Score: 75/100 🔥       │
├─────────────────────────────────────┤
│ Focus                               │
│ ┌─────────────────────────────────┐ │
│ │ What matters most today?        │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Tasks (3)                           │
│ ☐ Task 1                            │
│ ☐ Task 2                            │
│ ☐ Task 3                            │
├─────────────────────────────────────┤
│ Habits (2)                          │
│ ☐ Habit 1  🔥 5                     │
│ ☐ Habit 2  🔥 12                    │
├─────────────────────────────────────┤
│ Upcoming (Next 7 days)              │
│ Tomorrow: 2 tasks, 1 deadline       │
│ Friday: 1 task, 1 time block        │
└─────────────────────────────────────┘
```

**New Features**
- Productivity score display (calculated by AnalyticsEngine)
- Upcoming section showing next 7 days preview
- Quick action FAB with expanded menu

### Goals Screen

**Layout**
```
┌─────────────────────────────────────┐
│ ☰  Goals                         +  │
├─────────────────────────────────────┤
│ Tabs: All | Career | Health | ...  │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Goal Title                      │ │
│ │ Category • Priority • Deadline  │ │
│ │ ████████░░ 80%                  │ │
│ │ 3 milestones • 5 tasks linked   │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Another Goal                    │ │
│ │ ...                             │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Features**
- Tab filtering by category
- Progress bars for each goal
- Tap to view goal details, milestones, linked tasks/projects

### Goal Detail Screen

**Layout**
```
┌─────────────────────────────────────┐
│ ←  Goal Title                    ⋮  │
├─────────────────────────────────────┤
│ Description text here...            │
│                                     │
│ Progress: ████████░░ 80%            │
│ Deadline: Dec 31, 2026              │
│ Priority: High                      │
├─────────────────────────────────────┤
│ Milestones (3)                   +  │
│ ✓ Milestone 1 (Completed)           │
│ ☐ Milestone 2 (Target: Nov 15)     │
│ ☐ Milestone 3 (Target: Dec 1)      │
├─────────────────────────────────────┤
│ Linked Tasks (5)                 +  │
│ ✓ Task 1                            │
│ ☐ Task 2                            │
├─────────────────────────────────────┤
│ Linked Projects (1)              +  │
│ Project Alpha (60% complete)        │
└─────────────────────────────────────┘
```

### Projects Screen

**Layout**
```
┌─────────────────────────────────────┐
│ ☰  Projects                      +  │
├─────────────────────────────────────┤
│ Tabs: Active | Planning | Complete │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Project Title                   │ │
│ │ Status • Deadline               │ │
│ │ ████████░░ 80%                  │ │
│ │ 8/10 tasks • Linked to Goal X   │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Calendar Screen

**Week View Layout**
```
┌─────────────────────────────────────┐
│ ☰  Calendar          Week | Month   │
├─────────────────────────────────────┤
│ < Nov 10-16, 2026 >                 │
├─────────────────────────────────────┤
│ Mon Tue Wed Thu Fri Sat Sun         │
│  10  11  12  13  14  15  16         │
├─────────────────────────────────────┤
│ 8:00  [Time Block: Focus Work]      │
│ 9:00                                │
│ 10:00 [Meeting]                     │
│ 11:00                               │
│ 12:00                               │
│ ...                                 │
└─────────────────────────────────────┘
```

**Month View Layout**
```
┌─────────────────────────────────────┐
│ ☰  Calendar          Week | Month   │
├─────────────────────────────────────┤
│ < November 2026 >                   │
├─────────────────────────────────────┤
│ Sun Mon Tue Wed Thu Fri Sat         │
│                         1   2       │
│  3   4   5   6   7   8   9          │
│     •2      •1  •3                  │
│ 10  11  12  13  14  15  16          │
│ •1  •2      •1                      │
│ ...                                 │
└─────────────────────────────────────┘
```

### Time Tracking Screen

**Layout**
```
┌─────────────────────────────────────┐
│ ☰  Time Tracking                    │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Active Timer                    │ │
│ │ Task: Write documentation       │ │
│ │ 01:23:45                        │ │
│ │ [Stop Timer]                    │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Today's Time                        │
│ Work: 3h 45m                        │
│ Learning: 1h 20m                    │
│ Total: 5h 5m                        │
├─────────────────────────────────────┤
│ Recent Entries                   +  │
│ Documentation - 1h 23m              │
│ Code Review - 45m                   │
│ Meeting - 1h 0m                     │
├─────────────────────────────────────┤
│ [View Reports]                      │
└─────────────────────────────────────┘
```

### Life Areas Dashboard

**Layout**
```
┌─────────────────────────────────────┐
│ ☰  Life Areas                       │
├─────────────────────────────────────┤
│ Overall Balance: 78/100             │
│ ████████████████░░░░                │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 💪 Health          85/100       │ │
│ │ ████████████████░░                │
│ │ Last updated: Today             │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 💰 Finance         72/100       │ │
│ │ ████████████░░░░░░                │
│ │ Last updated: 2 days ago        │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ ❤️  Relationships  65/100       │ │
│ │ ██████████░░░░░░░░                │
│ │ Needs attention                 │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```



## Implementation Strategy

### Phase 1: Goals System (Week 1-2)
**Priority: High** - Foundation for linking tasks to long-term objectives

**Tasks**:
1. Create Goal and Milestone models with Hive adapters
2. Implement GoalRepository with CRUD operations
3. Build GoalsScreen with category tabs and filtering
4. Build GoalDetailScreen with milestones and linked entities
5. Add goal linking to TasksScreen
6. Implement progress calculation logic
7. Add goal progress widgets to Today screen

**Dependencies**: None (builds on v1)

### Phase 2: Projects System (Week 3-4)
**Priority: High** - Organizes complex work

**Tasks**:
1. Create Project, ProjectTemplate, TaskDependency models
2. Implement ProjectRepository with template support
3. Build ProjectsScreen with status filtering
4. Build ProjectDetailScreen with task list and dependencies
5. Add project linking to TasksScreen
6. Implement dependency validation (circular check)
7. Add project templates (default + custom)

**Dependencies**: Phase 1 (for project-goal linking)

### Phase 3: Time Tracking & Analytics (Week 5-6)
**Priority: Medium** - Provides productivity insights

**Tasks**:
1. Create TimeEntry model
2. Implement TimeTrackingRepository with timer logic
3. Build TimeTrackingScreen with active timer display
4. Implement AnalyticsEngine with productivity score calculation
5. Add productivity score to Today screen
6. Build time reports (daily, weekly, monthly)
7. Implement productivity insights and trends

**Dependencies**: Phase 1, 2 (for time-by-goal, time-by-project reports)

### Phase 4: Calendar Integration (Week 7-8)
**Priority: Medium** - Enables future planning

**Tasks**:
1. Create RecurringTask and TimeBlock models
2. Implement CalendarRepository
3. Build CalendarScreen with week/month views
4. Implement time block creation with overlap validation
5. Add recurring task logic with pattern support
6. Add task scheduling to TasksScreen
7. Add upcoming view to Today screen

**Dependencies**: None (extends Task model)

### Phase 5: Notes & Journal System (Week 9-10)
**Priority: Low** - Documentation and reflection

**Tasks**:
1. Create Note and JournalEntry models
2. Implement NotesRepository
3. Build NotesScreen with search and tag filtering
4. Build JournalScreen with daily entries
5. Implement photo attachment support
6. Add note linking to tasks, goals, projects
7. Add note templates

**Dependencies**: Phase 1, 2 (for entity linking)

### Phase 6: Life Areas Dashboard (Week 11-12)
**Priority: Low** - Holistic life management

**Tasks**:
1. Create LifeArea and metric models (Health, Finance, Contact, Learning)
2. Implement LifeAreasRepository
3. Build LifeAreasDashboardScreen with health scores
4. Build HealthScreen with metric tracking
5. Build FinanceScreen with transaction tracking
6. Build RelationshipsScreen with contact management
7. Build LearningScreen with progress tracking
8. Implement health score calculation for each area

**Dependencies**: None (independent module)

### Phase 7: Integration & Polish (Week 13-14)
**Priority: High** - Tie everything together

**Tasks**:
1. Implement cross-module linking throughout app
2. Add notification service for deadlines
3. Implement data export functionality
4. Build settings screen with module preferences
5. Create onboarding flow for v2 features
6. Implement quick actions FAB
7. Performance optimization and testing
8. Update navigation drawer with all modules

**Dependencies**: All previous phases

## Migration Strategy

### v1 to v2 Data Migration

**Task Model Migration**
```dart
Future<void> migrateTasksToV2() async {
  final v1Tasks = await loadV1Tasks();
  
  for (final task in v1Tasks) {
    final v2Task = Task(
      id: task.id,
      title: task.title,
      isDone: task.isDone,
      date: task.date,
      projectId: null,           // NEW: Initialize as null
      goalIds: [],               // NEW: Initialize as empty
      description: null,         // NEW: Initialize as null
      estimatedMinutes: null,    // NEW: Initialize as null
    );
    
    await saveTask(v2Task);
  }
}
```

**Habit Model** - No migration needed (unchanged)

**Storage Initialization**
```dart
Future<void> initializeV2Storage() async {
  final prefs = await SharedPreferences.getInstance();
  final isV2Migrated = prefs.getBool('v2_migrated') ?? false;
  
  if (!isV2Migrated) {
    await migrateTasksToV2();
    await prefs.setBool('v2_migrated', true);
  }
  
  // Initialize default life areas
  await createDefaultLifeAreas();
}

Future<void> createDefaultLifeAreas() async {
  final areas = [
    LifeArea(id: uuid(), name: 'Health', type: LifeAreaType.health, healthScore: 0.5, lastUpdated: DateTime.now()),
    LifeArea(id: uuid(), name: 'Finance', type: LifeAreaType.finance, healthScore: 0.5, lastUpdated: DateTime.now()),
    LifeArea(id: uuid(), name: 'Relationships', type: LifeAreaType.relationships, healthScore: 0.5, lastUpdated: DateTime.now()),
    LifeArea(id: uuid(), name: 'Learning', type: LifeAreaType.learning, healthScore: 0.5, lastUpdated: DateTime.now()),
  ];
  
  for (final area in areas) {
    await saveLifeArea(area);
  }
}
```

## Performance Considerations

### Optimization Strategies

**Lazy Loading**
- Load only visible data on screen initialization
- Use pagination for large lists (notes, time entries, transactions)
- Load linked entities on demand (don't preload all goal tasks)

**Caching**
- Cache calculated values (goal progress, project progress, health scores)
- Invalidate cache only when underlying data changes
- Use in-memory cache for frequently accessed data

**Indexing**
- Index tasks by date for fast Today screen loading
- Index time entries by date for fast report generation
- Index notes by tags for fast filtering

**Background Processing**
- Calculate productivity scores in background isolate
- Generate reports asynchronously
- Process recurring task generation in background

**Performance Targets** (Same as v1)
- Tap interactions: < 100ms
- Screen navigation: < 300ms
- App launch: < 2 seconds
- Data save operations: < 100ms
- Data load operations: < 500ms
- Chart/visualization updates: < 200ms

### Memory Management

**Hive Box Management**
- Keep only active boxes open
- Close unused boxes when navigating away from modules
- Use lazy boxes for large collections (time entries, transactions)

**Image Handling**
- Compress photos before storage (max 1920x1080)
- Use thumbnails for list views
- Load full images only on detail view

## Error Handling

### Module-Specific Error Handling

**Goals System**
- Invalid progress calculation: Default to 0.0, log error
- Missing linked entities: Filter out invalid IDs, continue operation
- Circular goal-project links: Prevent at creation time

**Projects System**
- Circular dependencies: Validate before saving, show error dialog
- Template generation failure: Show error, allow manual project creation
- Missing project tasks: Display empty state, allow task creation

**Time Tracking**
- Multiple active timers: Stop previous timer automatically
- Negative duration: Validate start < end, show error
- Timer running during app close: Save state, resume on reopen

**Calendar**
- Overlapping time blocks: Validate before saving, show error
- Invalid recurrence pattern: Default to daily, log warning
- Past date scheduling: Allow but show warning

**Notes System**
- Photo save failure: Show error, continue without photo
- Search timeout: Show partial results, log warning
- Invalid entity link: Remove link, continue operation

**Life Areas**
- Health score calculation error: Default to 0.5, log error
- Missing metric data: Show empty state, prompt for data entry
- Budget exceeded: Show warning notification, continue operation

### General Error Strategy

- All errors logged with module context
- User-facing errors are actionable
- Critical errors prevent further operations
- Non-critical errors allow retry
- Graceful degradation (missing data shows empty state)

## Testing Strategy

### Unit Tests

**Goals System**
- Goal progress calculation with various milestone/task combinations
- Milestone completion updates goal progress
- Task linking adds to linkedTaskIds list
- Goal deletion removes all milestones

**Projects System**
- Project progress calculation from task completion
- Circular dependency detection
- Template generation creates all tasks
- Task dependency blocking logic

**Time Tracking**
- Timer start/stop updates time entry correctly
- Duration calculation is accurate
- Only one active timer allowed
- Time report aggregation by category/goal

**Calendar**
- Recurring task next occurrence calculation
- Time block overlap detection
- Task scheduling updates date correctly
- Week/month view date range calculation

**Notes System**
- Note search finds matches in title and content
- Tag filtering returns correct notes
- Entity linking stores correct type and ID
- Journal entry one-per-date constraint

**Life Areas**
- Health score calculation for each area type
- Metric logging updates health score
- Contact attention detection (no recent interaction)
- Learning progress tracking

**Analytics Engine**
- Productivity score calculation with all factors
- Trend calculation over date ranges
- Heatmap generation for habits
- Cross-area insight generation

### Integration Tests

**End-to-End Flows**
- Create goal → add milestone → link task → complete task → verify progress
- Create project from template → add dependencies → complete tasks in order
- Start timer → stop timer → view report → verify time logged
- Schedule recurring task → verify next occurrence generated
- Create note → link to task → view task → verify note appears
- Log health metric → verify health score updates → view dashboard

**Navigation Tests**
- Drawer menu navigates to all modules
- Bottom nav preserves v1 behavior
- Back button navigation works correctly
- Deep linking to entity details

**Performance Tests**
- App launch time < 2 seconds with full v2 data
- Today screen loads < 500ms with 50 tasks, 20 habits
- Goals screen loads < 500ms with 100 goals
- Calendar month view renders < 300ms
- Time report generation < 1 second for 1000 entries

### Property-Based Tests

**Universal Properties**
- Task toggle idempotence (v1 property preserved)
- Goal progress always between 0.0 and 1.0
- Project progress always between 0.0 and 1.0
- No circular dependencies in project tasks
- Time entry duration always positive
- No overlapping time blocks
- Productivity score always between 0.0 and 1.0
- Health scores always between 0.0 and 1.0
- All entity IDs are unique across all models

## Security Considerations

### Data Privacy

**Local Storage**
- All data stored locally, no cloud sync
- No network requests for data operations
- Photos stored in app-private directory
- No analytics or tracking

**Data Export**
- Export requires explicit user action
- Export files saved to user-accessible location
- No automatic backups to cloud

### Input Validation

**Text Fields**
- Sanitize all user input before storage
- Limit text field lengths (title: 200 chars, description: 2000 chars)
- Validate date inputs are reasonable (not year 9999)
- Validate numeric inputs (amounts, durations) are positive

**File Uploads**
- Validate photo file types (jpg, png only)
- Limit photo file size (max 10MB)
- Compress photos before storage
- Validate file paths are within app directory

## Accessibility

### Screen Reader Support

- All interactive elements have semantic labels
- Progress bars announce percentage
- Timer announces elapsed time
- Charts have text descriptions

### Visual Accessibility

- Maintain v1 color contrast ratios (WCAG AA)
- Support system font size scaling
- Color is not the only indicator (use icons + text)
- Focus indicators visible on all interactive elements

### Interaction Accessibility

- All actions accessible via tap (no gestures required)
- Minimum touch target size 44x44 points
- Swipe actions have alternative button access
- Form fields have clear labels and error messages

## Future Expansion

### Potential v3 Features

**Cloud Sync**
- Optional cloud backup
- Multi-device sync
- Shared projects/goals with others

**AI Insights**
- Smart goal suggestions based on patterns
- Automatic time categorization
- Predictive task scheduling

**Integrations**
- Calendar app integration (Google Calendar, Apple Calendar)
- Fitness app integration (Apple Health, Google Fit)
- Finance app integration (bank accounts, budgets)

**Advanced Analytics**
- Machine learning for productivity predictions
- Correlation analysis between life areas
- Personalized recommendations

**Collaboration**
- Shared projects with team members
- Goal accountability partners
- Family relationship tracking

### Architecture Extensibility

The v2 architecture supports future expansion through:
- Modular repository pattern (easy to add new modules)
- Flexible entity linking system (supports new entity types)
- Plugin-style analytics engine (easy to add new calculations)
- Extensible life areas (custom areas with custom metrics)


# Implementation Tasks: Ordin v2 - Life Control System

## Phase 1: Goals System

### Task 1.1: Create Goal Data Models
**Status**: pending
**Priority**: high
**Estimated Time**: 2 hours

Create Goal, Milestone, and enum models with Hive type adapters.

**Acceptance Criteria**:
- Goal model with all 11 fields defined
- Milestone model with all 6 fields defined
- GoalCategory, GoalStatus, Priority enums with Hive adapters
- All models have toJson/fromJson methods
- Hive type IDs assigned (10-14)

**Files to Create**:
- `lib/models/goal.dart`
- `lib/models/milestone.dart`

### Task 1.2: Implement GoalRepository
**Status**: pending
**Priority**: high
**Estimated Time**: 3 hours

Create repository for goal and milestone CRUD operations.

**Acceptance Criteria**:
- GoalRepository class with all methods from design doc
- Load/save/delete operations for goals
- Load/save/delete operations for milestones
- Progress calculation method implemented
- All operations complete within 100ms

**Files to Create**:
- `lib/data/goal_repository.dart`

### Task 1.3: Update HiveStorageService for Goals
**Status**: pending
**Priority**: high
**Estimated Time**: 1 hour

Register goal adapters and open goal/milestone boxes.

**Acceptance Criteria**:
- Goal and Milestone adapters registered
- goalsBox and milestonesBox opened in init()
- No breaking changes to existing v1 storage

**Files to Modify**:
- `lib/data/hive_storage_service.dart`

### Task 1.4: Build GoalsScreen UI
**Status**: pending
**Priority**: high
**Estimated Time**: 4 hours

Create goals list screen with category tabs and filtering.

**Acceptance Criteria**:
- Tab bar with all 6 goal categories
- Goal cards showing title, category, priority, deadline, progress
- Progress bar visualization
- Floating action button to create new goal
- Tap goal card navigates to detail screen
- Empty state when no goals exist

**Files to Create**:
- `lib/screens/goals_screen.dart`
- `lib/widgets/goal_card.dart`

### Task 1.5: Build GoalDetailScreen UI
**Status**: pending
**Priority**: high
**Estimated Time**: 5 hours

Create goal detail screen with milestones and linked entities.

**Acceptance Criteria**:
- Display all goal properties
- Milestones section with add/complete/delete
- Linked tasks section with add/remove
- Linked projects section with add/remove
- Progress bar updates when milestones/tasks change
- Edit goal properties
- Delete goal with confirmation

**Files to Create**:
- `lib/screens/goal_detail_screen.dart`
- `lib/widgets/milestone_item.dart`

### Task 1.6: Add Goal Linking to TasksScreen
**Status**: pending
**Priority**: medium
**Estimated Time**: 2 hours

Allow linking tasks to goals from tasks screen.

**Acceptance Criteria**:
- Task creation/edit dialog has goal selection
- Multi-select goals (task can link to multiple)
- Task item shows linked goal badges
- Tapping goal badge navigates to goal detail

**Files to Modify**:
- `lib/screens/tasks_screen.dart`
- `lib/widgets/task_item.dart`

### Task 1.7: Enhance Task Model for Goal Linking
**Status**: pending
**Priority**: high
**Estimated Time**: 1 hour

Add goalIds field to Task model.

**Acceptance Criteria**:
- Task model has goalIds List<String> field
- Hive field annotation added
- Migration logic preserves existing tasks
- toJson/fromJson updated

**Files to Modify**:
- `lib/models/task.dart`

### Task 1.8: Add Goal Progress to Today Screen
**Status**: pending
**Priority**: low
**Estimated Time**: 2 hours

Display active goals with progress on Today screen.

**Acceptance Criteria**:
- "Active Goals" section on Today screen
- Shows top 3 active goals by priority
- Progress bars for each goal
- Tap goal navigates to detail screen

**Files to Modify**:
- `lib/screens/today_screen.dart`

## Phase 2: Projects System

### Task 2.1: Create Project Data Models
**Status**: pending
**Priority**: high
**Estimated Time**: 3 hours

Create Project, ProjectTemplate, TaskTemplate, TaskDependency models.

**Acceptance Criteria**:
- Project model with all 10 fields
- ProjectTemplate and TaskTemplate models
- TaskDependency model
- ProjectStatus enum with Hive adapter
- All models have toJson/fromJson methods
- Hive type IDs assigned (20-24)

**Files to Create**:
- `lib/models/project.dart`
- `lib/models/project_template.dart`
- `lib/models/task_dependency.dart`

### Task 2.2: Implement ProjectRepository
**Status**: pending
**Priority**: high
**Estimated Time**: 4 hours

Create repository for project operations including templates and dependencies.

**Acceptance Criteria**:
- ProjectRepository class with all methods
- CRUD operations for projects
- Template save/load/apply operations
- Dependency management with circular check
- Progress calculation from task completion
- isTaskBlocked() method implemented

**Files to Create**:
- `lib/data/project_repository.dart`

### Task 2.3: Update HiveStorageService for Projects
**Status**: pending
**Priority**: high
**Estimated Time**: 1 hour

Register project adapters and open boxes.

**Acceptance Criteria**:
- All project adapters registered
- projectsBox, templatesBox, dependenciesBox opened
- No breaking changes to existing storage

**Files to Modify**:
- `lib/data/hive_storage_service.dart`

### Task 2.4: Build ProjectsScreen UI
**Status**: pending
**Priority**: high
**Estimated Time**: 4 hours

Create projects list screen with status filtering.

**Acceptance Criteria**:
- Tab bar with status filters (Active, Planning, Completed)
- Project cards showing title, status, deadline, progress
- Progress bar visualization
- FAB to create new project or use template
- Tap project navigates to detail screen
- Empty state when no projects

**Files to Create**:
- `lib/screens/projects_screen.dart`
- `lib/widgets/project_card.dart`

### Task 2.5: Build ProjectDetailScreen UI
**Status**: pending
**Priority**: high
**Estimated Time**: 5 hours

Create project detail screen with tasks and dependencies.

**Acceptance Criteria**:
- Display all project properties
- Task list with add/complete/delete
- Dependency visualization (blocked tasks grayed out)
- Add dependency dialog with circular check
- Link to goal if applicable
- Progress updates automatically
- Edit project properties
- Delete project with confirmation

**Files to Create**:
- `lib/screens/project_detail_screen.dart`

### Task 2.6: Add Project Linking to TasksScreen
**Status**: pending
**Priority**: medium
**Estimated Time**: 2 hours

Allow assigning tasks to projects.

**Acceptance Criteria**:
- Task creation/edit dialog has project selection
- Single-select project (task belongs to one project)
- Task item shows project badge
- Tapping project badge navigates to project detail

**Files to Modify**:
- `lib/screens/tasks_screen.dart`
- `lib/widgets/task_item.dart`

### Task 2.7: Enhance Task Model for Project Linking
**Status**: pending
**Priority**: high
**Estimated Time**: 1 hour

Add projectId and description fields to Task model.

**Acceptance Criteria**:
- Task model has projectId String? field
- Task model has description String? field
- Task model has estimatedMinutes int? field
- Hive field annotations added
- Migration logic preserves existing tasks
- toJson/fromJson updated

**Files to Modify**:
- `lib/models/task.dart`

### Task 2.8: Create Default Project Templates
**Status**: pending
**Priority**: low
**Estimated Time**: 2 hours

Create 3-5 default project templates.

**Acceptance Criteria**:
- Templates for common project types (e.g., "Launch Product", "Learn New Skill", "Home Renovation")
- Each template has 5-10 predefined tasks
- Templates saved on first app launch
- User can create custom templates

**Files to Modify**:
- `lib/data/project_repository.dart`

## Phase 3: Time Tracking & Analytics

### Task 3.1: Create TimeEntry Data Model
**Status**: pending
**Priority**: high
**Estimated Time**: 1 hour

Create TimeEntry model with Hive adapter.

**Acceptance Criteria**:
- TimeEntry model with all 7 fields
- Hive type ID assigned (30)
- toJson/fromJson methods
- Duration calculation helper method

**Files to Create**:
- `lib/models/time_entry.dart`

### Task 3.2: Implement TimeTrackingRepository
**Status**: pending
**Priority**: high
**Estimated Time**: 3 hours

Create repository for time tracking operations.

**Acceptance Criteria**:
- TimeTrackingRepository with all methods
- startTimer() creates entry with null endTime
- stopTimer() sets endTime and calculates duration
- getActiveTimer() returns running timer or null
- Manual entry creation
- Date range queries for reports

**Files to Create**:
- `lib/data/time_tracking_repository.dart`

### Task 3.3: Update HiveStorageService for Time Tracking
**Status**: pending
**Priority**: high
**Estimated Time**: 1 hour

Register time entry adapter and open box.

**Acceptance Criteria**:
- TimeEntry adapter registered
- timeEntriesBox opened
- No breaking changes

**Files to Modify**:
- `lib/data/hive_storage_service.dart`

### Task 3.4: Build TimeTrackingScreen UI
**Status**: pending
**Priority**: high
**Estimated Time**: 5 hours

Create time tracking screen with timer and entries list.

**Acceptance Criteria**:
- Active timer display with elapsed time updating every second
- Start/stop timer buttons
- Task selection for timer
- Today's time summary by category
- Recent entries list
- Add manual entry button
- View reports button

**Files to Create**:
- `lib/screens/time_tracking_screen.dart`
- `lib/widgets/time_entry_item.dart`

### Task 3.5: Implement AnalyticsEngine
**Status**: pending
**Priority**: high
**Estimated Time**: 4 hours

Create analytics engine for productivity calculations.

**Acceptance Criteria**:
- AnalyticsEngine class with all methods
- calculateProductivityScore() with weighted factors
- getProductivityTrend() for date ranges
- getMostProductiveHours() analysis
- getMostProductiveDays() analysis
- getHabitCompletionHeatmap() generation
- All calculations complete within 500ms

**Files to Create**:
- `lib/services/analytics_engine.dart`

### Task 3.6: Add Productivity Score to Today Screen
**Status**: pending
**Priority**: high
**Estimated Time**: 2 hours

Display daily productivity score on Today screen.

**Acceptance Criteria**:
- Productivity score displayed prominently (0-100)
- Score updates when tasks/habits completed
- Visual indicator (color, icon) based on score
- Tap score navigates to analytics screen

**Files to Modify**:
- `lib/screens/today_screen.dart`

### Task 3.7: Build Time Reports Screen
**Status**: pending
**Priority**: medium
**Estimated Time**: 4 hours

Create screen for viewing time reports.

**Acceptance Criteria**:
- Period selector (Daily, Weekly, Monthly)
- Time by category chart
- Time by goal chart
- Time by project chart
- Export report button
- Date range navigation

**Files to Create**:
- `lib/screens/time_reports_screen.dart`

### Task 3.8: Build Analytics Screen
**Status**: pending
**Priority**: medium
**Estimated Time**: 5 hours

Create comprehensive analytics dashboard.

**Acceptance Criteria**:
- Productivity trend chart (last 30 days)
- Most productive hours chart
- Most productive days chart
- Habit completion heatmap for each habit
- Streak statistics
- Cross-area insights

**Files to Create**:
- `lib/screens/analytics_screen.dart`

## Phase 4: Calendar Integration

### Task 4.1: Create Calendar Data Models
**Status**: pending
**Priority**: high
**Estimated Time**: 2 hours

Create RecurringTask and TimeBlock models.

**Acceptance Criteria**:
- RecurringTask model with all 6 fields
- TimeBlock model with all 6 fields
- RecurrencePattern enum with Hive adapter
- Hive type IDs assigned (40-42)
- toJson/fromJson methods

**Files to Create**:
- `lib/models/recurring_task.dart`
- `lib/models/time_block.dart`

### Task 4.2: Implement CalendarRepository
**Status**: pending
**Priority**: high
**Estimated Time**: 3 hours

Create repository for calendar operations.

**Acceptance Criteria**:
- CalendarRepository with all methods
- Date range task queries
- Time block CRUD with overlap validation
- Recurring task management
- Next occurrence calculation
- Task instance generation

**Files to Create**:
- `lib/data/calendar_repository.dart`

### Task 4.3: Update HiveStorageService for Calendar
**Status**: pending
**Priority**: high
**Estimated Time**: 1 hour

Register calendar adapters and open boxes.

**Acceptance Criteria**:
- RecurringTask and TimeBlock adapters registered
- recurringTasksBox and timeBlocksBox opened
- No breaking changes

**Files to Modify**:
- `lib/data/hive_storage_service.dart`

### Task 4.4: Build CalendarScreen with Week View
**Status**: pending
**Priority**: high
**Estimated Time**: 6 hours

Create calendar screen with week view.

**Acceptance Criteria**:
- Week view showing 7 days
- Hourly time slots (6am-11pm)
- Time blocks displayed in slots
- Tasks displayed on dates
- Drag to create time block
- Tap time block to edit/delete
- Week navigation (previous/next)
- Switch to month view button

**Files to Create**:
- `lib/screens/calendar_screen.dart`
- `lib/widgets/calendar_day_cell.dart`
- `lib/widgets/time_block_widget.dart`

### Task 4.5: Add Month View to CalendarScreen
**Status**: pending
**Priority**: high
**Estimated Time**: 4 hours

Add month view to calendar screen.

**Acceptance Criteria**:
- Month view showing all days
- Task count badges on dates
- Tap date to view day details
- Month navigation (previous/next)
- Switch to week view button
- Current date highlighted

**Files to Modify**:
- `lib/screens/calendar_screen.dart`

### Task 4.6: Add Task Scheduling to TasksScreen
**Status**: pending
**Priority**: medium
**Estimated Time**: 2 hours

Allow scheduling tasks for future dates.

**Acceptance Criteria**:
- Task creation/edit has date picker
- Default date is today
- Can select any future date
- Task appears on calendar on selected date

**Files to Modify**:
- `lib/screens/tasks_screen.dart`

### Task 4.7: Implement Recurring Tasks
**Status**: pending
**Priority**: medium
**Estimated Time**: 3 hours

Add recurring task creation and management.

**Acceptance Criteria**:
- Create recurring task dialog
- Pattern selection (Daily, Weekly, Monthly)
- Start date and optional end date
- Automatic task generation on date arrival
- Edit/delete recurring pattern
- Edit/delete individual instances

**Files to Create**:
- `lib/screens/recurring_task_dialog.dart`

### Task 4.8: Add Upcoming View to Today Screen
**Status**: pending
**Priority**: low
**Estimated Time**: 2 hours

Display upcoming items for next 7 days on Today screen.

**Acceptance Criteria**:
- "Upcoming" section on Today screen
- Shows next 7 days with item counts
- Includes tasks, time blocks, deadlines
- Tap day navigates to calendar

**Files to Modify**:
- `lib/screens/today_screen.dart`

## Phase 5: Notes & Journal System

### Task 5.1: Create Notes Data Models
**Status**: pending
**Priority**: high
**Estimated Time**: 2 hours

Create Note and JournalEntry models.

**Acceptance Criteria**:
- Note model with all 9 fields
- JournalEntry model with all 6 fields
- Mood enum with Hive adapter
- Hive type IDs assigned (50-52)
- toJson/fromJson methods

**Files to Create**:
- `lib/models/note.dart`
- `lib/models/journal_entry.dart`

### Task 5.2: Implement NotesRepository
**Status**: pending
**Priority**: high
**Estimated Time**: 3 hours

Create repository for notes and journal operations.

**Acceptance Criteria**:
- NotesRepository with all methods
- Note CRUD operations
- Search functionality (title + content)
- Tag filtering
- Entity linking queries
- Journal entry CRUD (one per date)
- Photo path management

**Files to Create**:
- `lib/data/notes_repository.dart`

### Task 5.3: Update HiveStorageService for Notes
**Status**: pending
**Priority**: high
**Estimated Time**: 1 hour

Register notes adapters and open boxes.

**Acceptance Criteria**:
- Note and JournalEntry adapters registered
- notesBox and journalEntriesBox opened
- No breaking changes

**Files to Modify**:
- `lib/data/hive_storage_service.dart`

### Task 5.4: Build NotesScreen UI
**Status**: pending
**Priority**: high
**Estimated Time**: 4 hours

Create notes list screen with search and filtering.

**Acceptance Criteria**:
- Notes list sorted by modified date
- Search bar for title/content search
- Tag filter chips
- Note cards showing title, preview, tags
- FAB to create new note
- Tap note navigates to detail/edit
- Empty state when no notes

**Files to Create**:
- `lib/screens/notes_screen.dart`
- `lib/widgets/note_card.dart`

### Task 5.5: Build Note Detail/Edit Screen
**Status**: pending
**Priority**: high
**Estimated Time**: 4 hours

Create screen for viewing and editing notes.

**Acceptance Criteria**:
- Title and content text fields
- Tag management (add/remove)
- Entity linking (select task/goal/project)
- Photo attachment (add/view/delete)
- Save button
- Delete note button
- Modified date updates on save

**Files to Create**:
- `lib/screens/note_detail_screen.dart`

### Task 5.6: Build JournalScreen UI
**Status**: pending
**Priority**: high
**Estimated Time**: 4 hours

Create daily journal screen.

**Acceptance Criteria**:
- Date selector (defaults to today)
- One entry per date
- Content text field
- Mood selector (5 moods with icons)
- Gratitude items list (add/remove)
- Photo attachments
- Save button
- Journal history list

**Files to Create**:
- `lib/screens/journal_screen.dart`
- `lib/widgets/journal_entry_card.dart`

### Task 5.7: Implement Photo Attachment
**Status**: pending
**Priority**: medium
**Estimated Time**: 3 hours

Add photo capture and storage functionality.

**Acceptance Criteria**:
- Camera capture or gallery selection
- Photo compression (max 1920x1080)
- Save to app-private directory
- Thumbnail generation for lists
- Full-screen photo viewer
- Delete photo functionality

**Files to Create**:
- `lib/services/photo_service.dart`

### Task 5.8: Add Note Linking Throughout App
**Status**: pending
**Priority**: low
**Estimated Time**: 2 hours

Allow creating notes linked to tasks, goals, projects.

**Acceptance Criteria**:
- "Add Note" button on task/goal/project detail screens
- Creates note with entity link pre-filled
- Linked notes section on detail screens
- Tap note navigates to note detail

**Files to Modify**:
- `lib/screens/goal_detail_screen.dart`
- `lib/screens/project_detail_screen.dart`
- `lib/screens/tasks_screen.dart`

## Phase 6: Life Areas Dashboard

### Task 6.1: Create Life Areas Data Models
**Status**: pending
**Priority**: high
**Estimated Time**: 3 hours

Create LifeArea and all metric models.

**Acceptance Criteria**:
- LifeArea model with all 5 fields
- HealthMetric model with all 5 fields
- FinanceTransaction model with all 6 fields
- Contact model with all 5 fields
- LearningItem model with all 6 fields
- All enums with Hive adapters
- Hive type IDs assigned (60-70)
- toJson/fromJson methods

**Files to Create**:
- `lib/models/life_area.dart`
- `lib/models/health_metric.dart`
- `lib/models/finance_transaction.dart`
- `lib/models/contact.dart`
- `lib/models/learning_item.dart`

### Task 6.2: Implement LifeAreasRepository
**Status**: pending
**Priority**: high
**Estimated Time**: 4 hours

Create repository for all life areas operations.

**Acceptance Criteria**:
- LifeAreasRepository with all methods
- Life area CRUD operations
- Health metric logging and queries
- Finance transaction logging and queries
- Contact management
- Learning item management
- Health score calculation for each area type

**Files to Create**:
- `lib/data/life_areas_repository.dart`

### Task 6.3: Update HiveStorageService for Life Areas
**Status**: pending
**Priority**: high
**Estimated Time**: 1 hour

Register life areas adapters and open boxes.

**Acceptance Criteria**:
- All life area adapters registered
- All boxes opened (lifeAreas, healthMetrics, transactions, contacts, learningItems)
- Default life areas created on first launch
- No breaking changes

**Files to Modify**:
- `lib/data/hive_storage_service.dart`

### Task 6.4: Build LifeAreasDashboardScreen UI
**Status**: pending
**Priority**: high
**Estimated Time**: 4 hours

Create life areas overview dashboard.

**Acceptance Criteria**:
- Overall balance score display
- Life area cards with health scores
- Color coding (red/yellow/green)
- Last updated timestamps
- Tap area navigates to detail screen
- Add custom area button
- Empty state for new users

**Files to Create**:
- `lib/screens/life_areas_dashboard_screen.dart`
- `lib/widgets/life_area_card.dart`

### Task 6.5: Build HealthScreen UI
**Status**: pending
**Priority**: high
**Estimated Time**: 5 hours

Create health tracking screen.

**Acceptance Criteria**:
- Metric type selector (Workout, Water, Sleep, Weight, Meals)
- Log metric form with date, value, notes
- Metric history list
- Charts showing trends
- Daily targets with progress
- Health score display

**Files to Create**:
- `lib/screens/health_screen.dart`

### Task 6.6: Build FinanceScreen UI
**Status**: pending
**Priority**: high
**Estimated Time**: 5 hours

Create finance tracking screen.

**Acceptance Criteria**:
- Transaction type selector (Expense, Income)
- Log transaction form with date, category, amount, description
- Transaction history list
- Spending by category chart
- Budget management (set/view/edit)
- Budget warnings when exceeded
- Finance score display

**Files to Create**:
- `lib/screens/finance_screen.dart`

### Task 6.7: Build RelationshipsScreen UI
**Status**: pending
**Priority**: high
**Estimated Time**: 4 hours

Create relationships management screen.

**Acceptance Criteria**:
- Contacts list sorted by last interaction
- Add contact form with name, important dates, notes
- Log interaction button (updates lastInteraction)
- Important date reminders
- Contacts needing attention highlighted
- Relationship score display

**Files to Create**:
- `lib/screens/relationships_screen.dart`

### Task 6.8: Build LearningScreen UI
**Status**: pending
**Priority**: high
**Estimated Time**: 4 hours

Create learning tracking screen.

**Acceptance Criteria**:
- Learning type tabs (Books, Courses, Skills, Certifications)
- Status filter (Not Started, In Progress, Completed, Paused)
- Add learning item form
- Progress tracking (0-100%)
- Completion date recording
- Learning score display

**Files to Create**:
- `lib/screens/learning_screen.dart`

## Phase 7: Integration & Polish

### Task 7.1: Implement Navigation Drawer
**Status**: pending
**Priority**: high
**Estimated Time**: 3 hours

Create drawer menu with all modules.

**Acceptance Criteria**:
- Drawer header with app name/logo
- v1 core items (Today, Tasks, Habits)
- v2 module items (Goals, Projects, Calendar, etc.)
- Settings item
- Current screen highlighted
- Drawer opens from all screens

**Files to Modify**:
- `lib/main.dart`

### Task 7.2: Implement Notification Service
**Status**: pending
**Priority**: medium
**Estimated Time**: 4 hours

Create service for deadline and reminder notifications.

**Acceptance Criteria**:
- Goal deadline notifications (7 days before)
- Project deadline notifications (3 days before)
- Time block start notifications
- Important date notifications (7 days before)
- Notification settings (enable/disable per module)
- Notification tap navigates to relevant screen

**Files to Create**:
- `lib/services/notification_service.dart`

### Task 7.3: Implement Data Export
**Status**: pending
**Priority**: medium
**Estimated Time**: 3 hours

Create data export functionality.

**Acceptance Criteria**:
- Export all data to JSON
- Export time reports to CSV
- Save to downloads folder
- Export progress indicator
- Success/error messages
- Export from settings screen

**Files to Create**:
- `lib/services/export_service.dart`

### Task 7.4: Build Settings Screen
**Status**: pending
**Priority**: medium
**Estimated Time**: 4 hours

Create settings screen with module preferences.

**Acceptance Criteria**:
- Notification settings per module
- Default values (goal category, project status, etc.)
- Visual preferences (chart colors, calendar start day)
- Data export button
- Reset to defaults button
- About section with version

**Files to Create**:
- `lib/screens/settings_screen.dart`

### Task 7.5: Create Onboarding Flow
**Status**: pending
**Priority**: medium
**Estimated Time**: 4 hours

Build onboarding for v2 features.

**Acceptance Criteria**:
- Welcome screen explaining v2
- 6 screens explaining each module with examples
- Skip button on all screens
- Replay from settings
- Mark as completed after finish/skip
- Show only on first v2 launch

**Files to Create**:
- `lib/screens/onboarding_screen.dart`

### Task 7.6: Implement Quick Actions FAB
**Status**: pending
**Priority**: low
**Estimated Time**: 3 hours

Add quick actions floating action button to Today screen.

**Acceptance Criteria**:
- FAB on Today screen
- Tap opens menu with 5 actions (Add Task, Add Habit, Start Timer, Add Note, Log Health Metric)
- Each action opens relevant dialog/screen
- Returns to Today screen after action
- Customizable actions in settings

**Files to Modify**:
- `lib/screens/today_screen.dart`

### Task 7.7: Implement Cross-Module Linking
**Status**: pending
**Priority**: high
**Estimated Time**: 4 hours

Ensure all entity linking works throughout app.

**Acceptance Criteria**:
- Tasks link to goals and projects
- Projects link to goals
- Notes link to tasks, goals, projects
- Time entries link to tasks
- All links are bidirectional (visible from both entities)
- Link deletion removes references
- Link indicators in list views

**Files to Modify**:
- Multiple screens and widgets

### Task 7.8: Performance Optimization
**Status**: pending
**Priority**: high
**Estimated Time**: 5 hours

Optimize app performance to meet targets.

**Acceptance Criteria**:
- App launch < 2 seconds with full data
- Screen navigation < 300ms
- Tap interactions < 100ms
- Data operations < 100ms (save) / 500ms (load)
- Chart updates < 200ms
- Smooth scrolling at 60fps
- Memory usage optimized

**Files to Modify**:
- Multiple files (add lazy loading, caching, indexing)

### Task 7.9: Testing and Bug Fixes
**Status**: pending
**Priority**: high
**Estimated Time**: 8 hours

Comprehensive testing and bug fixing.

**Acceptance Criteria**:
- All unit tests passing
- All integration tests passing
- Manual testing of all features
- Bug fixes for discovered issues
- Edge case handling
- Error handling validation

**Files to Modify**:
- Multiple files as needed

### Task 7.10: Documentation and Release
**Status**: pending
**Priority**: medium
**Estimated Time**: 3 hours

Finalize documentation and prepare release.

**Acceptance Criteria**:
- Update README with v2 features
- Create CHANGELOG
- Update BUILD_SUMMARY
- Version bump to 2.0.0
- Build release APK
- Test release build on device

**Files to Modify**:
- `README.md`
- `BUILD_SUMMARY.md`
- `pubspec.yaml`


import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/project.dart';
import '../models/project_template.dart';
import '../models/task_dependency.dart';
import '../models/time_entry.dart';
import '../models/recurring_task.dart';
import '../models/time_block.dart';
import '../models/note.dart';
import '../models/journal_entry.dart';
import '../models/life_area.dart';
import '../models/health_metric.dart';
import '../models/finance_transaction.dart';
import '../models/contact.dart';
import '../models/learning_item.dart';

class HiveStorageService implements StorageService {
  static const String _boxName = 'ordin_box';
  Box? _box;
  
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
    
    // Check if v2 migration is needed
    final prefs = await SharedPreferences.getInstance();
    final isV2Migrated = prefs.getBool('v2_migrated') ?? false;
    
    // Register v2 adapters - Goals System
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(GoalAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(GoalCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(GoalStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(PriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(MilestoneAdapter());
    }
    
    // Register v2 adapters - Projects System
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(ProjectAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(ProjectStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(ProjectTemplateAdapter());
    }
    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(TaskTemplateAdapter());
    }
    if (!Hive.isAdapterRegistered(24)) {
      Hive.registerAdapter(TaskDependencyAdapter());
    }
    
    // Register v2 adapters - Time Tracking System
    if (!Hive.isAdapterRegistered(30)) {
      Hive.registerAdapter(TimeEntryAdapter());
    }
    
    // Register v2 adapters - Calendar System
    if (!Hive.isAdapterRegistered(40)) {
      Hive.registerAdapter(RecurringTaskAdapter());
    }
    if (!Hive.isAdapterRegistered(41)) {
      Hive.registerAdapter(RecurrencePatternAdapter());
    }
    if (!Hive.isAdapterRegistered(42)) {
      Hive.registerAdapter(TimeBlockAdapter());
    }
    
    // Register v2 adapters - Notes & Journal System
    if (!Hive.isAdapterRegistered(50)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(51)) {
      Hive.registerAdapter(JournalEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(52)) {
      Hive.registerAdapter(MoodAdapter());
    }
    
    // Register v2 adapters - Life Areas System
    if (!Hive.isAdapterRegistered(60)) {
      Hive.registerAdapter(LifeAreaAdapter());
    }
    if (!Hive.isAdapterRegistered(61)) {
      Hive.registerAdapter(LifeAreaTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(62)) {
      Hive.registerAdapter(HealthMetricAdapter());
    }
    if (!Hive.isAdapterRegistered(63)) {
      Hive.registerAdapter(HealthMetricTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(64)) {
      Hive.registerAdapter(FinanceTransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(65)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(66)) {
      Hive.registerAdapter(ContactAdapter());
    }
    if (!Hive.isAdapterRegistered(67)) {
      Hive.registerAdapter(ImportantDateAdapter());
    }
    if (!Hive.isAdapterRegistered(68)) {
      Hive.registerAdapter(LearningItemAdapter());
    }
    if (!Hive.isAdapterRegistered(69)) {
      Hive.registerAdapter(LearningTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(70)) {
      Hive.registerAdapter(LearningStatusAdapter());
    }
    
    // Open boxes
    _box = await Hive.openBox(_boxName);
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
    
    // Mark v2 as migrated (no actual migration needed for goals, they're new)
    if (!isV2Migrated) {
      await prefs.setBool('v2_migrated', true);
    }
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _box?.put(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _box?.get(key);
  }

  @override
  Future<void> saveList(String key, List<String> values) async {
    await _box?.put(key, values);
  }

  @override
  Future<List<String>> getList(String key) async {
    final result = _box?.get(key);
    if (result == null) return [];
    return List<String>.from(result);
  }

  @override
  Future<void> delete(String key) async {
    await _box?.delete(key);
  }
}

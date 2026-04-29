import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/task_repository.dart';
import '../data/habit_repository.dart';
import '../data/goal_repository.dart';
import '../data/project_repository.dart';
import '../data/time_tracking_repository.dart';
import '../data/notes_repository.dart';
import '../data/life_areas_repository.dart';
import '../data/hive_storage_service.dart';

class ExportService {
  final HiveStorageService _storage;

  ExportService(this._storage);

  Future<String> exportAllData() async {
    final data = <String, dynamic>{};
    
    // Export tasks
    final taskRepo = TaskRepository(_storage);
    final tasks = await taskRepo.loadTasks();
    data['tasks'] = tasks.map((t) => t.toJson()).toList();
    
    // Export habits
    final habitRepo = HabitRepository(_storage);
    final habits = await habitRepo.loadHabits();
    data['habits'] = habits.map((h) => h.toJson()).toList();
    
    // Export goals
    final goalRepo = GoalRepository(_storage);
    final goals = await goalRepo.loadGoals();
    data['goals'] = goals.map((g) => g.toJson()).toList();
    
    // Export milestones
    final allMilestones = <Map<String, dynamic>>[];
    for (final goal in goals) {
      final milestones = await goalRepo.loadMilestones(goal.id);
      allMilestones.addAll(milestones.map((m) => m.toJson()));
    }
    data['milestones'] = allMilestones;
    
    // Export projects
    final projectRepo = ProjectRepository(_storage);
    final projects = await projectRepo.loadProjects();
    data['projects'] = projects.map((p) => p.toJson()).toList();
    
    // Export time entries
    final timeRepo = TimeTrackingRepository();
    await timeRepo.init(_storage);
    final timeEntries = await timeRepo.loadTimeEntries();
    data['timeEntries'] = timeEntries.map((t) => t.toJson()).toList();
    
    // Export notes
    final notesRepo = NotesRepository(_storage);
    final notes = await notesRepo.loadNotes();
    data['notes'] = notes.map((n) => n.toJson()).toList();
    
    // Export journal entries
    final journalEntries = await notesRepo.loadJournalEntries();
    data['journalEntries'] = journalEntries.map((j) => j.toJson()).toList();
    
    // Export life areas
    final lifeAreasRepo = LifeAreasRepository(_storage);
    final lifeAreas = await lifeAreasRepo.loadLifeAreas();
    data['lifeAreas'] = lifeAreas.map((l) => {
      'id': l.id,
      'name': l.name,
      'type': l.type.name,
      'healthScore': l.healthScore,
      'lastUpdated': l.lastUpdated.toIso8601String(),
    }).toList();
    
    // Add metadata
    data['exportDate'] = DateTime.now().toIso8601String();
    data['version'] = '2.0';
    
    return jsonEncode(data);
  }

  Future<File> saveExportToFile(String jsonData) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${directory.path}/ordin_backup_$timestamp.json');
    await file.writeAsString(jsonData);
    return file;
  }

  Future<void> shareExport() async {
    try {
      final jsonData = await exportAllData();
      final file = await saveExportToFile(jsonData);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Ordin Data Backup',
        text: 'Backup of all Ordin data',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getExportStats() async {
    final taskRepo = TaskRepository(_storage);
    final habitRepo = HabitRepository(_storage);
    final goalRepo = GoalRepository(_storage);
    final projectRepo = ProjectRepository(_storage);
    final notesRepo = NotesRepository(_storage);
    
    final tasks = await taskRepo.loadTasks();
    final habits = await habitRepo.loadHabits();
    final goals = await goalRepo.loadGoals();
    final projects = await projectRepo.loadProjects();
    final notes = await notesRepo.loadNotes();
    final journalEntries = await notesRepo.loadJournalEntries();
    
    return {
      'tasks': tasks.length,
      'habits': habits.length,
      'goals': goals.length,
      'projects': projects.length,
      'notes': notes.length,
      'journalEntries': journalEntries.length,
    };
  }
}

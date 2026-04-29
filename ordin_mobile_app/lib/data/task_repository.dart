import 'dart:convert';
import '../models/task.dart';
import 'storage_service.dart';

class TaskRepository {
  final StorageService _storage;
  static const String _tasksKey = 'tasks';

  TaskRepository(this._storage);

  Future<List<Task>> loadTasks() async {
    try {
      final taskJsonList = await _storage.getList(_tasksKey);
      return taskJsonList
          .map((jsonStr) => Task.fromJson(json.decode(jsonStr)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTask(Task task) async {
    final tasks = await loadTasks();
    final existingIndex = tasks.indexWhere((t) => t.id == task.id);
    
    if (existingIndex != -1) {
      tasks[existingIndex] = task;
    } else {
      tasks.add(task);
    }

    await _saveTasks(tasks);
  }

  Future<void> deleteTask(String id) async {
    final tasks = await loadTasks();
    tasks.removeWhere((task) => task.id == id);
    await _saveTasks(tasks);
  }

  Future<List<Task>> getTasksForDate(DateTime date) async {
    final tasks = await loadTasks();
    return tasks.where((task) => task.isScheduledFor(date)).toList();
  }

  Future<void> _saveTasks(List<Task> tasks) async {
    final taskJsonList = tasks
        .map((task) => json.encode(task.toJson()))
        .toList();
    await _storage.saveList(_tasksKey, taskJsonList);
  }
}

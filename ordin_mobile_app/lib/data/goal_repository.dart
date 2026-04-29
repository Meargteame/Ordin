import 'package:hive/hive.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/task.dart';
import 'task_repository.dart';
import 'storage_service.dart';

class GoalRepository {
  late Box<Goal> _goalsBox;
  late Box<Milestone> _milestonesBox;
  late TaskRepository _taskRepository;

  Future<void> init(StorageService storage) async {
    _goalsBox = await Hive.openBox<Goal>('goals');
    _milestonesBox = await Hive.openBox<Milestone>('milestones');
    _taskRepository = TaskRepository(storage);
  }

  Future<List<Goal>> loadGoals() async {
    return _goalsBox.values.toList();
  }

  Future<void> saveGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  Future<void> deleteGoal(String id) async {
    // Delete all milestones for this goal
    final milestones = await loadMilestones(id);
    for (final milestone in milestones) {
      await deleteMilestone(milestone.id);
    }
    
    // Remove goal from all linked tasks
    final tasks = await _taskRepository.loadTasks();
    for (final task in tasks.where((task) => task.goalIds.contains(id))) {
      task.goalIds.remove(id);
      await _taskRepository.saveTask(task);
    }
    
    await _goalsBox.delete(id);
  }

  Future<List<Goal>> getGoalsByCategory(GoalCategory category) async {
    return _goalsBox.values.where((goal) => goal.category == category).toList();
  }

  Future<List<Goal>> getActiveGoals() async {
    return _goalsBox.values.where((goal) => goal.status == GoalStatus.active).toList();
  }

  Future<void> updateGoalProgress(String goalId) async {
    final goal = _goalsBox.get(goalId);
    if (goal == null) return;

    final progress = await calculateGoalProgress(goal);
    goal.progress = progress;
    await saveGoal(goal);
  }

  Future<double> calculateGoalProgress(Goal goal) async {
    final milestones = await loadMilestones(goal.id);
    final allTasks = await _taskRepository.loadTasks();
    final linkedTasks = allTasks.where((task) => task.goalIds.contains(goal.id)).toList();

    final milestoneProgress = milestones.isEmpty
        ? 0.0
        : milestones.where((m) => m.isCompleted).length / milestones.length;

    final taskProgress = linkedTasks.isEmpty
        ? 0.0
        : linkedTasks.where((t) => t.isDone).length / linkedTasks.length;

    // Weight: 60% milestones, 40% tasks
    return (milestoneProgress * 0.6) + (taskProgress * 0.4);
  }

  Future<List<Milestone>> loadMilestones(String goalId) async {
    return _milestonesBox.values
        .where((milestone) => milestone.goalId == goalId)
        .toList()
      ..sort((a, b) => a.targetDate.compareTo(b.targetDate));
  }

  Future<void> saveMilestone(Milestone milestone) async {
    await _milestonesBox.put(milestone.id, milestone);
    await updateGoalProgress(milestone.goalId);
  }

  Future<void> deleteMilestone(String id) async {
    final milestone = _milestonesBox.get(id);
    if (milestone != null) {
      final goalId = milestone.goalId;
      await _milestonesBox.delete(id);
      await updateGoalProgress(goalId);
    }
  }

  Future<void> completeMilestone(String id) async {
    final milestone = _milestonesBox.get(id);
    if (milestone != null) {
      milestone.isCompleted = true;
      milestone.completedDate = DateTime.now();
      await saveMilestone(milestone);
    }
  }

  Future<void> linkTaskToGoal(String taskId, String goalId) async {
    final tasks = await _taskRepository.loadTasks();
    final task = tasks.where((t) => t.id == taskId).firstOrNull;
    if (task != null && !task.goalIds.contains(goalId)) {
      task.goalIds.add(goalId);
      await _taskRepository.saveTask(task);
      await updateGoalProgress(goalId);
    }
  }

  Future<void> unlinkTaskFromGoal(String taskId, String goalId) async {
    final tasks = await _taskRepository.loadTasks();
    final task = tasks.where((t) => t.id == taskId).firstOrNull;
    if (task != null) {
      task.goalIds.remove(goalId);
      await _taskRepository.saveTask(task);
      await updateGoalProgress(goalId);
    }
  }

  Future<List<Task>> getTasksForGoal(String goalId) async {
    final tasks = await _taskRepository.loadTasks();
    return tasks.where((task) => task.goalIds.contains(goalId)).toList();
  }
}

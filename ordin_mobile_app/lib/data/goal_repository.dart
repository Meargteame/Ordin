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
    final goals = _goalsBox.values.toList();
    
    // Add sample data if no goals exist
    if (goals.isEmpty) {
      await _addSampleGoals();
      return _goalsBox.values.toList();
    }
    
    return goals;
  }

  Future<void> _addSampleGoals() async {
    final sampleGoals = [
      Goal(
        id: 'goal-1',
        title: 'Complete Flutter Certification',
        description: 'Master Flutter development and get certified to advance my career in mobile development.',
        category: GoalCategory.career,
        status: GoalStatus.active,
        priority: Priority.high,
        deadline: DateTime.now().add(const Duration(days: 90)),
        successMetrics: 'Pass certification exam with 85% or higher',
        progress: 0.65,
        linkedTaskIds: [],
        linkedProjectIds: [],
        createdDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Goal(
        id: 'goal-2',
        title: 'Run 5K Marathon',
        description: 'Build endurance and complete a 5K marathon to improve my overall fitness and health.',
        category: GoalCategory.health,
        status: GoalStatus.active,
        priority: Priority.medium,
        deadline: DateTime.now().add(const Duration(days: 60)),
        successMetrics: 'Complete 5K run in under 30 minutes',
        progress: 0.40,
        linkedTaskIds: [],
        linkedProjectIds: [],
        createdDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Goal(
        id: 'goal-3',
        title: 'Save \$10,000 Emergency Fund',
        description: 'Build a solid financial foundation by saving money for unexpected expenses.',
        category: GoalCategory.finance,
        status: GoalStatus.active,
        priority: Priority.high,
        deadline: DateTime.now().add(const Duration(days: 365)),
        successMetrics: 'Reach \$10,000 in savings account',
        progress: 0.30,
        linkedTaskIds: [],
        linkedProjectIds: [],
        createdDate: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Goal(
        id: 'goal-4',
        title: 'Learn Spanish Conversational Level',
        description: 'Achieve conversational fluency in Spanish to enhance personal growth and career opportunities.',
        category: GoalCategory.learning,
        status: GoalStatus.active,
        priority: Priority.medium,
        deadline: DateTime.now().add(const Duration(days: 180)),
        successMetrics: 'Hold 30-minute conversation in Spanish',
        progress: 0.25,
        linkedTaskIds: [],
        linkedProjectIds: [],
        createdDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Goal(
        id: 'goal-5',
        title: 'Strengthen Family Relationships',
        description: 'Spend more quality time with family and improve communication.',
        category: GoalCategory.relationships,
        status: GoalStatus.active,
        priority: Priority.high,
        deadline: null,
        successMetrics: 'Weekly family activities and monthly check-ins',
        progress: 0.55,
        linkedTaskIds: [],
        linkedProjectIds: [],
        createdDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Goal(
        id: 'goal-6',
        title: 'Complete Meditation Challenge',
        description: 'Develop a consistent meditation practice for mental clarity and stress reduction.',
        category: GoalCategory.personalGrowth,
        status: GoalStatus.completed,
        priority: Priority.medium,
        deadline: DateTime.now().subtract(const Duration(days: 5)),
        successMetrics: 'Meditate for 30 days straight, 10 minutes daily',
        progress: 1.0,
        linkedTaskIds: [],
        linkedProjectIds: [],
        createdDate: DateTime.now().subtract(const Duration(days: 35)),
      ),
    ];

    for (final goal in sampleGoals) {
      await saveGoal(goal);
    }
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

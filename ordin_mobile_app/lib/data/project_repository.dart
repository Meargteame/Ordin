import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/project_template.dart';
import '../models/task_dependency.dart';
import '../models/task.dart';
import 'task_repository.dart';
import 'storage_service.dart';

class ProjectRepository {
  late Box<Project> _projectsBox;
  late Box<ProjectTemplate> _templatesBox;
  late Box<TaskDependency> _dependenciesBox;
  late TaskRepository _taskRepository;

  Future<void> init(StorageService storage) async {
    _projectsBox = await Hive.openBox<Project>('projects');
    _templatesBox = await Hive.openBox<ProjectTemplate>('templates');
    _dependenciesBox = await Hive.openBox<TaskDependency>('dependencies');
    _taskRepository = TaskRepository(storage);
  }

  Future<List<Project>> loadProjects() async {
    return _projectsBox.values.toList()
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
  }

  Future<void> saveProject(Project project) async {
    await _projectsBox.put(project.id, project);
  }

  Future<void> deleteProject(String id) async {
    final tasks = await _taskRepository.loadTasks();
    for (final task in tasks.where((t) => t.projectId == id)) {
      task.projectId = null;
      await _taskRepository.saveTask(task);
    }
    
    final dependencies = await loadDependencies(id);
    for (final dep in dependencies) {
      await _dependenciesBox.delete(dep.id);
    }
    
    await _projectsBox.delete(id);
  }

  Future<List<Project>> getProjectsByStatus(ProjectStatus status) async {
    return _projectsBox.values
        .where((project) => project.status == status)
        .toList()
      ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
  }

  Future<void> updateProjectProgress(String projectId) async {
    final project = _projectsBox.get(projectId);
    if (project == null) return;

    final tasks = await getTasksForProject(projectId);
    if (tasks.isEmpty) {
      project.progress = 0.0;
    } else {
      final completedTasks = tasks.where((t) => t.isDone).length;
      project.progress = completedTasks / tasks.length;
    }

    if (project.progress >= 1.0 && project.status == ProjectStatus.active) {
      project.status = ProjectStatus.completed;
      project.completedDate = DateTime.now();
    }

    await saveProject(project);
  }

  Future<List<ProjectTemplate>> loadTemplates() async {
    return _templatesBox.values.toList();
  }

  Future<void> saveTemplate(ProjectTemplate template) async {
    await _templatesBox.put(template.id, template);
  }

  Future<Project> createProjectFromTemplate(String templateId) async {
    final template = _templatesBox.get(templateId);
    if (template == null) {
      throw Exception('Template not found');
    }

    final project = Project(
      id: const Uuid().v4(),
      title: template.name,
      description: template.description,
      status: ProjectStatus.planning,
      category: 'General',
      progress: 0.0,
      createdDate: DateTime.now(),
    );

    await saveProject(project);

    final taskIdMap = <String, String>{};
    for (final taskTemplate in template.taskTemplates) {
      final task = Task(
        id: const Uuid().v4(),
        title: taskTemplate.title,
        isDone: false,
        date: DateTime.now(),
        projectId: project.id,
        goalIds: [],
        description: taskTemplate.description,
        estimatedMinutes: taskTemplate.estimatedMinutes,
      );
      await _taskRepository.saveTask(task);
      taskIdMap[taskTemplate.title] = task.id;
    }

    for (final taskTemplate in template.taskTemplates) {
      for (final dependsOnTitle in taskTemplate.dependsOnTitles) {
        final taskId = taskIdMap[taskTemplate.title];
        final dependsOnTaskId = taskIdMap[dependsOnTitle];
        if (taskId != null && dependsOnTaskId != null) {
          final dependency = TaskDependency(
            id: const Uuid().v4(),
            taskId: taskId,
            dependsOnTaskId: dependsOnTaskId,
          );
          await saveDependency(dependency);
        }
      }
    }

    return project;
  }

  Future<List<TaskDependency>> loadDependencies(String projectId) async {
    final tasks = await getTasksForProject(projectId);
    final taskIds = tasks.map((t) => t.id).toSet();
    return _dependenciesBox.values
        .where((dep) => taskIds.contains(dep.taskId))
        .toList();
  }

  Future<void> saveDependency(TaskDependency dependency) async {
    if (await hasCircularDependency(dependency.taskId, dependency.dependsOnTaskId)) {
      throw Exception('Circular dependency detected');
    }
    await _dependenciesBox.put(dependency.id, dependency);
  }

  Future<bool> hasCircularDependency(String taskId, String dependsOnTaskId) async {
    final visited = <String>{};
    final stack = [dependsOnTaskId];

    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (current == taskId) return true;
      if (visited.contains(current)) continue;

      visited.add(current);
      final deps = _dependenciesBox.values
          .where((d) => d.taskId == current)
          .map((d) => d.dependsOnTaskId);
      stack.addAll(deps);
    }

    return false;
  }

  Future<bool> isTaskBlocked(String taskId) async {
    final dependencies = _dependenciesBox.values
        .where((dep) => dep.taskId == taskId)
        .toList();

    if (dependencies.isEmpty) return false;

    final tasks = await _taskRepository.loadTasks();
    final taskMap = {for (var t in tasks) t.id: t};

    for (final dep in dependencies) {
      final dependsOnTask = taskMap[dep.dependsOnTaskId];
      if (dependsOnTask != null && !dependsOnTask.isDone) {
        return true;
      }
    }

    return false;
  }

  Future<List<Task>> getTasksForProject(String projectId) async {
    final tasks = await _taskRepository.loadTasks();
    return tasks.where((task) => task.projectId == projectId).toList();
  }

  Future<void> createDefaultTemplates() async {
    if (_templatesBox.isNotEmpty) return;

    final templates = [
      ProjectTemplate(
        id: const Uuid().v4(),
        name: 'Launch Product',
        description: 'Template for launching a new product',
        taskTemplates: [
          TaskTemplate(
            title: 'Market Research',
            description: 'Research target market and competitors',
            estimatedMinutes: 480,
            dependsOnTitles: [],
          ),
          TaskTemplate(
            title: 'Define Requirements',
            description: 'Document product requirements',
            estimatedMinutes: 240,
            dependsOnTitles: ['Market Research'],
          ),
          TaskTemplate(
            title: 'Create Prototype',
            description: 'Build initial prototype',
            estimatedMinutes: 960,
            dependsOnTitles: ['Define Requirements'],
          ),
          TaskTemplate(
            title: 'User Testing',
            description: 'Test with target users',
            estimatedMinutes: 480,
            dependsOnTitles: ['Create Prototype'],
          ),
          TaskTemplate(
            title: 'Marketing Plan',
            description: 'Create marketing strategy',
            estimatedMinutes: 360,
            dependsOnTitles: ['Market Research'],
          ),
          TaskTemplate(
            title: 'Launch',
            description: 'Official product launch',
            estimatedMinutes: 120,
            dependsOnTitles: ['User Testing', 'Marketing Plan'],
          ),
        ],
      ),
      ProjectTemplate(
        id: const Uuid().v4(),
        name: 'Learn New Skill',
        description: 'Template for learning a new skill',
        taskTemplates: [
          TaskTemplate(
            title: 'Research Resources',
            description: 'Find courses, books, tutorials',
            estimatedMinutes: 120,
            dependsOnTitles: [],
          ),
          TaskTemplate(
            title: 'Create Learning Plan',
            description: 'Plan learning schedule',
            estimatedMinutes: 60,
            dependsOnTitles: ['Research Resources'],
          ),
          TaskTemplate(
            title: 'Complete Basics',
            description: 'Learn fundamental concepts',
            estimatedMinutes: 1200,
            dependsOnTitles: ['Create Learning Plan'],
          ),
          TaskTemplate(
            title: 'Practice Project',
            description: 'Build practice project',
            estimatedMinutes: 960,
            dependsOnTitles: ['Complete Basics'],
          ),
          TaskTemplate(
            title: 'Advanced Topics',
            description: 'Study advanced concepts',
            estimatedMinutes: 1200,
            dependsOnTitles: ['Practice Project'],
          ),
        ],
      ),
      ProjectTemplate(
        id: const Uuid().v4(),
        name: 'Home Renovation',
        description: 'Template for home renovation project',
        taskTemplates: [
          TaskTemplate(
            title: 'Plan Design',
            description: 'Design renovation layout',
            estimatedMinutes: 240,
            dependsOnTitles: [],
          ),
          TaskTemplate(
            title: 'Get Quotes',
            description: 'Get contractor quotes',
            estimatedMinutes: 180,
            dependsOnTitles: ['Plan Design'],
          ),
          TaskTemplate(
            title: 'Purchase Materials',
            description: 'Buy renovation materials',
            estimatedMinutes: 240,
            dependsOnTitles: ['Get Quotes'],
          ),
          TaskTemplate(
            title: 'Demolition',
            description: 'Remove old fixtures',
            estimatedMinutes: 480,
            dependsOnTitles: ['Purchase Materials'],
          ),
          TaskTemplate(
            title: 'Construction',
            description: 'Build new structures',
            estimatedMinutes: 1440,
            dependsOnTitles: ['Demolition'],
          ),
          TaskTemplate(
            title: 'Finishing Touches',
            description: 'Paint, decorate, clean',
            estimatedMinutes: 480,
            dependsOnTitles: ['Construction'],
          ),
        ],
      ),
    ];

    for (final template in templates) {
      await saveTemplate(template);
    }
  }
}

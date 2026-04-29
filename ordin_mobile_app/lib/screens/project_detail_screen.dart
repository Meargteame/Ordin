import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/task_dependency.dart';
import '../data/project_repository.dart';
import '../data/task_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/task_item.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final ProjectRepository _projectRepository = ProjectRepository();
  final TaskRepository _taskRepository = TaskRepository(HiveStorageService());
  final HiveStorageService _storage = HiveStorageService();
  
  Project? _project;
  List<Task> _tasks = [];
  List<TaskDependency> _dependencies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  Future<void> _initRepository() async {
    await _storage.init();
    await _projectRepository.init(_storage);
    await _loadData();
  }

  Future<void> _loadData() async {
    final project = await _projectRepository.loadProjects();
    final projectData = project.where((p) => p.id == widget.projectId).firstOrNull;
    
    if (projectData != null) {
      final tasks = await _projectRepository.getTasksForProject(widget.projectId);
      final dependencies = await _projectRepository.loadDependencies(widget.projectId);
      
      setState(() {
        _project = projectData;
        _tasks = tasks;
        _dependencies = dependencies;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _project == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_project!.title),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Project'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Project'),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog();
              } else if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_project!.description.isNotEmpty) ...[
              Text(
                _project!.description,
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
            ],
            
            _buildInfoCard(),
            const SizedBox(height: 20),
            
            _buildProgressCard(),
            const SizedBox(height: 20),
            
            _buildTasksSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('Status', _getStatusName(_project!.status)),
          const Divider(height: 24),
          _buildInfoRow('Category', _project!.category),
          if (_project!.deadline != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              'Deadline',
              '${_project!.deadline!.day}/${_project!.deadline!.month}/${_project!.deadline!.year}',
            ),
          ],
          const Divider(height: 24),
          _buildInfoRow(
            'Created',
            '${_project!.createdDate.day}/${_project!.createdDate.month}/${_project!.createdDate.year}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyMedium),
        Text(value, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Progress', style: AppTheme.heading3),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _project!.progress,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_project!.progress * 100).toInt()}% complete • ${_tasks.where((t) => t.isDone).length}/${_tasks.length} tasks',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tasks (${_tasks.length})',
              style: AppTheme.heading2,
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (_tasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.task_rounded,
                      size: 30,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('No tasks yet', style: AppTheme.heading3),
                  const SizedBox(height: 4),
                  Text(
                    'Add tasks to this project',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else
          ..._tasks.map((task) {
            final isBlocked = _dependencies.any((dep) =>
                dep.taskId == task.id &&
                _tasks.any((t) => t.id == dep.dependsOnTaskId && !t.isDone));
            
            return Opacity(
              opacity: isBlocked ? 0.5 : 1.0,
              child: TaskItem(
                task: task,
                onToggle: () async {
                  if (!isBlocked) {
                    task.isDone = !task.isDone;
                    await _taskRepository.saveTask(task);
                    await _projectRepository.updateProjectProgress(widget.projectId);
                    await _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Complete dependencies first'),
                      ),
                    );
                  }
                },
                onDelete: () async {
                  await _taskRepository.deleteTask(task.id);
                  await _projectRepository.updateProjectProgress(widget.projectId);
                  await _loadData();
                },
              ),
            );
          }),
      ],
    );
  }

  String _getStatusName(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.archived:
        return 'Archived';
    }
  }

  Future<void> _showAddTaskDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter task title',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional details',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final task = Task(
        id: const Uuid().v4(),
        title: titleController.text,
        isDone: false,
        date: DateTime.now(),
        projectId: widget.projectId,
        goalIds: [],
        description: descriptionController.text.isEmpty ? null : descriptionController.text,
      );

      await _taskRepository.saveTask(task);
      await _projectRepository.updateProjectProgress(widget.projectId);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added')),
        );
      }
    }
  }

  Future<void> _showEditDialog() async {
    final titleController = TextEditingController(text: _project!.title);
    final descriptionController = TextEditingController(text: _project!.description);
    final categoryController = TextEditingController(text: _project!.category);
    ProjectStatus selectedStatus = _project!.status;
    DateTime? selectedDeadline = _project!.deadline;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ProjectStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ProjectStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_getStatusName(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Deadline'),
                  subtitle: Text(
                    selectedDeadline != null
                        ? '${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}'
                        : 'No deadline set',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDeadline ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDeadline = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _project!.title = titleController.text;
      _project!.description = descriptionController.text;
      _project!.category = categoryController.text;
      _project!.status = selectedStatus;
      _project!.deadline = selectedDeadline;

      await _projectRepository.saveProject(_project!);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project updated')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure? This will remove the project but keep the tasks.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _projectRepository.deleteProject(widget.projectId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project deleted')),
        );
      }
    }
  }
}

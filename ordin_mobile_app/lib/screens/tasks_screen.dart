import 'package:flutter/material.dart';
import '../models/task.dart';
import '../data/task_repository.dart';
import '../data/hive_storage_service.dart';
import '../widgets/task_form_screen.dart';
import '../theme/theme_helper.dart';
import '../theme/ordin_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late TaskRepository _taskRepo;
  List<Task> _allTasks = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepo();
  }

  Future<void> _initRepo() async {
    final storage = HiveStorageService();
    await storage.init();
    _taskRepo = TaskRepository(storage);
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _taskRepo.loadTasks();
    setState(() {
      _allTasks = tasks;
      _isLoading = false;
    });
  }

  List<Task> get _filteredTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (_selectedFilter) {
      case 'Today':
        return _allTasks.where((t) {
          if (t.date == null) return false;
          final taskDate = DateTime(t.date!.year, t.date!.month, t.date!.day);
          return taskDate.isAtSameMomentAs(today);
        }).toList();
      case 'Upcoming':
        return _allTasks.where((t) {
          if (t.date == null) return false;
          final taskDate = DateTime(t.date!.year, t.date!.month, t.date!.day);
          return taskDate.isAfter(today);
        }).toList();
      case 'Completed':
        return _allTasks.where((t) => t.isDone).toList();
      default:
        return _allTasks;
    }
  }

  List<Task> get _highPriorityTasks => _filteredTasks
      .where((t) => t.priority == TaskPriority.high && !t.isDone)
      .toList();

  List<Task> get _mediumPriorityTasks => _filteredTasks
      .where((t) => t.priority == TaskPriority.medium && !t.isDone)
      .toList();

  List<Task> get _lowPriorityTasks => _filteredTasks
      .where((t) => t.priority == TaskPriority.low && !t.isDone)
      .toList();

  Future<void> _toggleTask(Task task) async {
    task.isDone = !task.isDone;
    await _taskRepo.saveTask(task);
    setState(() {});
  }

  Future<void> _deleteTask(Task task) async {
    await _taskRepo.deleteTask(task.id);
    await _loadTasks();
  }

  void _openTaskForm([Task? task]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(
          task: task,
          onSave: (newTask) async {
            await _taskRepo.saveTask(newTask);
            await _loadTasks();
          },
          onDelete: task != null
              ? () async {
                  await _deleteTask(task);
                  if (context.mounted) Navigator.pop(context);
                }
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchBar(),
                            const SizedBox(height: 20),
                            _buildFilterChips(),
                            const SizedBox(height: 24),
                            if (_highPriorityTasks.isNotEmpty) ...[
                              _buildPrioritySection(
                                'High Priority',
                                _highPriorityTasks,
                                OrdinTheme.error,
                              ),
                              const SizedBox(height: 24),
                            ],
                            if (_mediumPriorityTasks.isNotEmpty) ...[
                              _buildPrioritySection(
                                'Medium Priority',
                                _mediumPriorityTasks,
                                OrdinTheme.warning,
                              ),
                              const SizedBox(height: 24),
                            ],
                            if (_lowPriorityTasks.isNotEmpty) ...[
                              _buildPrioritySection(
                                'Low Priority',
                                _lowPriorityTasks,
                                OrdinTheme.success,
                              ),
                              const SizedBox(height: 24),
                            ],
                            if (_filteredTasks.isEmpty) _buildEmptyState(),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ThemeHelper.cardDecoration(context),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search tasks, projects, or tags...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: ThemeHelper.textTertiary(context),
          ),
          prefixIcon: Icon(Icons.search, color: ThemeHelper.textTertiary(context)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Today', 'Upcoming', 'Completed'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
              backgroundColor: ThemeHelper.cardColor(context),
              selectedColor: OrdinTheme.primary,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : ThemeHelper.textSecondary(context),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? OrdinTheme.primary : ThemeHelper.borderColor(context),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPrioritySection(String title, List<Task> tasks, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ThemeHelper.textPrimary(context),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${tasks.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tasks.map((task) => _buildTaskCard(task, color)),
      ],
    );
  }

  Widget _buildTaskCard(Task task, Color priorityColor) {
    return GestureDetector(
      onTap: () => _openTaskForm(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeHelper.cardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: task.isDone ? OrdinTheme.success : ThemeHelper.borderColor(context),
            width: 1,
          ),
          boxShadow: [ThemeHelper.cardShadow(context)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleTask(task),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isDone ? OrdinTheme.primary : Colors.transparent,
                      border: Border.all(
                        color: task.isDone ? OrdinTheme.primary : ThemeHelper.borderColor(context),
                        width: 2,
                      ),
                    ),
                    child: task.isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: task.isDone ? ThemeHelper.textTertiary(context) : ThemeHelper.textPrimary(context),
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: OrdinTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: OrdinTheme.warning),
                        const SizedBox(width: 4),
                        Text(
                          _formatDueDate(task.dueDate!),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: OrdinTheme.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: ThemeHelper.textSecondary(context),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (task.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: task.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ThemeHelper.isDark(context) 
                            ? ThemeHelper.borderColor(context)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ThemeHelper.textSecondary(context),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate.isAtSameMomentAs(today)) {
      return 'Due Today';
    } else if (taskDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else if (taskDate.isBefore(today)) {
      return 'Overdue';
    } else {
      return 'Due ${date.month}/${date.day}';
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: ThemeHelper.cardDecoration(context),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: ThemeHelper.textTertiary(context).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first task to get started',
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.textTertiary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import 'modern_form_screen.dart';
import 'modern_form_field.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;
  final VoidCallback? onDelete;

  const TaskFormScreen({
    super.key,
    this.task,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate;
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _tags = List.from(widget.task?.tags ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _isValid => _titleController.text.trim().isNotEmpty;

  void _save() {
    if (!_isValid) return;

    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      isDone: widget.task?.isDone ?? false,
      date: widget.task?.date ?? DateTime.now(),
      priority: _priority,
      dueDate: _dueDate,
      tags: _tags,
    );

    widget.onSave(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ModernFormScreen(
      title: widget.task == null ? 'New Task' : 'Edit Task',
      icon: Icons.task_alt_rounded,
      accentColor: AppTheme.primaryBlue,
      saveLabel: widget.task == null ? 'Create Task' : 'Save Changes',
      isValid: _isValid,
      onSave: _save,
      onDelete: widget.onDelete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          ModernFormField(
            label: 'Task Title',
            hint: 'What needs to be done?',
            icon: Icons.edit_rounded,
            controller: _titleController,
            autofocus: widget.task == null,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 24),

          // Description
          ModernFormField(
            label: 'Description',
            hint: 'Add details, notes, or context...',
            icon: Icons.notes_rounded,
            controller: _descController,
            maxLines: 4,
          ),
          const SizedBox(height: 32),

          // Priority Section
          FormSection(
            title: 'Priority',
            icon: Icons.flag_rounded,
            child: ModernChoiceSelector<TaskPriority>(
              label: 'How important is this?',
              options: TaskPriority.values,
              selected: _priority,
              onSelected: (value) => setState(() => _priority = value),
              getLabel: _getPriorityLabel,
              getIcon: _getPriorityIcon,
              getColor: _getPriorityColor,
            ),
          ),
          const SizedBox(height: 32),

          // Due Date Section
          FormSection(
            title: 'Schedule',
            icon: Icons.calendar_today_rounded,
            child: ModernDateTimePicker(
              label: 'Due Date',
              icon: Icons.event_rounded,
              value: _dueDate,
              onChanged: (value) => setState(() => _dueDate = value),
            ),
          ),
          const SizedBox(height: 32),

          // Tags Section
          FormSection(
            title: 'Tags',
            icon: Icons.label_rounded,
            child: ModernTagSelector(
              label: 'Organize with tags',
              tags: _tags,
              onChanged: (value) => setState(() => _tags = value),
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppTheme.successGreen;
      case TaskPriority.medium:
        return AppTheme.primaryBlue;
      case TaskPriority.high:
        return AppTheme.warningOrange;
    }
  }
}

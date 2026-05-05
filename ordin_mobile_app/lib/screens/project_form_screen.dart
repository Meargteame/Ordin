import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../theme/theme_helper.dart';
import '../theme/ordin_theme.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;
  final Function(Project) onSave;

  const ProjectFormScreen({super.key, this.project, required this.onSave});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  ProjectStatus _selectedStatus = ProjectStatus.planning;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project?.title ?? '');
    _descriptionController = TextEditingController(text: widget.project?.description ?? '');
    _categoryController = TextEditingController(text: widget.project?.category ?? '');
    
    if (widget.project != null) {
      _selectedStatus = widget.project!.status;
      _deadline = widget.project!.deadline;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final project = Project(
        id: widget.project?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        category: _categoryController.text.isEmpty ? 'General' : _categoryController.text,
        status: _selectedStatus,
        deadline: _deadline,
        linkedGoalId: widget.project?.linkedGoalId,
        progress: widget.project?.progress ?? 0.0,
        createdDate: widget.project?.createdDate ?? DateTime.now(),
        completedDate: _selectedStatus == ProjectStatus.completed ? DateTime.now() : null,
      );
      widget.onSave(project);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.backgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: ThemeHelper.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.project == null ? 'New Project' : 'Edit Project',
          style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Save', style: TextStyle(color: OrdinTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Project Title',
                hintStyle: TextStyle(color: ThemeHelper.textTertiary(context), fontSize: 24, fontWeight: FontWeight.bold),
                border: InputBorder.none,
              ),
              validator: (v) => v == null || v.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(color: ThemeHelper.textSecondary(context), fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Description (optional)',
                hintStyle: TextStyle(color: ThemeHelper.textTertiary(context), fontSize: 16),
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _categoryController,
              style: TextStyle(color: ThemeHelper.textSecondary(context), fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Category e.g. Work, Home (optional)',
                hintStyle: TextStyle(color: ThemeHelper.textTertiary(context), fontSize: 16),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 30),
            _buildDropdown<ProjectStatus>(
              label: 'Status',
              value: _selectedStatus,
              items: ProjectStatus.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _selectedStatus = v!),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Deadline', style: TextStyle(color: ThemeHelper.textPrimary(context))),
              subtitle: Text(
                _deadline == null ? 'Not set' : '${_deadline!.month}/${_deadline!.day}/${_deadline!.year}',
                style: TextStyle(color: ThemeHelper.textSecondary(context)),
              ),
              trailing: Icon(Icons.calendar_today, color: OrdinTheme.primary),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _deadline ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _deadline = date);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({required String label, required T value, required List<DropdownMenuItem<T>> items, required void Function(T?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: ThemeHelper.textSecondary(context), fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ThemeHelper.cardDecoration(context),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: ThemeHelper.cardColor(context),
              style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 16),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

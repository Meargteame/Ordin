import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../theme/theme_helper.dart';
import '../theme/ordin_theme.dart';

class GoalFormScreen extends StatefulWidget {
  final Goal? goal;
  final Function(Goal) onSave;

  const GoalFormScreen({super.key, this.goal, required this.onSave});

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  GoalCategory _selectedCategory = GoalCategory.personalGrowth;
  Priority _selectedPriority = Priority.medium;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _descriptionController = TextEditingController(text: widget.goal?.description ?? '');
    if (widget.goal != null) {
      _selectedCategory = widget.goal!.category;
      _selectedPriority = widget.goal!.priority;
      _deadline = widget.goal!.deadline;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final goal = Goal(
        id: widget.goal?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        status: widget.goal?.status ?? GoalStatus.active,
        priority: _selectedPriority,
        deadline: _deadline,
        successMetrics: widget.goal?.successMetrics ?? '',
        progress: widget.goal?.progress ?? 0.0,
        linkedTaskIds: widget.goal?.linkedTaskIds ?? [],
        linkedProjectIds: widget.goal?.linkedProjectIds ?? [],
        createdDate: widget.goal?.createdDate ?? DateTime.now(),
      );
      widget.onSave(goal);
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
          widget.goal == null ? 'New Goal' : 'Edit Goal',
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
                hintText: 'Goal Title',
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
            const SizedBox(height: 30),
            _buildDropdown<GoalCategory>(
              label: 'Category',
              value: _selectedCategory,
              items: GoalCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 20),
            _buildDropdown<Priority>(
              label: 'Priority',
              value: _selectedPriority,
              items: Priority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _selectedPriority = v!),
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

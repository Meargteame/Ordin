import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modern form field with consistent styling
class ModernFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final TextEditingController? controller;
  final int maxLines;
  final bool autofocus;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const ModernFormField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.controller,
    this.maxLines = 1,
    this.autofocus = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          autofocus: autofocus,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.surfaceWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}

/// Section header for forms
class FormSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;

  const FormSection({
    super.key,
    required this.title,
    this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppTheme.primaryBlue),
              ),
              const SizedBox(width: 12),
            ],
            Text(title, style: AppTheme.headingMedium),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

/// Choice selector with icons and colors
class ModernChoiceSelector<T> extends StatelessWidget {
  final String label;
  final IconData? icon;
  final List<T> options;
  final T selected;
  final Function(T) onSelected;
  final String Function(T) getLabel;
  final IconData Function(T)? getIcon;
  final Color Function(T)? getColor;
  final bool wrap;

  const ModernChoiceSelector({
    super.key,
    required this.label,
    this.icon,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.getLabel,
    this.getIcon,
    this.getColor,
    this.wrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 12),
        wrap ? _buildWrap() : _buildRow(),
      ],
    );
  }

  Widget _buildWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) => _buildChip(option)).toList(),
    );
  }

  Widget _buildRow() {
    return Row(
      children: options.map((option) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: option == options.last ? 0 : 8),
            child: _buildChip(option),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChip(T option) {
    final isSelected = selected == option;
    final color = getColor?.call(option) ?? AppTheme.primaryBlue;
    final optionIcon = getIcon?.call(option);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(option),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppTheme.borderGray,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (optionIcon != null) ...[
                Icon(optionIcon, size: 18, color: isSelected ? color : AppTheme.textSecondary),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  getLabel(option),
                  style: AppTheme.labelLarge.copyWith(
                    color: isSelected ? color : AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Date/Time picker field
class ModernDateTimePicker extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final Function(DateTime?) onChanged;
  final bool isTime;
  final bool allowClear;

  const ModernDateTimePicker({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    required this.onChanged,
    this.isTime = false,
    this.allowClear = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickDateTime(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderGray),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppTheme.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTheme.labelMedium),
                    const SizedBox(height: 2),
                    Text(
                      value == null ? 'Not set' : _formatValue(),
                      style: AppTheme.bodyLarge.copyWith(
                        color: value == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (value != null && allowClear)
                IconButton(
                  icon: Icon(Icons.clear, size: 20, color: AppTheme.textSecondary),
                  onPressed: () => onChanged(null),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatValue() {
    if (value == null) return 'Not set';
    if (isTime) {
      final hour = value!.hour.toString().padLeft(2, '0');
      final minute = value!.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return '${value!.day}/${value!.month}/${value!.year}';
  }

  Future<void> _pickDateTime(BuildContext context) async {
    if (isTime) {
      final time = await showTimePicker(
        context: context,
        initialTime: value != null 
          ? TimeOfDay(hour: value!.hour, minute: value!.minute)
          : TimeOfDay.now(),
      );
      if (time != null) {
        final now = DateTime.now();
        onChanged(DateTime(now.year, now.month, now.day, time.hour, time.minute));
      }
    } else {
      final date = await showDatePicker(
        context: context,
        initialDate: value ?? DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 365)),
        lastDate: DateTime.now().add(Duration(days: 365 * 2)),
      );
      if (date != null) {
        onChanged(date);
      }
    }
  }
}

/// Tag selector with add/remove
class ModernTagSelector extends StatelessWidget {
  final String label;
  final List<String> tags;
  final Function(List<String>) onChanged;
  final Color color;

  const ModernTagSelector({
    super.key,
    required this.label,
    required this.tags,
    required this.onChanged,
    this.color = AppTheme.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.label, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...tags.map((tag) => Chip(
              label: Text(tag, style: AppTheme.labelMedium),
              deleteIcon: Icon(Icons.close, size: 16),
              onDeleted: () {
                final newTags = List<String>.from(tags)..remove(tag);
                onChanged(newTags);
              },
              backgroundColor: color.withOpacity(0.1),
              side: BorderSide(color: color.withOpacity(0.3)),
            )),
            ActionChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: color),
                  const SizedBox(width: 4),
                  Text('Add', style: AppTheme.labelMedium.copyWith(color: color)),
                ],
              ),
              onPressed: () => _showAddTagDialog(context),
              backgroundColor: color.withOpacity(0.05),
              side: BorderSide(color: color.withOpacity(0.3)),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showAddTagDialog(BuildContext context) async {
    final controller = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Tag', style: AppTheme.headingLarge),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Tag name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Add'),
          ),
        ],
      ),
    );
    if (tag != null && tag.isNotEmpty && !tags.contains(tag)) {
      final newTags = List<String>.from(tags)..add(tag);
      onChanged(newTags);
    }
  }
}

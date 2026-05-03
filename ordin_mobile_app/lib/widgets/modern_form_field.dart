// Temporary compatibility widgets
import 'package:flutter/material.dart';

class ModernFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final bool autofocus;
  final TextEditingController? controller;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  
  const ModernFormField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.autofocus = false,
    this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class ModernChoiceSelector<T> extends StatelessWidget {
  final String label;
  final T? value;
  final T? selected;
  final List<T> options;
  final String Function(T) getLabel;
  final IconData Function(T)? getIcon;
  final Color Function(T)? getColor;
  final ValueChanged<T>? onChanged;
  final ValueChanged<T>? onSelected;
  final bool wrap;
  
  const ModernChoiceSelector({
    super.key,
    required this.label,
    this.value,
    this.selected,
    required this.options,
    required this.getLabel,
    this.getIcon,
    this.getColor,
    this.onChanged,
    this.onSelected,
    this.wrap = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final currentValue = selected ?? value ?? (options.isNotEmpty ? options.first : null);
    final callback = onSelected ?? onChanged;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == currentValue;
            final icon = getIcon?.call(option);
            final color = getColor?.call(option);
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: isSelected ? Colors.white : color),
                    const SizedBox(width: 4),
                  ],
                  Text(getLabel(option)),
                ],
              ),
              selected: isSelected,
              selectedColor: color,
              onSelected: callback != null ? (_) => callback(option) : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ModernDateTimePicker extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isTime;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  
  const ModernDateTimePicker({
    super.key,
    required this.label,
    this.icon,
    this.isTime = false,
    this.value,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(label),
      subtitle: Text(value?.toString() ?? 'Not set'),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        if (isTime) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time != null) {
            final now = DateTime.now();
            onChanged(DateTime(now.year, now.month, now.day, time.hour, time.minute));
          }
        } else {
          final date = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) onChanged(date);
        }
      },
    );
  }
}

class ModernTagSelector extends StatelessWidget {
  final String label;
  final Color? color;
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  
  const ModernTagSelector({
    super.key,
    required this.label,
    this.color,
    required this.tags,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: tags.map((tag) {
            return Chip(
              label: Text(tag),
              onDeleted: () {
                final newTags = List<String>.from(tags)..remove(tag);
                onChanged(newTags);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

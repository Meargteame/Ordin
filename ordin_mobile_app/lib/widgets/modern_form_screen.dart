// Temporary compatibility widget
import 'package:flutter/material.dart';

class ModernFormScreen extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? accentColor;
  final List<Widget>? children;
  final Widget? child;
  final String? saveLabel;
  final bool? isValid;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;
  
  const ModernFormScreen({
    super.key,
    required this.title,
    this.icon,
    this.accentColor,
    this.children,
    this.child,
    this.saveLabel,
    this.isValid,
    this.onSave,
    this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    final content = child ?? Column(children: children ?? []);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [content],
      ),
      floatingActionButton: onSave != null
          ? FloatingActionButton.extended(
              onPressed: (isValid ?? true) ? onSave : null,
              backgroundColor: (isValid ?? true) ? accentColor : Colors.grey,
              icon: const Icon(Icons.check),
              label: Text(saveLabel ?? 'Save'),
            )
          : null,
    );
  }
}

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
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 24),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modern full-screen form with gradient header and action buttons
class ModernFormScreen extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? accentColor;
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback? onDelete;
  final String saveLabel;
  final bool isValid;

  const ModernFormScreen({
    super.key,
    required this.title,
    this.icon,
    this.accentColor,
    required this.child,
    required this.onSave,
    this.onDelete,
    this.saveLabel = 'Save',
    this.isValid = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.primaryBlue;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Gradient Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        if (icon != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            style: AppTheme.headingLarge.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        if (onDelete != null)
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.white),
                            onPressed: () => _confirmDelete(context),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppTheme.borderGray),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Cancel', style: AppTheme.labelLarge),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: isValid ? onSave : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            saveLabel,
                            style: AppTheme.labelLarge.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete?', style: AppTheme.headingLarge),
        content: Text('This action cannot be undone.', style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && onDelete != null) {
      onDelete!();
      Navigator.pop(context);
    }
  }
}

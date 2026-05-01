import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0EA5E9), // Sky Blue
            Color(0xFF0284C7), // Deep Sky Blue
            Color(0xFF06B6D4), // Cyan
          ],
        ),
      ),
      child: AppBar(
        title: Text(title, style: AppTheme.displayMedium.copyWith(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: leading,
        actions: actions,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: bottom,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

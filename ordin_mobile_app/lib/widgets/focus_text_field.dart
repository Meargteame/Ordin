import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';

class FocusTextField extends StatefulWidget {
  final String initialText;
  final Function(String) onTextChanged;

  const FocusTextField({
    super.key,
    required this.initialText,
    required this.onTextChanged,
  });

  @override
  State<FocusTextField> createState() => _FocusTextFieldState();
}

class _FocusTextFieldState extends State<FocusTextField> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onTextChanged(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.08),
            AppTheme.secondaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: '✨ What matters today?',
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              Icons.wb_sunny_rounded,
              color: AppTheme.primaryColor.withOpacity(0.6),
              size: 24,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
        style: AppTheme.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 3,
        minLines: 1,
        textCapitalization: TextCapitalization.sentences,
        onChanged: _onTextChanged,
      ),
    );
  }
}

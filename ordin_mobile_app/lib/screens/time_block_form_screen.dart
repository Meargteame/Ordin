import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/time_block.dart';
import '../theme/theme_helper.dart';
import '../theme/ordin_theme.dart';

class TimeBlockFormScreen extends StatefulWidget {
  final Function(TimeBlock) onSave;

  const TimeBlockFormScreen({super.key, required this.onSave});

  @override
  State<TimeBlockFormScreen> createState() => _TimeBlockFormScreenState();
}

class _TimeBlockFormScreenState extends State<TimeBlockFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_endTime.isBefore(_startTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
        return;
      }
      
      final newBlock = TimeBlock(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        startTime: _startTime,
        endTime: _endTime,
      );
      widget.onSave(newBlock);
      Navigator.pop(context);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart 
        ? TimeOfDay.fromDateTime(_startTime) 
        : TimeOfDay.fromDateTime(_endTime);
    
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        final now = DateTime.now();
        final newDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (isStart) {
          _startTime = newDateTime;
          if (_endTime.isBefore(_startTime)) {
            _endTime = _startTime.add(const Duration(hours: 1));
          }
        } else {
          _endTime = newDateTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.backgroundColor(context),
        elevation: 0,
        title: Text(
          'New Event',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ThemeHelper.textPrimary(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: ThemeHelper.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveForm,
            child: Text(
              'Save',
              style: TextStyle(
                color: OrdinTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  labelStyle: TextStyle(color: ThemeHelper.textSecondary(context)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ThemeHelper.borderColor(context)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: OrdinTheme.primary, width: 2),
                  ),
                ),
                style: TextStyle(
                  fontSize: 18,
                  color: ThemeHelper.textPrimary(context),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: ThemeHelper.borderColor(context)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: ThemeHelper.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              TimeOfDay.fromDateTime(_startTime).format(context),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ThemeHelper.textPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: ThemeHelper.borderColor(context)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: ThemeHelper.textSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              TimeOfDay.fromDateTime(_endTime).format(context),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ThemeHelper.textPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: ThemeHelper.textSecondary(context)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ThemeHelper.borderColor(context)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: OrdinTheme.primary, width: 2),
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: ThemeHelper.textPrimary(context),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

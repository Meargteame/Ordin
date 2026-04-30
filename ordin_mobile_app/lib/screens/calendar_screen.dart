import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/time_block.dart';
import '../models/task.dart';
import '../data/calendar_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarRepository _calendarRepo;
  DateTime _selectedDate = DateTime.now();
  List<TimeBlock> _timeBlocks = [];
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepo();
  }

  Future<void> _initRepo() async {
    final storage = HiveStorageService();
    await storage.init();
    _calendarRepo = CalendarRepository();
    await _calendarRepo.init(storage);
    await _loadData();
  }

  Future<void> _loadData() async {
    final blocks = await _calendarRepo.getTimeBlocksForDate(_selectedDate);
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final tasks = await _calendarRepo.getTasksForDateRange(startOfDay, startOfDay);
    
    setState(() {
      _timeBlocks = blocks;
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _addTimeBlock() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('New Time Block', style: AppTheme.headingLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  style: AppTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: AppTheme.labelMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  style: AppTheme.bodyLarge,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    labelStyle: AppTheme.labelMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() => startTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time_rounded),
                        label: Text(
                          startTime != null ? startTime!.format(context) : 'Start Time',
                          style: AppTheme.bodyMedium,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          side: const BorderSide(color: AppTheme.borderGray),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() => endTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time_rounded),
                        label: Text(
                          endTime != null ? endTime!.format(context) : 'End Time',
                          style: AppTheme.bodyMedium,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          side: const BorderSide(color: AppTheme.borderGray),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Add', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result == true && titleController.text.isNotEmpty && startTime != null && endTime != null) {
      final start = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        startTime!.hour,
        startTime!.minute,
      );
      final end = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        endTime!.hour,
        endTime!.minute,
      );

      if (end.isBefore(start)) {
        _showError('End time must be after start time');
        return;
      }

      final hasOverlap = await _calendarRepo.hasOverlappingTimeBlock(start, end, null);
      if (hasOverlap) {
        _showError('Time block overlaps with existing block');
        return;
      }

      final block = TimeBlock(
        id: const Uuid().v4(),
        startTime: start,
        endTime: end,
        title: titleController.text,
        description: descController.text.isEmpty ? null : descController.text,
      );

      await _calendarRepo.saveTimeBlock(block);
      await _loadData();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.dangerRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _deleteTimeBlock(TimeBlock block) async {
    await _calendarRepo.deleteTimeBlock(block.id);
    await _loadData();
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadData();
  }

  int get _totalItems => _timeBlocks.length + _tasks.length;
  int get _completedTasks => _tasks.where((t) => t.isDone).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Calendar', style: AppTheme.displayMedium),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.borderGray),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildDateSelector(),
                const SizedBox(height: 8),
                Expanded(
                  child: _totalItems == 0
                      ? _buildEmptyState()
                      : ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            if (_tasks.isNotEmpty) ...[
                              Text('Tasks', style: AppTheme.headingLarge),
                              const SizedBox(height: 16),
                              ..._tasks.map((task) => _buildTaskCard(task)),
                              const SizedBox(height: 24),
                            ],
                            if (_timeBlocks.isNotEmpty) ...[
                              Text('Schedule', style: AppTheme.headingLarge),
                              const SizedBox(height: 16),
                              ..._timeBlocks.map((block) => _buildTimeBlockCard(block)),
                            ],
                          ],
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTimeBlock,
        backgroundColor: AppTheme.successGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Block', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildDateSelector() {
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Container(
      padding: const EdgeInsets.all(20),
      color: AppTheme.surfaceWhite,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _changeDate(-1),
                icon: const Icon(Icons.chevron_left_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEEE').format(_selectedDate),
                      style: AppTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM d, yyyy').format(_selectedDate),
                      style: AppTheme.displayMedium,
                    ),
                    if (isToday) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('Today', style: AppTheme.labelMedium.copyWith(color: AppTheme.primaryBlue)),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _changeDate(1),
                icon: const Icon(Icons.chevron_right_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total', '$_totalItems', Icons.event_rounded, AppTheme.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Tasks', '${_tasks.length}', Icons.check_circle_rounded, AppTheme.successGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Blocks', '${_timeBlocks.length}', Icons.schedule_rounded, AppTheme.warningOrange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.headingMedium.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: task.isDone ? AppTheme.successGreen.withOpacity(0.3) : AppTheme.borderGray),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isDone ? AppTheme.successGreen : Colors.transparent,
              border: Border.all(
                color: task.isDone ? AppTheme.successGreen : AppTheme.borderGray,
                width: 2,
              ),
            ),
            child: task.isDone ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.title,
              style: AppTheme.bodyLarge.copyWith(
                decoration: task.isDone ? TextDecoration.lineThrough : null,
                color: task.isDone ? AppTheme.textSecondary : AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlockCard(TimeBlock block) {
    final duration = block.durationMinutes;
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    final durationText = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.schedule_rounded, color: AppTheme.successGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(block.title, style: AppTheme.headingMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed),
                  onPressed: () => _deleteTimeBlock(block),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${DateFormat('h:mm a').format(block.startTime)} - ${DateFormat('h:mm a').format(block.endTime)}',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(durationText, style: AppTheme.labelMedium.copyWith(color: AppTheme.warningOrange)),
                ),
              ],
            ),
            if (block.description != null && block.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(block.description!, style: AppTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_today_rounded, size: 64, color: AppTheme.successGreen.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text('No events scheduled', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text('Add time blocks to plan your day', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}

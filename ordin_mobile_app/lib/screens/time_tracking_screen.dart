import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/time_entry.dart';
import '../data/time_tracking_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/time_entry_item.dart';

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({super.key});

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  final TimeTrackingRepository _repository = TimeTrackingRepository();
  final HiveStorageService _storage = HiveStorageService();
  
  TimeEntry? _activeTimer;
  List<TimeEntry> _todayEntries = [];
  Map<String, int> _todayTimeByCategory = {};
  Timer? _updateTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepository();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _initRepository() async {
    await _storage.init();
    await _repository.init(_storage);
    await _loadData();
    _startUpdateTimer();
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_activeTimer != null && mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadData() async {
    final activeTimer = await _repository.getActiveTimer();
    final todayEntries = await _repository.getEntriesForDate(DateTime.now());
    final timeByCategory = await _repository.getTodayTimeByCategory();

    setState(() {
      _activeTimer = activeTimer;
      _todayEntries = todayEntries;
      _todayTimeByCategory = timeByCategory;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Time Tracking',
                      style: AppTheme.heading1,
                    ),
                    const SizedBox(height: 24),
                    
                    _buildTimerCard(),
                    const SizedBox(height: 20),
                    
                    _buildTodaySummaryCard(),
                    const SizedBox(height: 20),
                    
                    _buildRecentEntriesSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_activeTimer != null) ...[
            const Text(
              'Timer Running',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDuration(_activeTimer!.calculateDuration()),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _activeTimer!.category,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _stopTimer,
                icon: const Icon(Icons.stop_rounded),
                label: const Text('Stop Timer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            const Icon(
              Icons.timer_outlined,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Active Timer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start tracking your time',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showStartTimerDialog,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Timer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodaySummaryCard() {
    final totalMinutes = _todayTimeByCategory.values.fold(0, (sum, mins) => sum + mins);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Time',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDuration(totalMinutes),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Text(
                    'Total Time',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          
          if (_todayTimeByCategory.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            ..._todayTimeByCategory.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: AppTheme.bodyLarge),
                  Text(
                    _formatDuration(entry.value),
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentEntriesSection() {
    final completedEntries = _todayEntries.where((e) => !e.isRunning).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Entries (${completedEntries.length})',
              style: AppTheme.heading2,
            ),
            TextButton.icon(
              onPressed: _showAddManualEntryDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Manual'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (completedEntries.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      size: 30,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('No entries yet', style: AppTheme.heading3),
                  const SizedBox(height: 4),
                  Text(
                    'Start a timer or add manual entry',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else
          ...completedEntries.map((entry) => TimeEntryItem(
            entry: entry,
            onDelete: () async {
              await _repository.deleteTimeEntry(entry.id);
              await _loadData();
            },
          )),
      ],
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  Future<void> _showStartTimerDialog() async {
    final categoryController = TextEditingController(text: 'Work');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g., Work, Learning, Exercise',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (result == true && categoryController.text.isNotEmpty) {
      await _repository.startTimer(null, categoryController.text);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timer started')),
        );
      }
    }
  }

  Future<void> _stopTimer() async {
    await _repository.stopTimer();
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timer stopped')),
      );
    }
  }

  Future<void> _showAddManualEntryDialog() async {
    final categoryController = TextEditingController(text: 'Work');
    final notesController = TextEditingController();
    int durationMinutes = 30;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Manual Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'e.g., Work, Learning',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'What did you work on?',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Duration: '),
                    Expanded(
                      child: Slider(
                        value: durationMinutes.toDouble(),
                        min: 5,
                        max: 480,
                        divisions: 95,
                        label: _formatDuration(durationMinutes),
                        onChanged: (value) {
                          setDialogState(() => durationMinutes = value.toInt());
                        },
                      ),
                    ),
                    Text(_formatDuration(durationMinutes)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && categoryController.text.isNotEmpty) {
      final now = DateTime.now();
      final entry = TimeEntry(
        id: const Uuid().v4(),
        startTime: now.subtract(Duration(minutes: durationMinutes)),
        endTime: now,
        durationMinutes: durationMinutes,
        category: categoryController.text,
        notes: notesController.text,
      );

      await _repository.saveTimeEntry(entry);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry added')),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/time_entry.dart';
import '../data/time_tracking_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({super.key});

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  late TimeTrackingRepository _timeRepo;
  List<TimeEntry> _entries = [];
  TimeEntry? _activeTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepo();
  }

  Future<void> _initRepo() async {
    final storage = HiveStorageService();
    await storage.init();
    _timeRepo = TimeTrackingRepository();
    await _timeRepo.init(storage);
    await _loadData();
  }

  Future<void> _loadData() async {
    final entries = await _timeRepo.loadTimeEntries();
    final active = await _timeRepo.getActiveTimer();
    setState(() {
      _entries = entries;
      _activeTimer = active;
      _isLoading = false;
    });
  }

  Future<void> _startTimer() async {
    final categoryController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start Timer', style: AppTheme.headingLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              autofocus: true,
              style: AppTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: AppTheme.labelMedium,
                hintText: 'e.g., Work, Study, Exercise',
                hintStyle: AppTheme.bodyMedium,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              style: AppTheme.bodyLarge,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                labelStyle: AppTheme.labelMedium,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                ),
              ),
            ),
          ],
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
            child: Text('Start', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && categoryController.text.isNotEmpty) {
      final entry = await _timeRepo.startTimer(null, categoryController.text);
      entry.notes = notesController.text;
      await _timeRepo.saveTimeEntry(entry);
      await _loadData();
    }
  }

  Future<void> _stopTimer() async {
    await _timeRepo.stopTimer();
    await _loadData();
  }

  Future<void> _deleteEntry(TimeEntry entry) async {
    await _timeRepo.deleteTimeEntry(entry.id);
    await _loadData();
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  int get _todayMinutes {
    final today = DateTime.now();
    return _entries
        .where((e) =>
            e.startTime.year == today.year &&
            e.startTime.month == today.month &&
            e.startTime.day == today.day &&
            e.endTime != null)
        .fold<int>(0, (sum, e) => sum + e.durationMinutes);
  }

  int get _weekMinutes {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _entries
        .where((e) => e.startTime.isAfter(weekAgo) && e.endTime != null)
        .fold<int>(0, (sum, e) => sum + e.durationMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: GradientAppBar(
        title: 'Time Tracking',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  color: AppTheme.surfaceWhite,
                  child: Column(
                    children: [
                      if (_activeTimer != null) _buildActiveTimer(),
                      if (_activeTimer != null) const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard('Today', _formatDuration(_todayMinutes), Icons.today_rounded, AppTheme.primaryBlue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard('This Week', _formatDuration(_weekMinutes), Icons.calendar_view_week_rounded, AppTheme.successGreen),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard('Entries', '${_entries.length}', Icons.list_rounded, AppTheme.warningOrange),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _entries.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _entries.length,
                          itemBuilder: (context, index) => _buildEntryCard(_entries[index]),
                        ),
                ),
              ],
            ),
      floatingActionButton: _activeTimer == null
          ? FloatingActionButton.extended(
              heroTag: 'time_start_fab',
              onPressed: _startTimer,
              backgroundColor: AppTheme.successGreen,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: Text('Start Timer', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
            )
          : FloatingActionButton.extended(
              heroTag: 'time_stop_fab',
              onPressed: _stopTimer,
              backgroundColor: AppTheme.dangerRed,
              icon: const Icon(Icons.stop_rounded, color: Colors.white),
              label: Text('Stop Timer', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
            ),
    );
  }

  Widget _buildActiveTimer() {
    if (_activeTimer == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.successGreen, AppTheme.successGreen.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Timer Running', style: AppTheme.labelMedium.copyWith(color: Colors.white.withOpacity(0.9))),
                    Text(_activeTimer!.category, style: AppTheme.headingMedium.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              Text(
                _formatDuration(_activeTimer!.calculateDuration()),
                style: AppTheme.displayMedium.copyWith(color: Colors.white),
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

  Widget _buildEntryCard(TimeEntry entry) {
    final isRunning = entry.isRunning;
    final duration = isRunning ? entry.calculateDuration() : entry.durationMinutes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isRunning ? AppTheme.successGreen.withOpacity(0.3) : AppTheme.borderGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(entry.category, style: AppTheme.labelMedium.copyWith(color: AppTheme.primaryBlue)),
                ),
                const Spacer(),
                if (!isRunning)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed),
                    onPressed: () => _deleteEntry(entry),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  DateFormat('MMM d, h:mm a').format(entry.startTime),
                  style: AppTheme.bodyMedium,
                ),
                if (!isRunning) ...[
                  Text(' - ', style: AppTheme.bodyMedium),
                  Text(
                    DateFormat('h:mm a').format(entry.endTime!),
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 16, color: AppTheme.warningOrange),
                const SizedBox(width: 6),
                Text(
                  _formatDuration(duration),
                  style: AppTheme.headingMedium.copyWith(color: AppTheme.warningOrange),
                ),
              ],
            ),
            if (entry.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(entry.notes, style: AppTheme.bodyMedium),
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
              color: AppTheme.warningOrange.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.timer_rounded, size: 64, color: AppTheme.warningOrange.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text('No time entries yet', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text('Start tracking your time to see insights', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}

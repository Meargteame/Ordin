import 'dart:async';
import 'package:flutter/material.dart';
import '../data/time_tracking_repository.dart';
import '../data/hive_storage_service.dart';
import '../models/time_entry.dart';
import '../theme/theme_helper.dart';
import '../theme/ordin_theme.dart';

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
  Timer? _timer;
  int _activeSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initRepo();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeTimer != null) {
        setState(() {
          _activeSeconds = DateTime.now().difference(_activeTimer!.startTime).inSeconds;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initRepo() async {
    final storage = HiveStorageService();
    await storage.init();
    _timeRepo = TimeTrackingRepository();
    await _timeRepo.init(storage);
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final entries = await _timeRepo.loadTimeEntries();
    final active = await _timeRepo.getActiveTimer();
    
    setState(() {
      _entries = entries.where((e) => e.id != active?.id).toList();
      _activeTimer = active;
      if (active != null) {
        _activeSeconds = DateTime.now().difference(active.startTime).inSeconds;
      }
      _isLoading = false;
    });
  }

  Future<void> _toggleTimer() async {
    if (_activeTimer == null) {
      await _timeRepo.startTimer(null, 'General');
    } else {
      await _timeRepo.stopTimer();
    }
    await _loadData();
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    buf(int val) => val.toString().padLeft(2, '0');
    return '${hours > 0 ? "${buf(hours)}:" : ""}${buf(minutes)}:${buf(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.backgroundColor(context),
        elevation: 0,
        title: Text(
          'Time Tracking',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ThemeHelper.textPrimary(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeHelper.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_activeTimer != null) _buildActiveTimerCard(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleTimer,
        backgroundColor: _activeTimer == null ? OrdinTheme.primary : OrdinTheme.error,
        child: Icon(
          _activeTimer == null ? Icons.play_arrow : Icons.stop,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActiveTimerCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: OrdinTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OrdinTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Current Session',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: OrdinTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatDuration(_activeSeconds),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: ThemeHelper.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _activeTimer!.category,
            style: TextStyle(
              fontSize: 16,
              color: ThemeHelper.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(TimeEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: ThemeHelper.cardDecoration(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.startTime.month}/${entry.startTime.day} - ${entry.notes.isEmpty ? "No notes" : entry.notes}',
                  style: TextStyle(
                    fontSize: 13,
                    color: ThemeHelper.textSecondary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${entry.durationMinutes} min',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: OrdinTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_outlined, size: 80, color: ThemeHelper.borderColor(context)),
            const SizedBox(height: 24),
            Text(
              'No tracked time yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ThemeHelper.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap play to start tracking your time',
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.textTertiary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

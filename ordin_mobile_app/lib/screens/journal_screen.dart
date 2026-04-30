import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../data/notes_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late NotesRepository _notesRepo;
  DateTime _selectedDate = DateTime.now();
  JournalEntry? _todayEntry;
  List<JournalEntry> _recentEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepo();
  }

  Future<void> _initRepo() async {
    final storage = HiveStorageService();
    await storage.init();
    _notesRepo = NotesRepository(storage);
    await _loadData();
  }

  Future<void> _loadData() async {
    final entry = await _notesRepo.getJournalEntryForDate(_selectedDate);
    final entries = await _notesRepo.loadJournalEntries();

    setState(() {
      _todayEntry = entry;
      _recentEntries = entries.take(10).toList();
      _isLoading = false;
    });
  }

  Future<void> _editEntry() async {
    final contentController = TextEditingController(text: _todayEntry?.content ?? '');
    final gratitudeControllers = List.generate(
      3,
      (i) => TextEditingController(
        text: _todayEntry != null && i < _todayEntry!.gratitudeItems.length
            ? _todayEntry!.gratitudeItems[i]
            : '',
      ),
    );
    Mood? selectedMood = _todayEntry?.mood;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Journal Entry', style: AppTheme.headingLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How are you feeling?', style: AppTheme.labelLarge),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMoodButton('😄', Mood.great, selectedMood, (mood) {
                      setDialogState(() => selectedMood = mood);
                    }),
                    _buildMoodButton('🙂', Mood.good, selectedMood, (mood) {
                      setDialogState(() => selectedMood = mood);
                    }),
                    _buildMoodButton('😐', Mood.neutral, selectedMood, (mood) {
                      setDialogState(() => selectedMood = mood);
                    }),
                    _buildMoodButton('😟', Mood.bad, selectedMood, (mood) {
                      setDialogState(() => selectedMood = mood);
                    }),
                    _buildMoodButton('😢', Mood.terrible, selectedMood, (mood) {
                      setDialogState(() => selectedMood = mood);
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                Text('What happened today?', style: AppTheme.labelLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  style: AppTheme.bodyLarge,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Write about your day...',
                    hintStyle: AppTheme.bodyMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('What are you grateful for?', style: AppTheme.labelLarge),
                const SizedBox(height: 12),
                ...List.generate(3, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: gratitudeControllers[i],
                      style: AppTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: '${i + 1}.',
                        labelStyle: AppTheme.labelMedium,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                        ),
                      ),
                    ),
                  );
                }),
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
                backgroundColor: AppTheme.infoBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Save', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final gratitudeItems = gratitudeControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final entry = _todayEntry != null
          ? (_todayEntry!
            ..content = contentController.text
            ..mood = selectedMood
            ..gratitudeItems = gratitudeItems)
          : JournalEntry(
              id: const Uuid().v4(),
              date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
              content: contentController.text,
              mood: selectedMood,
              gratitudeItems: gratitudeItems,
              photoUrls: [],
            );

      await _notesRepo.saveJournalEntry(entry);
      await _loadData();
    }
  }

  Widget _buildMoodButton(String emoji, Mood mood, Mood? selected, Function(Mood) onSelect) {
    final isSelected = selected == mood;
    return GestureDetector(
      onTap: () => onSelect(mood),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderGray,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadData();
  }

  String _getMoodEmoji(Mood? mood) {
    if (mood == null) return '😐';
    switch (mood) {
      case Mood.great:
        return '😄';
      case Mood.good:
        return '🙂';
      case Mood.neutral:
        return '😐';
      case Mood.bad:
        return '😟';
      case Mood.terrible:
        return '😢';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Journal', style: AppTheme.displayMedium),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.borderGray),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildDateSelector(isToday),
                const SizedBox(height: 24),
                _todayEntry != null ? _buildEntryCard() : _buildEmptyEntry(),
                const SizedBox(height: 32),
                if (_recentEntries.isNotEmpty) ...[
                  Text('Recent Entries', style: AppTheme.headingLarge),
                  const SizedBox(height: 16),
                  ..._recentEntries.where((e) => !_isSameDay(e.date, _selectedDate)).map((entry) {
                    return _buildRecentEntryCard(entry);
                  }),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _editEntry,
        backgroundColor: AppTheme.infoBlue,
        icon: Icon(_todayEntry == null ? Icons.add_rounded : Icons.edit_rounded, color: Colors.white),
        label: Text(
          _todayEntry == null ? 'Write Entry' : 'Edit Entry',
          style: AppTheme.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDateSelector(bool isToday) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
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
                Text(DateFormat('EEEE').format(_selectedDate), style: AppTheme.labelLarge),
                const SizedBox(height: 4),
                Text(DateFormat('MMMM d, yyyy').format(_selectedDate), style: AppTheme.headingLarge),
                if (isToday) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.infoBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Today', style: AppTheme.labelMedium.copyWith(color: AppTheme.infoBlue)),
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
    );
  }

  Widget _buildEntryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_getMoodEmoji(_todayEntry!.mood), style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Text('Your Day', style: AppTheme.headingLarge),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(_todayEntry!.content, style: AppTheme.bodyLarge),
          if (_todayEntry!.gratitudeItems.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Grateful For', style: AppTheme.headingMedium),
            const SizedBox(height: 12),
            ..._todayEntry!.gratitudeItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 20, color: AppTheme.successGreen)),
                    Expanded(child: Text(item, style: AppTheme.bodyMedium)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyEntry() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.infoBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.book_rounded, size: 48, color: AppTheme.infoBlue.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),
          Text('No entry for this day', style: AppTheme.headingMedium),
          const SizedBox(height: 8),
          Text('Tap the button below to write', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildRecentEntryCard(JournalEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_getMoodEmoji(entry.mood), style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(DateFormat('EEEE, MMM d').format(entry.date), style: AppTheme.headingMedium),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            entry.content,
            style: AppTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

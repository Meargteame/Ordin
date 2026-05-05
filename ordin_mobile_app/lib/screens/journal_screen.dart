import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../data/notes_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/theme_helper.dart';
import '../theme/ordin_theme.dart';

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
          backgroundColor: ThemeHelper.cardColor(context),
          title: Text('Journal Entry', style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 20, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How are you feeling?', style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 16)),
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
                Text('What happened today?', style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 16)),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  style: TextStyle(color: ThemeHelper.textPrimary(context)),
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Write about your day...',
                    hintStyle: TextStyle(color: ThemeHelper.textTertiary(context)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: OrdinTheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('What are you grateful for?', style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 16)),
                const SizedBox(height: 12),
                ...List.generate(3, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: gratitudeControllers[i],
                      style: TextStyle(color: ThemeHelper.textPrimary(context)),
                      decoration: InputDecoration(
                        labelText: '${i + 1}.',
                        labelStyle: TextStyle(color: ThemeHelper.textSecondary(context)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: OrdinTheme.primary, width: 2),
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
              child: Text('Cancel', style: TextStyle(color: ThemeHelper.textSecondary(context))),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: OrdinTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
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
          color: isSelected ? OrdinTheme.primary.withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? OrdinTheme.primary : ThemeHelper.borderColor(context),
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
      _isLoading = true;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.backgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeHelper.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Journal',
          style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(),
                  const SizedBox(height: 24),
                  if (_todayEntry != null) _buildEntryView() else _buildEmptyState(),
                  const SizedBox(height: 32),
                  if (_recentEntries.isNotEmpty) ...[
                    Text('Recent Entries', style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ..._recentEntries.map((e) => _buildRecentEntryCard(e)),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _editEntry,
        backgroundColor: OrdinTheme.primary,
        icon: Icon(_todayEntry != null ? Icons.edit : Icons.edit_document, color: Colors.white),
        label: Text(_todayEntry != null ? 'Edit' : 'Write', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDateHeader() {
    final isToday = DateTime.now().difference(_selectedDate).inDays == 0 && DateTime.now().day == _selectedDate.day;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ThemeHelper.cardDecoration(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: ThemeHelper.textPrimary(context)),
            onPressed: () => _changeDate(-1),
          ),
          Column(
            children: [
              Text(DateFormat('EEEE').format(_selectedDate), style: TextStyle(color: ThemeHelper.textSecondary(context), fontSize: 14)),
              const SizedBox(height: 4),
              Text(DateFormat('MMMM d, yyyy').format(_selectedDate), style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
              if (isToday) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: OrdinTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Today', style: TextStyle(color: OrdinTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: isToday ? ThemeHelper.borderColor(context) : ThemeHelper.textPrimary(context)),
            onPressed: isToday ? null : () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ThemeHelper.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_todayEntry!.mood != null) ...[
            Row(
              children: [
                const Text('Feeling: ', style: TextStyle(color: Colors.grey)),
                Text(_getMoodEmoji(_todayEntry!.mood!), style: const TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Text('Your Day', style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_todayEntry!.content, style: TextStyle(color: ThemeHelper.textSecondary(context), fontSize: 16)),
          const SizedBox(height: 24),
          if (_todayEntry!.gratitudeItems.isNotEmpty) ...[
            Text('Grateful For', style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._todayEntry!.gratitudeItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(fontSize: 20, color: OrdinTheme.success)),
                      Expanded(child: Text(item, style: TextStyle(color: ThemeHelper.textSecondary(context), fontSize: 14))),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: ThemeHelper.cardDecoration(context),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: OrdinTheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.book_rounded, size: 48, color: OrdinTheme.primary.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text('No entry for this day', style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Tap the button below to write', style: TextStyle(color: ThemeHelper.textSecondary(context), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRecentEntryCard(JournalEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: ThemeHelper.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(DateFormat('EEEE, MMM d').format(entry.date), style: TextStyle(color: ThemeHelper.textPrimary(context), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              if (entry.mood != null) Text(_getMoodEmoji(entry.mood!), style: const TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.content,
            style: TextStyle(color: ThemeHelper.textSecondary(context), fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(Mood mood) {
    switch (mood) {
      case Mood.great: return '😄';
      case Mood.good: return '🙂';
      case Mood.neutral: return '😐';
      case Mood.bad: return '😟';
      case Mood.terrible: return '😢';
    }
  }
}

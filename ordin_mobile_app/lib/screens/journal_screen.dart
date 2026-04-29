import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/journal_entry.dart';
import '../data/notes_repository.dart';
import '../data/hive_storage_service.dart';
import '../widgets/journal_entry_card.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late NotesRepository _repository;
  List<JournalEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _repository = NotesRepository(HiveStorageService());
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await _repository.loadJournalEntries();
    setState(() => _entries = entries);
  }

  void _showEntryDialog([JournalEntry? entry]) {
    final date = entry?.date ?? DateTime.now();
    final contentController = TextEditingController(text: entry?.content ?? '');
    Mood? selectedMood = entry?.mood;
    final gratitudeItems = List<String>.from(entry?.gratitudeItems ?? ['', '', '']);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Journal - ${_formatDate(date)}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How are you feeling?', style: AppTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: Mood.values.map((mood) {
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedMood = mood),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedMood == mood
                              ? AppTheme.primaryColor.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getMoodEmoji(mood),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'What happened today?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                const Text('Three things I\'m grateful for:', style: AppTheme.bodyMedium),
                const SizedBox(height: 8),
                ...List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '${index + 1}.',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) => gratitudeItems[index] = value,
                      controller: TextEditingController(text: gratitudeItems[index]),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newEntry = JournalEntry(
                  id: entry?.id ?? _repository.generateId(),
                  date: date,
                  content: contentController.text,
                  mood: selectedMood,
                  gratitudeItems: gratitudeItems.where((i) => i.isNotEmpty).toList(),
                  photoUrls: entry?.photoUrls ?? [],
                );

                await _repository.saveJournalEntry(newEntry);
                Navigator.pop(context);
                _loadEntries();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _getMoodEmoji(Mood mood) {
    switch (mood) {
      case Mood.great:
        return '😄';
      case Mood.good:
        return '🙂';
      case Mood.neutral:
        return '😐';
      case Mood.bad:
        return '😞';
      case Mood.terrible:
        return '😢';
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: _entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.book_rounded,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('No journal entries yet', style: AppTheme.heading3),
                  const SizedBox(height: 8),
                  const Text('Start journaling today', style: AppTheme.caption),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                return JournalEntryCard(
                  entry: _entries[index],
                  onTap: () => _showEntryDialog(_entries[index]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEntryDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
    );
  }
}

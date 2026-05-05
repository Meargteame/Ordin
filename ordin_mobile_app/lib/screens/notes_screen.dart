import 'package:flutter/material.dart';
import '../models/note.dart';
import '../data/notes_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/theme_helper.dart';
import '../theme/ordin_theme.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late NotesRepository _notesRepo;
  List<Note> _notes = [];
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
    await _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _notesRepo.loadNotes();
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.backgroundColor(context),
        elevation: 0,
        title: Text(
          'Notes',
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
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: ThemeHelper.textSecondary(context)),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) => _buildNoteCard(_notes[index]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: OrdinTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ThemeHelper.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ThemeHelper.textPrimary(context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              note.content,
              style: TextStyle(
                fontSize: 13,
                color: ThemeHelper.textSecondary(context),
                height: 1.4,
              ),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(note.createdDate),
            style: TextStyle(
              fontSize: 11,
              color: ThemeHelper.textTertiary(context),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 80, color: ThemeHelper.borderColor(context)),
            const SizedBox(height: 24),
            Text(
              'No notes yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ThemeHelper.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture your ideas and thoughts',
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

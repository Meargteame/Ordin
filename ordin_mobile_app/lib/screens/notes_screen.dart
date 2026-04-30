import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../data/notes_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late NotesRepository _notesRepo;
  List<Note> _notes = [];
  List<String> _allTags = [];
  String? _selectedTag;
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
    final notes = _selectedTag == null
        ? await _notesRepo.loadNotes()
        : await _notesRepo.getNotesByTag(_selectedTag!);
    final tags = await _notesRepo.getAllTags();

    setState(() {
      _notes = notes;
      _allTags = tags;
      _isLoading = false;
    });
  }

  Future<void> _addOrEditNote([Note? existingNote]) async {
    final titleController = TextEditingController(text: existingNote?.title ?? '');
    final contentController = TextEditingController(text: existingNote?.content ?? '');
    final tagsController = TextEditingController(text: existingNote?.tags.join(', ') ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingNote == null ? 'New Note' : 'Edit Note', style: AppTheme.headingLarge),
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
                controller: contentController,
                style: AppTheme.bodyLarge,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: AppTheme.labelMedium,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagsController,
                style: AppTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Tags (comma separated)',
                  labelStyle: AppTheme.labelMedium,
                  hintText: 'work, ideas, personal',
                  hintStyle: AppTheme.bodyMedium,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  ),
                ),
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
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Save', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final tags = tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final now = DateTime.now();
      final note = existingNote != null
          ? (existingNote
            ..title = titleController.text
            ..content = contentController.text
            ..tags = tags
            ..modifiedDate = now)
          : Note(
              id: const Uuid().v4(),
              title: titleController.text,
              content: contentController.text,
              tags: tags,
              createdDate: now,
              modifiedDate: now,
              photoUrls: [],
            );

      await _notesRepo.saveNote(note);
      await _loadData();
    }
  }

  Future<void> _deleteNote(Note note) async {
    await _notesRepo.deleteNote(note.id);
    await _loadData();
  }

  void _filterByTag(String? tag) {
    setState(() {
      _selectedTag = tag;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: GradientAppBar(
        title: 'Notes',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_allTags.isNotEmpty) _buildTagFilter(),
                Expanded(
                  child: _notes.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _notes.length,
                          itemBuilder: (context, index) => _buildNoteCard(_notes[index]),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'notes_fab',
        onPressed: () => _addOrEditNote(),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Note', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildTagFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppTheme.surfaceWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter by Tag', style: AppTheme.labelLarge),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTagChip('All', _selectedTag == null, () => _filterByTag(null)),
                const SizedBox(width: 8),
                ..._allTags.map((tag) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildTagChip(tag, _selectedTag == tag, () => _filterByTag(tag)),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderGray,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _addOrEditNote(note),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(note.title, style: AppTheme.headingMedium),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed),
                      onPressed: () => _deleteNote(note),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: AppTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(note.modifiedDate),
                      style: AppTheme.bodySmall,
                    ),
                    if (note.tags.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          children: note.tags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: AppTheme.labelMedium.copyWith(color: AppTheme.primaryBlue),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
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
              color: AppTheme.primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.note_rounded, size: 64, color: AppTheme.primaryBlue.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text(_selectedTag == null ? 'No notes yet' : 'No notes with this tag', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text(
            _selectedTag == null ? 'Create your first note' : 'Try a different tag filter',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

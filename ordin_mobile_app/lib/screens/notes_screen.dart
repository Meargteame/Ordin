import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/note.dart';
import '../data/notes_repository.dart';
import '../data/hive_storage_service.dart';
import '../widgets/note_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late NotesRepository _repository;
  List<Note> _notes = [];
  List<String> _allTags = [];
  String? _selectedTag;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = NotesRepository(HiveStorageService());
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _repository.loadNotes();
    final tags = await _repository.getAllTags();
    setState(() {
      _notes = notes;
      _allTags = tags;
    });
  }

  Future<void> _searchNotes(String query) async {
    if (query.isEmpty) {
      _loadNotes();
      return;
    }
    final results = await _repository.searchNotes(query);
    setState(() => _notes = results);
  }

  Future<void> _filterByTag(String? tag) async {
    setState(() => _selectedTag = tag);
    if (tag == null) {
      _loadNotes();
      return;
    }
    final filtered = await _repository.getNotesByTag(tag);
    setState(() => _notes = filtered);
  }

  void _showNoteDialog([Note? note]) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    final tagsController = TextEditingController(text: note?.tags.join(', ') ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'New Note' : 'Edit Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'work, ideas, personal',
                ),
              ),
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
              final now = DateTime.now();
              final tags = tagsController.text
                  .split(',')
                  .map((t) => t.trim())
                  .where((t) => t.isNotEmpty)
                  .toList();

              final newNote = Note(
                id: note?.id ?? _repository.generateId(),
                title: titleController.text,
                content: contentController.text,
                tags: tags,
                createdDate: note?.createdDate ?? now,
                modifiedDate: now,
                photoUrls: note?.photoUrls ?? [],
              );

              await _repository.saveNote(newNote);
              Navigator.pop(context);
              _loadNotes();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchNotes,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_allTags.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildTagChip('All', _selectedTag == null),
                  ..._allTags.map((tag) => _buildTagChip(tag, _selectedTag == tag)),
                ],
              ),
            ),
          Expanded(
            child: _notes.isEmpty
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
                            Icons.note_rounded,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No notes yet',
                          style: AppTheme.heading3,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap + to create your first note',
                          style: AppTheme.caption,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      return NoteCard(
                        note: _notes[index],
                        onTap: () => _showNoteDialog(_notes[index]),
                        onDelete: () async {
                          await _repository.deleteNote(_notes[index].id);
                          _loadNotes();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }

  Widget _buildTagChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _filterByTag(label == 'All' ? null : label),
        backgroundColor: AppTheme.cardColor,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
        ),
      ),
    );
  }
}

import '../models/note.dart';
import '../models/journal_entry.dart';
import 'hive_storage_service.dart';
import 'package:uuid/uuid.dart';

class NotesRepository {
  final HiveStorageService _storage;
  final _uuid = const Uuid();

  NotesRepository(this._storage);

  Future<List<Note>> loadNotes() async {
    return _storage.notesBox.values.toList()
      ..sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));
  }

  Future<void> saveNote(Note note) async {
    await _storage.notesBox.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await _storage.notesBox.delete(id);
  }

  Future<List<Note>> searchNotes(String query) async {
    final notes = await loadNotes();
    final lowerQuery = query.toLowerCase();
    return notes.where((note) =>
      note.title.toLowerCase().contains(lowerQuery) ||
      note.content.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  Future<List<Note>> getNotesByTag(String tag) async {
    final notes = await loadNotes();
    return notes.where((note) => note.tags.contains(tag)).toList();
  }

  Future<List<String>> getAllTags() async {
    final notes = await loadNotes();
    final tags = <String>{};
    for (final note in notes) {
      tags.addAll(note.tags);
    }
    return tags.toList()..sort();
  }

  Future<JournalEntry?> getJournalEntryForDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    try {
      return _storage.journalEntriesBox.values.firstWhere(
        (entry) => _isSameDay(entry.date, normalized),
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<JournalEntry>> loadJournalEntries() async {
    return _storage.journalEntriesBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveJournalEntry(JournalEntry entry) async {
    await _storage.journalEntriesBox.put(entry.id, entry);
  }

  String generateId() => _uuid.v4();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

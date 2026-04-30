import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/contact.dart';
import '../data/life_areas_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';

class RelationshipsScreen extends StatefulWidget {
  const RelationshipsScreen({super.key});

  @override
  State<RelationshipsScreen> createState() => _RelationshipsScreenState();
}

class _RelationshipsScreenState extends State<RelationshipsScreen> {
  late LifeAreasRepository _repo;
  List<Contact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepo();
  }

  Future<void> _initRepo() async {
    final storage = HiveStorageService();
    await storage.init();
    _repo = LifeAreasRepository(storage);
    await _loadData();
  }

  Future<void> _loadData() async {
    final contacts = await _repo.loadContacts();
    setState(() {
      _contacts = contacts;
      _isLoading = false;
    });
  }

  Future<void> _addOrEditContact([Contact? existingContact]) async {
    final nameController = TextEditingController(text: existingContact?.name ?? '');
    final notesController = TextEditingController(text: existingContact?.notes ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingContact == null ? 'New Contact' : 'Edit Contact', style: AppTheme.headingLarge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                style: AppTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: AppTheme.labelMedium,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.warningOrange, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                style: AppTheme.bodyLarge,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  labelStyle: AppTheme.labelMedium,
                  hintText: 'Interests, preferences, etc.',
                  hintStyle: AppTheme.bodyMedium,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.warningOrange, width: 2),
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
              backgroundColor: AppTheme.warningOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Save', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final contact = existingContact != null
          ? (existingContact
            ..name = nameController.text
            ..notes = notesController.text)
          : Contact(
              id: const Uuid().v4(),
              name: nameController.text,
              importantDates: [],
              notes: notesController.text,
            );

      await _repo.saveContact(contact);
      await _loadData();
    }
  }

  Future<void> _logInteraction(Contact contact) async {
    contact.lastInteraction = DateTime.now();
    await _repo.saveContact(contact);
    await _loadData();
  }

  Future<void> _deleteContact(Contact contact) async {
    await _repo.deleteContact(contact.id);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Relationships', style: AppTheme.displayMedium),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.borderGray),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) => _buildContactCard(_contacts[index]),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditContact(),
        backgroundColor: AppTheme.warningOrange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Contact', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildContactCard(Contact contact) {
    final daysSinceInteraction = contact.lastInteraction != null
        ? DateTime.now().difference(contact.lastInteraction!).inDays
        : null;

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
          onTap: () => _addOrEditContact(contact),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.warningOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          contact.name[0].toUpperCase(),
                          style: AppTheme.headingLarge.copyWith(color: AppTheme.warningOrange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contact.name, style: AppTheme.headingMedium),
                          if (daysSinceInteraction != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Last contact: $daysSinceInteraction days ago',
                              style: AppTheme.bodySmall.copyWith(
                                color: daysSinceInteraction > 30 ? AppTheme.dangerRed : AppTheme.textTertiary,
                              ),
                            ),
                          ] else
                            Text('No interactions yet', style: AppTheme.bodySmall),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed),
                      onPressed: () => _deleteContact(contact),
                    ),
                  ],
                ),
                if (contact.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(contact.notes, style: AppTheme.bodyMedium),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _logInteraction(contact),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: Text('Log Interaction', style: AppTheme.labelMedium),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.warningOrange,
                    side: const BorderSide(color: AppTheme.warningOrange),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
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
              color: AppTheme.warningOrange.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_rounded, size: 64, color: AppTheme.warningOrange.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text('No contacts yet', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text('Add people you want to stay connected with', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}

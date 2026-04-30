import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/contact.dart';
import '../data/life_areas_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

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
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Interaction logged', style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _deleteContact(Contact contact) async {
    await _repo.deleteContact(contact.id);
    await _loadData();
  }

  String _getLastInteractionText(DateTime? lastInteraction) {
    if (lastInteraction == null) return 'Never';
    final days = DateTime.now().difference(lastInteraction).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    if (days < 30) return '${(days / 7).floor()} weeks ago';
    return '${(days / 30).floor()} months ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: GradientAppBar(
        title: 'Relationships',
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
        heroTag: 'relationships_fab',
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
        : 999;
    final needsAttention = daysSinceInteraction > 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: needsAttention ? AppTheme.warningOrange.withOpacity(0.3) : AppTheme.borderGray,
          width: needsAttention ? 2 : 1,
        ),
      ),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact.name, style: AppTheme.headingMedium),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            'Last: ${_getLastInteractionText(contact.lastInteraction)}',
                            style: AppTheme.bodySmall.copyWith(
                              color: needsAttention ? AppTheme.warningOrange : AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => Future.delayed(Duration.zero, () => _addOrEditContact(contact)),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_rounded, size: 20),
                          const SizedBox(width: 12),
                          Text('Edit', style: AppTheme.bodyMedium),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () => _logInteraction(contact),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 20, color: AppTheme.successGreen),
                          const SizedBox(width: 12),
                          Text('Log Interaction', style: AppTheme.bodyMedium),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () => _deleteContact(contact),
                      child: Row(
                        children: [
                          const Icon(Icons.delete_rounded, size: 20, color: AppTheme.dangerRed),
                          const SizedBox(width: 12),
                          Text('Delete', style: AppTheme.bodyMedium.copyWith(color: AppTheme.dangerRed)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (contact.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(contact.notes, style: AppTheme.bodyMedium),
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

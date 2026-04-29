import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/contact.dart';
import '../data/life_areas_repository.dart';
import '../data/hive_storage_service.dart';

class RelationshipsScreen extends StatefulWidget {
  const RelationshipsScreen({super.key});

  @override
  State<RelationshipsScreen> createState() => _RelationshipsScreenState();
}

class _RelationshipsScreenState extends State<RelationshipsScreen> {
  late LifeAreasRepository _repository;
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _repository = LifeAreasRepository(HiveStorageService());
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await _repository.loadContacts();
    setState(() => _contacts = contacts);
  }

  void _showAddContactDialog([Contact? contact]) {
    final nameController = TextEditingController(text: contact?.name ?? '');
    final notesController = TextEditingController(text: contact?.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newContact = Contact(
                id: contact?.id ?? _repository.generateId(),
                name: nameController.text,
                importantDates: contact?.importantDates ?? [],
                lastInteraction: contact?.lastInteraction,
                notes: notesController.text,
              );

              await _repository.saveContact(newContact);
              Navigator.pop(context);
              _loadContacts();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _logInteraction(Contact contact) async {
    contact.lastInteraction = DateTime.now();
    await _repository.saveContact(contact);
    _loadContacts();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Interaction logged')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Relationships'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: _contacts.isEmpty
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
                      Icons.people_rounded,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('No contacts yet', style: AppTheme.heading3),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: Text(
                              contact.name[0].toUpperCase(),
                              style: const TextStyle(color: AppTheme.primaryColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(contact.name, style: AppTheme.heading3.copyWith(fontSize: 16)),
                                if (contact.lastInteraction != null)
                                  Text(
                                    'Last: ${_formatDate(contact.lastInteraction!)}',
                                    style: AppTheme.caption,
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: () => _logInteraction(contact),
                            color: AppTheme.successColor,
                          ),
                        ],
                      ),
                      if (contact.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(contact.notes, style: AppTheme.bodyMedium),
                      ],
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddContactDialog(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Contact'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }
}

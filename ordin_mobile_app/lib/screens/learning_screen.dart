import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/learning_item.dart';
import '../data/life_areas_repository.dart';
import '../data/hive_storage_service.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late LifeAreasRepository _repository;
  List<LearningItem> _items = [];

  @override
  void initState() {
    super.initState();
    _repository = LifeAreasRepository(HiveStorageService());
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _repository.loadLearningItems();
    setState(() => _items = items);
  }

  void _showAddItemDialog([LearningItem? item]) {
    final titleController = TextEditingController(text: item?.title ?? '');
    LearningType selectedType = item?.type ?? LearningType.book;
    LearningStatus selectedStatus = item?.status ?? LearningStatus.notStarted;
    double progress = item?.progress ?? 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Add Learning Item' : 'Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                DropdownButtonFormField<LearningType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: LearningType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedType = value);
                  },
                ),
                DropdownButtonFormField<LearningStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: LearningStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name[0].toUpperCase() + status.name.substring(1)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedStatus = value);
                  },
                ),
                const SizedBox(height: 12),
                Text('Progress: ${(progress * 100).toInt()}%'),
                Slider(
                  value: progress,
                  onChanged: (value) => setDialogState(() => progress = value),
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
                final newItem = LearningItem(
                  id: item?.id ?? _repository.generateId(),
                  title: titleController.text,
                  type: selectedType,
                  status: selectedStatus,
                  progress: progress,
                  completedDate: selectedStatus == LearningStatus.completed
                      ? DateTime.now()
                      : null,
                );

                await _repository.saveLearningItem(newItem);
                Navigator.pop(context);
                _loadItems();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Learning'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 40,
                      color: AppTheme.warningColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('No learning items yet', style: AppTheme.heading3),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.type.name[0].toUpperCase() + item.type.name.substring(1),
                              style: AppTheme.caption.copyWith(color: AppTheme.warningColor),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showAddItemDialog(item),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(item.title, style: AppTheme.heading3.copyWith(fontSize: 16)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: item.progress,
                              backgroundColor: AppTheme.textSecondary.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation(AppTheme.warningColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(item.progress * 100).toInt()}%',
                            style: AppTheme.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(),
        backgroundColor: AppTheme.warningColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}

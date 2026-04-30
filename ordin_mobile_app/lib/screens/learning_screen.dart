import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/learning_item.dart';
import '../data/life_areas_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late LifeAreasRepository _repo;
  List<LearningItem> _items = [];
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
    final items = await _repo.loadLearningItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _addOrEditItem([LearningItem? existingItem]) async {
    final titleController = TextEditingController(text: existingItem?.title ?? '');
    LearningType? type = existingItem?.type;
    LearningStatus? status = existingItem?.status ?? LearningStatus.notStarted;
    double progress = existingItem?.progress ?? 0.0;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existingItem == null ? 'New Learning Item' : 'Edit Item', style: AppTheme.headingLarge),
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
                DropdownButtonFormField<LearningType>(
                  value: type,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: AppTheme.labelMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: LearningType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(_typeName(t), style: AppTheme.bodyLarge),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => type = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<LearningStatus>(
                  value: status,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: AppTheme.labelMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: LearningStatus.values.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(_statusName(s), style: AppTheme.bodyLarge),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => status = value),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress: ${(progress * 100).toInt()}%', style: AppTheme.labelMedium),
                    const SizedBox(height: 8),
                    Slider(
                      value: progress,
                      onChanged: (value) => setDialogState(() => progress = value),
                      activeColor: AppTheme.primaryBlue,
                    ),
                  ],
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
      ),
    );

    if (result == true && titleController.text.isNotEmpty && type != null && status != null) {
      final item = existingItem != null
          ? (existingItem
            ..title = titleController.text
            ..type = type!
            ..status = status!
            ..progress = progress
            ..completedDate = status == LearningStatus.completed ? DateTime.now() : null)
          : LearningItem(
              id: const Uuid().v4(),
              title: titleController.text,
              type: type!,
              status: status!,
              progress: progress,
              completedDate: status == LearningStatus.completed ? DateTime.now() : null,
            );

      await _repo.saveLearningItem(item);
      await _loadData();
    }
  }

  Future<void> _deleteItem(LearningItem item) async {
    await _repo.deleteLearningItem(item.id);
    await _loadData();
  }

  String _typeName(LearningType type) {
    switch (type) {
      case LearningType.book:
        return 'Book';
      case LearningType.course:
        return 'Course';
      case LearningType.skill:
        return 'Skill';
      case LearningType.certification:
        return 'Certification';
    }
  }

  String _statusName(LearningStatus status) {
    switch (status) {
      case LearningStatus.notStarted:
        return 'Not Started';
      case LearningStatus.inProgress:
        return 'In Progress';
      case LearningStatus.completed:
        return 'Completed';
      case LearningStatus.paused:
        return 'Paused';
    }
  }

  Color _statusColor(LearningStatus status) {
    switch (status) {
      case LearningStatus.notStarted:
        return AppTheme.textSecondary;
      case LearningStatus.inProgress:
        return AppTheme.primaryBlue;
      case LearningStatus.completed:
        return AppTheme.successGreen;
      case LearningStatus.paused:
        return AppTheme.warningOrange;
    }
  }

  IconData _typeIcon(LearningType type) {
    switch (type) {
      case LearningType.book:
        return Icons.menu_book_rounded;
      case LearningType.course:
        return Icons.school_rounded;
      case LearningType.skill:
        return Icons.build_rounded;
      case LearningType.certification:
        return Icons.workspace_premium_rounded;
    }
  }

  int get _inProgressCount => _items.where((i) => i.status == LearningStatus.inProgress).length;
  int get _completedCount => _items.where((i) => i.status == LearningStatus.completed).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: GradientAppBar(
        title: 'Learning',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  color: AppTheme.surfaceWhite,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Total', '${_items.length}', Icons.library_books_rounded, AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Active', '$_inProgressCount', Icons.play_circle_rounded, AppTheme.warningOrange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Done', '$_completedCount', Icons.check_circle_rounded, AppTheme.successGreen),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _items.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _items.length,
                          itemBuilder: (context, index) => _buildItemCard(_items[index]),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'learning_fab',
        onPressed: () => _addOrEditItem(),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Item', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.headingMedium.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildItemCard(LearningItem item) {
    final statusColor = _statusColor(item.status);

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
          onTap: () => _addOrEditItem(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_typeIcon(item.type), color: AppTheme.primaryBlue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: AppTheme.headingMedium),
                          const SizedBox(height: 4),
                          Text(_typeName(item.type), style: AppTheme.bodySmall),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed),
                      onPressed: () => _deleteItem(item),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_statusName(item.status), style: AppTheme.labelMedium.copyWith(color: statusColor)),
                    ),
                    const Spacer(),
                    Text('${(item.progress * 100).toInt()}%', style: AppTheme.labelMedium.copyWith(color: statusColor)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.progress,
                    backgroundColor: AppTheme.borderGray,
                    valueColor: AlwaysStoppedAnimation(statusColor),
                    minHeight: 6,
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
              color: AppTheme.primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.school_rounded, size: 64, color: AppTheme.primaryBlue.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text('No learning items yet', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text('Start tracking your learning journey', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}

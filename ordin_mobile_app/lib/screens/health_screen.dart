import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/health_metric.dart';
import '../data/life_areas_repository.dart';
import '../data/hive_storage_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  late LifeAreasRepository _repository;
  List<HealthMetric> _metrics = [];

  @override
  void initState() {
    super.initState();
    _repository = LifeAreasRepository(HiveStorageService());
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final metrics = await _repository.loadHealthMetrics();
    setState(() => _metrics = metrics);
  }

  void _showAddMetricDialog() {
    HealthMetricType selectedType = HealthMetricType.workout;
    final valueController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Log Health Metric'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<HealthMetricType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: HealthMetricType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getMetricLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(
                    labelText: _getValueLabel(selectedType),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 2,
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
                final value = double.tryParse(valueController.text);
                if (value == null) return;

                final metric = HealthMetric(
                  id: _repository.generateId(),
                  date: DateTime.now(),
                  type: selectedType,
                  value: value,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );

                await _repository.saveHealthMetric(metric);
                Navigator.pop(context);
                _loadMetrics();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _getMetricLabel(HealthMetricType type) {
    switch (type) {
      case HealthMetricType.workout:
        return 'Workout';
      case HealthMetricType.waterIntake:
        return 'Water Intake';
      case HealthMetricType.sleep:
        return 'Sleep';
      case HealthMetricType.weight:
        return 'Weight';
      case HealthMetricType.meals:
        return 'Meals';
    }
  }

  String _getValueLabel(HealthMetricType type) {
    switch (type) {
      case HealthMetricType.workout:
        return 'Duration (minutes)';
      case HealthMetricType.waterIntake:
        return 'Amount (glasses)';
      case HealthMetricType.sleep:
        return 'Hours';
      case HealthMetricType.weight:
        return 'Weight (kg)';
      case HealthMetricType.meals:
        return 'Number of meals';
    }
  }

  String _formatValue(HealthMetric metric) {
    switch (metric.type) {
      case HealthMetricType.workout:
        return '${metric.value.toInt()} min';
      case HealthMetricType.waterIntake:
        return '${metric.value.toInt()} glasses';
      case HealthMetricType.sleep:
        return '${metric.value} hrs';
      case HealthMetricType.weight:
        return '${metric.value} kg';
      case HealthMetricType.meals:
        return '${metric.value.toInt()} meals';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Health & Fitness'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: _metrics.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      size: 40,
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('No health metrics yet', style: AppTheme.heading3),
                  const SizedBox(height: 8),
                  const Text('Start tracking your health', style: AppTheme.caption),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _metrics.length,
              itemBuilder: (context, index) {
                final metric = _metrics[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getMetricLabel(metric.type),
                              style: AppTheme.heading3.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatValue(metric),
                              style: AppTheme.bodyMedium,
                            ),
                            if (metric.notes != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                metric.notes!,
                                style: AppTheme.caption,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(metric.date),
                        style: AppTheme.caption,
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMetricDialog,
        backgroundColor: AppTheme.successColor,
        icon: const Icon(Icons.add),
        label: const Text('Log Metric'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

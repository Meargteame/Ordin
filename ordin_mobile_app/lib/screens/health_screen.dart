import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/health_metric.dart';
import '../data/life_areas_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  late LifeAreasRepository _repo;
  List<HealthMetric> _metrics = [];
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
    final metrics = await _repo.loadHealthMetrics();
    setState(() {
      _metrics = metrics;
      _isLoading = false;
    });
  }

  Future<void> _addMetric() async {
    HealthMetricType? type;
    final valueController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Log Health Metric', style: AppTheme.headingLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<HealthMetricType>(
                  value: type,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: AppTheme.labelMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: HealthMetricType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(_metricName(t), style: AppTheme.bodyLarge),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => type = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  style: AppTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Value',
                    labelStyle: AppTheme.labelMedium,
                    hintText: type != null ? _metricHint(type!) : 'Enter value',
                    hintStyle: AppTheme.bodyMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.successGreen, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  style: AppTheme.bodyLarge,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    labelStyle: AppTheme.labelMedium,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.successGreen, width: 2),
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
                backgroundColor: AppTheme.successGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Log', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result == true && type != null && valueController.text.isNotEmpty) {
      final metric = HealthMetric(
        id: const Uuid().v4(),
        date: DateTime.now(),
        type: type!,
        value: double.parse(valueController.text),
        notes: notesController.text.isEmpty ? null : notesController.text,
      );
      await _repo.saveHealthMetric(metric);
      await _loadData();
    }
  }

  String _metricName(HealthMetricType type) {
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

  String _metricHint(HealthMetricType type) {
    switch (type) {
      case HealthMetricType.workout:
        return 'Minutes';
      case HealthMetricType.waterIntake:
        return 'Glasses';
      case HealthMetricType.sleep:
        return 'Hours';
      case HealthMetricType.weight:
        return 'kg';
      case HealthMetricType.meals:
        return 'Count';
    }
  }

  String _metricUnit(HealthMetricType type) {
    switch (type) {
      case HealthMetricType.workout:
        return 'min';
      case HealthMetricType.waterIntake:
        return 'glasses';
      case HealthMetricType.sleep:
        return 'hrs';
      case HealthMetricType.weight:
        return 'kg';
      case HealthMetricType.meals:
        return 'meals';
    }
  }

  IconData _metricIcon(HealthMetricType type) {
    switch (type) {
      case HealthMetricType.workout:
        return Icons.fitness_center_rounded;
      case HealthMetricType.waterIntake:
        return Icons.water_drop_rounded;
      case HealthMetricType.sleep:
        return Icons.bedtime_rounded;
      case HealthMetricType.weight:
        return Icons.monitor_weight_rounded;
      case HealthMetricType.meals:
        return Icons.restaurant_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: GradientAppBar(
        title: 'Health',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _metrics.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _metrics.length,
                  itemBuilder: (context, index) => _buildMetricCard(_metrics[index]),
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'health_fab',
        onPressed: _addMetric,
        backgroundColor: AppTheme.successGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Log Metric', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildMetricCard(HealthMetric metric) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_metricIcon(metric.type), color: AppTheme.successGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_metricName(metric.type), style: AppTheme.headingMedium),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, h:mm a').format(metric.date),
                  style: AppTheme.bodySmall,
                ),
                if (metric.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(metric.notes!, style: AppTheme.bodyMedium),
                ],
              ],
            ),
          ),
          Text(
            '${metric.value.toStringAsFixed(metric.type == HealthMetricType.weight ? 1 : 0)} ${_metricUnit(metric.type)}',
            style: AppTheme.headingLarge.copyWith(color: AppTheme.successGreen),
          ),
        ],
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
              color: AppTheme.successGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_rounded, size: 64, color: AppTheme.successGreen.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text('No health metrics yet', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text('Start tracking your health journey', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}

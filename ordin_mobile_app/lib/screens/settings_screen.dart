import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/export_service.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ExportService _exportService;
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final storage = HiveStorageService();
    await storage.init();
    _exportService = ExportService(storage);
    await _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _exportService.getExportStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    
    try {
      await _exportService.shareExport();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully', style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e', style: AppTheme.bodyMedium.copyWith(color: Colors.white)),
            backgroundColor: AppTheme.dangerRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Ordin',
      applicationVersion: '2.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 32),
      ),
      children: [
        const SizedBox(height: 16),
        Text(
          'Complete life management system for productivity, health, finance, relationships, and learning.',
          style: AppTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Built with Flutter',
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: GradientAppBar(
        title: 'Settings',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Data Overview', style: AppTheme.headingLarge),
                const SizedBox(height: 16),
                _buildStatsGrid(),
                const SizedBox(height: 32),
                Text('Data Management', style: AppTheme.headingLarge),
                const SizedBox(height: 16),
                _buildActionCard(
                  'Export All Data',
                  'Backup your complete data to JSON file',
                  Icons.download_rounded,
                  AppTheme.primaryBlue,
                  _isExporting ? null : _exportData,
                  isLoading: _isExporting,
                ),
                const SizedBox(height: 32),
                Text('About', style: AppTheme.headingLarge),
                const SizedBox(height: 16),
                _buildActionCard(
                  'About Ordin',
                  'Version and app information',
                  Icons.info_rounded,
                  AppTheme.infoBlue,
                  _showAbout,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  'Last Export',
                  'Never',
                  Icons.history_rounded,
                ),
              ],
            ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Tasks', '${_stats['tasks'] ?? 0}', Icons.check_circle_rounded, AppTheme.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Habits', '${_stats['habits'] ?? 0}', Icons.auto_awesome_rounded, AppTheme.successGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Goals', '${_stats['goals'] ?? 0}', Icons.flag_rounded, AppTheme.warningOrange),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Projects', '${_stats['projects'] ?? 0}', Icons.folder_rounded, AppTheme.infoBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Notes', '${_stats['notes'] ?? 0}', Icons.note_rounded, AppTheme.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('Journal', '${_stats['journalEntries'] ?? 0}', Icons.book_rounded, AppTheme.infoBlue),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTheme.headingLarge.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback? onTap, {
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        )
                      : Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTheme.headingMedium),
                      const SizedBox(height: 2),
                      Text(description, style: AppTheme.bodyMedium),
                    ],
                  ),
                ),
                if (!isLoading) const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.textSecondary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.labelMedium),
                const SizedBox(height: 2),
                Text(value, style: AppTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

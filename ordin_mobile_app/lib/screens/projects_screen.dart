import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../data/project_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/app_theme.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late ProjectRepository _projectRepo;
  List<Project> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRepo();
  }

  Future<void> _initRepo() async {
    final storage = HiveStorageService();
    await storage.init();
    _projectRepo = ProjectRepository();
    await _projectRepo.init(storage);
    await _loadProjects();
  }

  Future<void> _loadProjects() async {
    final projects = await _projectRepo.loadProjects();
    setState(() {
      _projects = projects;
      _isLoading = false;
    });
  }

  Future<void> _addProject() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final categoryController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Project', style: AppTheme.headingLarge),
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
              TextField(
                controller: descController,
                style: AppTheme.bodyLarge,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: AppTheme.labelMedium,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                style: AppTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: AppTheme.labelMedium,
                  hintText: 'e.g., Work, Personal, Learning',
                  hintStyle: AppTheme.bodyMedium,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
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
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Add', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      final project = Project(
        id: const Uuid().v4(),
        title: titleController.text,
        description: descController.text,
        status: ProjectStatus.planning,
        category: categoryController.text.isEmpty ? 'General' : categoryController.text,
        progress: 0.0,
        createdDate: DateTime.now(),
      );
      await _projectRepo.saveProject(project);
      await _loadProjects();
    }
  }

  Future<void> _deleteProject(Project project) async {
    await _projectRepo.deleteProject(project.id);
    await _loadProjects();
  }

  int get _activeCount => _projects.where((p) => p.status == ProjectStatus.active).length;
  int get _completedCount => _projects.where((p) => p.status == ProjectStatus.completed).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Projects', style: AppTheme.displayMedium),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.borderGray),
        ),
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
                        child: _buildStatCard('Total', '${_projects.length}', Icons.folder_rounded, AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Active', '$_activeCount', Icons.play_circle_rounded, AppTheme.warningOrange),
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
                  child: _projects.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _projects.length,
                          itemBuilder: (context, index) => _buildProjectCard(_projects[index]),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProject,
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Project', style: AppTheme.labelLarge.copyWith(color: Colors.white)),
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
          Text(value, style: AppTheme.headingLarge.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.labelMedium),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    final statusColor = _statusColor(project.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(_statusName(project.status), style: AppTheme.labelMedium.copyWith(color: statusColor)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.infoBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(project.category, style: AppTheme.labelMedium.copyWith(color: AppTheme.infoBlue)),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed),
                  onPressed: () => _deleteProject(project),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(project.title, style: AppTheme.headingMedium),
            if (project.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(project.description, style: AppTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: project.progress,
                      backgroundColor: AppTheme.borderGray,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${(project.progress * 100).toInt()}%', style: AppTheme.labelMedium.copyWith(color: statusColor)),
              ],
            ),
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
              color: AppTheme.primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_rounded, size: 64, color: AppTheme.primaryBlue.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text('No projects yet', style: AppTheme.headingLarge),
          const SizedBox(height: 8),
          Text('Create your first project to get started', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }

  String _statusName(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning: return 'Planning';
      case ProjectStatus.active: return 'Active';
      case ProjectStatus.onHold: return 'On Hold';
      case ProjectStatus.completed: return 'Completed';
      case ProjectStatus.archived: return 'Archived';
    }
  }

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning: return AppTheme.infoBlue;
      case ProjectStatus.active: return AppTheme.warningOrange;
      case ProjectStatus.onHold: return AppTheme.textSecondary;
      case ProjectStatus.completed: return AppTheme.successGreen;
      case ProjectStatus.archived: return AppTheme.textTertiary;
    }
  }
}

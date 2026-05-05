import 'package:flutter/material.dart';
import '../models/project.dart';
import '../data/project_repository.dart';
import '../data/hive_storage_service.dart';
import '../theme/theme_helper.dart';
import '../theme/ordin_theme.dart';
import 'project_form_screen.dart';

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
      _projects = projects.where((p) => p.status != ProjectStatus.completed).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.backgroundColor(context),
        elevation: 0,
        title: Text(
          'Projects',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ThemeHelper.textPrimary(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeHelper.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) => _buildProjectCard(_projects[index]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectFormScreen(
                onSave: (newProject) async {
                  await _projectRepo.saveProject(newProject);
                  await _loadProjects();
                },
              ),
              fullscreenDialog: true,
            ),
          );
        },
        backgroundColor: OrdinTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    final progress = project.progress;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: ThemeHelper.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.folder, color: Color(0xFFEC4899), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ThemeHelper.textPrimary(context),
                      ),
                    ),
                    if (project.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        project.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: ThemeHelper.textSecondary(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              _buildStatusBadge(project.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}% complete',
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeHelper.textSecondary(context),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: OrdinTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: ThemeHelper.borderColor(context),
                        valueColor: const AlwaysStoppedAnimation<Color>(OrdinTheme.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ProjectStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case ProjectStatus.planning:
        color = const Color(0xFF6B7280);
        label = 'Planning';
        break;
      case ProjectStatus.active:
        color = const Color(0xFF2563EB);
        label = 'Active';
        break;
      case ProjectStatus.onHold:
        color = const Color(0xFFF59E0B);
        label = 'On Hold';
        break;
      case ProjectStatus.completed:
        color = const Color(0xFF10B981);
        label = 'Completed';
        break;
      case ProjectStatus.archived:
        color = const Color(0xFF9CA3AF);
        label = 'Archived';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 80, color: ThemeHelper.borderColor(context)),
            const SizedBox(height: 24),
            Text(
              'No projects yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ThemeHelper.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first project to organize tasks',
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.textTertiary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

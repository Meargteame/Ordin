import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/life_area.dart';
import '../data/life_areas_repository.dart';
import '../data/hive_storage_service.dart';
import '../widgets/life_area_card.dart';
import 'health_screen.dart';
import 'finance_screen.dart';
import 'relationships_screen.dart';
import 'learning_screen.dart';

class LifeAreasDashboardScreen extends StatefulWidget {
  const LifeAreasDashboardScreen({super.key});

  @override
  State<LifeAreasDashboardScreen> createState() => _LifeAreasDashboardScreenState();
}

class _LifeAreasDashboardScreenState extends State<LifeAreasDashboardScreen> {
  late LifeAreasRepository _repository;
  List<LifeArea> _lifeAreas = [];

  @override
  void initState() {
    super.initState();
    _repository = LifeAreasRepository(HiveStorageService());
    _loadLifeAreas();
  }

  Future<void> _loadLifeAreas() async {
    var areas = await _repository.loadLifeAreas();
    
    // Initialize default life areas if empty
    if (areas.isEmpty) {
      await _initializeDefaultAreas();
      areas = await _repository.loadLifeAreas();
    }
    
    setState(() => _lifeAreas = areas);
  }

  Future<void> _initializeDefaultAreas() async {
    final defaultAreas = [
      LifeArea(
        id: _repository.generateId(),
        name: 'Health & Fitness',
        type: LifeAreaType.health,
        healthScore: 0.0,
        lastUpdated: DateTime.now(),
      ),
      LifeArea(
        id: _repository.generateId(),
        name: 'Finance',
        type: LifeAreaType.finance,
        healthScore: 0.0,
        lastUpdated: DateTime.now(),
      ),
      LifeArea(
        id: _repository.generateId(),
        name: 'Relationships',
        type: LifeAreaType.relationships,
        healthScore: 0.0,
        lastUpdated: DateTime.now(),
      ),
      LifeArea(
        id: _repository.generateId(),
        name: 'Learning',
        type: LifeAreaType.learning,
        healthScore: 0.0,
        lastUpdated: DateTime.now(),
      ),
    ];

    for (final area in defaultAreas) {
      await _repository.saveLifeArea(area);
    }
  }

  void _navigateToArea(LifeArea area) {
    Widget? screen;
    
    switch (area.type) {
      case LifeAreaType.health:
        screen = const HealthScreen();
        break;
      case LifeAreaType.finance:
        screen = const FinanceScreen();
        break;
      case LifeAreaType.relationships:
        screen = const RelationshipsScreen();
        break;
      case LifeAreaType.learning:
        screen = const LearningScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen!),
    ).then((_) => _loadLifeAreas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Life Areas'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: _lifeAreas.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _lifeAreas.length,
              itemBuilder: (context, index) {
                return LifeAreaCard(
                  area: _lifeAreas[index],
                  onTap: () => _navigateToArea(_lifeAreas[index]),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/today_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/more_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/advanced_goals_dashboard.dart';
import 'screens/projects_screen.dart';
import 'screens/time_tracking_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/health_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/relationships_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/task_form_screen.dart';
import 'widgets/habit_form_screen.dart';
import 'theme/ordin_theme.dart';
import 'theme/theme_helper.dart';
import 'data/hive_storage_service.dart';
import 'data/task_repository.dart';
import 'data/habit_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize Hive storage
  final storage = HiveStorageService();
  await storage.init();
  
  runApp(const OrdinApp());
}

class OrdinApp extends StatefulWidget {
  const OrdinApp({super.key});

  @override
  State<OrdinApp> createState() => _OrdinAppState();
}

class _OrdinAppState extends State<OrdinApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ordin',
      debugShowCheckedModeBanner: false,
      theme: OrdinTheme.lightTheme,
      darkTheme: OrdinTheme.darkTheme,
      themeMode: _themeMode,
      home: const SplashScreen(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ordin',
      debugShowCheckedModeBanner: false,
      theme: OrdinTheme.lightTheme,
      darkTheme: OrdinTheme.darkTheme,
      themeMode: _themeMode,
      home: MainScreen(
        onThemeChanged: _changeTheme,
        currentThemeMode: _themeMode,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;
  
  const MainScreen({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late TaskRepository _taskRepo;
  late HabitRepository _habitRepo;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initRepos();
  }

  Future<void> _initRepos() async {
    final storage = HiveStorageService();
    await storage.init();
    _taskRepo = TaskRepository(storage);
    _habitRepo = HabitRepository(storage);
    setState(() {
      _isInitialized = true;
    });
  }

  List<Widget> get _screens => [
    TodayScreen(key: ValueKey('today_$_currentIndex')),
    TasksScreen(key: ValueKey('tasks_$_currentIndex')),
    HabitsScreen(key: ValueKey('habits_$_currentIndex')),
    MoreScreen(
      onThemeChanged: widget.onThemeChanged,
      currentThemeMode: widget.currentThemeMode,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      drawer: _buildGlobalDrawer(context),
      appBar: _buildAppBar(context),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? OrdinTheme.darkSurface 
              : OrdinTheme.lightSurface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? OrdinTheme.darkBorder
                  : OrdinTheme.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: OrdinTheme.primary,
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? OrdinTheme.darkTextTertiary
              : OrdinTheme.lightTextTertiary,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          enableFeedback: false, // Disable haptic feedback
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'TODAY',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              activeIcon: Icon(Icons.check_circle),
              label: 'TASKS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bolt_outlined),
              activeIcon: Icon(Icons.bolt),
              label: 'HABITS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apps_outlined),
              activeIcon: Icon(Icons.apps),
              label: 'MORE',
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 1: // Tasks screen
        return FloatingActionButton(
          onPressed: () => _openTaskForm(),
          backgroundColor: OrdinTheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
      case 2: // Habits screen
        return FloatingActionButton(
          onPressed: () => _openHabitForm(),
          backgroundColor: OrdinTheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
      default:
        return null;
    }
  }

  void _openTaskForm() {
    if (!_isInitialized) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(
          onSave: (task) async {
            await _taskRepo.saveTask(task);
            // Force rebuild of screens to refresh data
            setState(() {});
          },
        ),
      ),
    );
  }

  void _openHabitForm() {
    if (!_isInitialized) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitFormScreen(
          onSave: (habit) async {
            await _habitRepo.saveHabit(habit);
            // Force rebuild of screens to refresh data
            setState(() {});
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final titles = ['Today', 'Tasks', 'Habits', 'Apps'];
    
    return AppBar(
      backgroundColor: ThemeHelper.backgroundColor(context),
      elevation: 0,
      title: _currentIndex == 3 ? Text(
        titles[_currentIndex],
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: ThemeHelper.textPrimary(context),
        ),
      ) : Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: OrdinTheme.primary.withOpacity(0.1),
            child: const Icon(Icons.person, color: OrdinTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Good morning, Alex',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeHelper.textPrimary(context),
            ),
          ),
        ],
      ),
      actions: [
        if (_currentIndex == 3) // More screen
          IconButton(
            icon: Icon(Icons.search, color: ThemeHelper.textSecondary(context)),
            onPressed: () {},
          )
        else ...[
          IconButton(
            icon: Icon(Icons.calendar_today_outlined, color: ThemeHelper.textSecondary(context)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: ThemeHelper.textSecondary(context)),
            onPressed: () {},
          ),
        ],
      ],
    );
  }

  Widget _buildGlobalDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: ThemeHelper.backgroundColor(context),
      width: 280,
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildDrawerSection(context, 'Core Apps', [
                    _DrawerItem(
                      icon: Icons.home_outlined,
                      title: 'Today',
                      color: OrdinTheme.primary,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 0);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.check_circle_outline,
                      title: 'Tasks',
                      color: OrdinTheme.primary,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 1);
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.bolt_outlined,
                      title: 'Habits',
                      color: OrdinTheme.primary,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 2);
                      },
                    ),
                  ]),
                  _buildDrawerSection(context, 'Life Management', [
                    _DrawerItem(
                      icon: Icons.flag_outlined,
                      title: 'Goals',
                      color: const Color(0xFF8B5CF6),
                      screen: const GoalsScreen(),
                    ),
                    _DrawerItem(
                      icon: Icons.psychology_outlined,
                      title: 'Goals Intelligence',
                      color: const Color(0xFF6366F1),
                      screen: const AdvancedGoalsDashboard(),
                    ),
                    _DrawerItem(
                      icon: Icons.folder_outlined,
                      title: 'Projects',
                      color: const Color(0xFFEC4899),
                      screen: const ProjectsScreen(),
                    ),
                    _DrawerItem(
                      icon: Icons.timer_outlined,
                      title: 'Time Tracking',
                      color: const Color(0xFF3B82F6),
                      screen: const TimeTrackingScreen(),
                    ),
                    _DrawerItem(
                      icon: Icons.calendar_today_outlined,
                      title: 'Calendar',
                      color: const Color(0xFF10B981),
                      screen: const CalendarScreen(),
                    ),
                  ]),
                  _buildDrawerSection(context, 'Knowledge & Reflection', [
                    _DrawerItem(
                      icon: Icons.note_outlined,
                      title: 'Notes',
                      color: const Color(0xFF6B7280),
                      screen: const NotesScreen(),
                    ),
                    _DrawerItem(
                      icon: Icons.book_outlined,
                      title: 'Journal',
                      color: const Color(0xFFF59E0B),
                      screen: const JournalScreen(),
                    ),
                  ]),
                  _buildDrawerSection(context, 'Life Areas', [
                    _DrawerItem(
                      icon: Icons.favorite_outline,
                      title: 'Health',
                      color: const Color(0xFFEF4444),
                      screen: const HealthScreen(),
                    ),
                    _DrawerItem(
                      icon: Icons.attach_money,
                      title: 'Finance',
                      color: const Color(0xFF10B981),
                      screen: const FinanceScreen(),
                    ),
                    _DrawerItem(
                      icon: Icons.people_outline,
                      title: 'Relationships',
                      color: const Color(0xFFEC4899),
                      screen: const RelationshipsScreen(),
                    ),
                    _DrawerItem(
                      icon: Icons.school_outlined,
                      title: 'Learning',
                      color: const Color(0xFF3B82F6),
                      screen: const LearningScreen(),
                    ),
                  ]),
                  _buildDrawerSection(context, 'Insights & Settings', [
                    _DrawerItem(
                      icon: Icons.insights_outlined,
                      title: 'Analytics',
                      color: OrdinTheme.primary,
                      screen: const AnalyticsScreen(),
                    ),
                    _DrawerItem(
                      icon: Icons.file_download_outlined,
                      title: 'Export',
                      color: const Color(0xFF6B7280),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export feature coming soon')),
                        );
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      color: const Color(0xFF6B7280),
                      screen: SettingsScreen(
                        onThemeChanged: widget.onThemeChanged,
                        currentThemeMode: widget.currentThemeMode,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            OrdinTheme.primary,
            OrdinTheme.primaryDark,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Alex Johnson',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Ordin Super App',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerSection(BuildContext context, String title, List<_DrawerItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ThemeHelper.textSecondary(context),
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items.map((item) => _buildDrawerItem(context, item)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDrawerItem(BuildContext context, _DrawerItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (item.onTap != null) {
              item.onTap!();
            } else if (item.screen != null) {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => item.screen!),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.textPrimary(context),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: ThemeHelper.textTertiary(context),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String title;
  final Color color;
  final Widget? screen;
  final VoidCallback? onTap;

  _DrawerItem({
    required this.icon,
    required this.title,
    required this.color,
    this.screen,
    this.onTap,
  });
}
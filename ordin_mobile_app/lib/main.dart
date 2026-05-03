import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/today_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/more_screen.dart';
import 'theme/ordin_theme.dart';
import 'data/hive_storage_service.dart';

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
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ordin',
      debugShowCheckedModeBanner: false,
      theme: OrdinTheme.lightTheme,
      darkTheme: OrdinTheme.darkTheme,
      themeMode: ThemeMode.light, // Start with light mode
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TodayScreen(),
    const TasksScreen(),
    const HabitsScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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
}

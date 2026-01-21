import 'package:flutter/material.dart';
import 'package:habitquest/widges/app_drawer.dart';
import 'package:habitquest/widges/bottom_nav.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'pages/calendar_page.dart';
import 'pages/checklist_page.dart';
import 'pages/focus_page.dart';
import 'pages/habit_page.dart';
import 'pages/profile_page.dart';
import 'services/local_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = LocalDb();
  await db.init();
  runApp(HabitQuestApp(db: db));
}

class HabitQuestApp extends StatelessWidget {
  const HabitQuestApp({super.key, required this.db});

  final LocalDb db;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(db)..loadAll(),
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'HabitQuest',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: state.settings.isDarkMode ? Brightness.dark : Brightness.light,
              ),
              fontFamily: 'Roboto',
            ),
            home: const MainShell(),
          );
        },
      ),
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static final pages = [
    const ChecklistPage(),
    const CalendarPage(),
    const HabitPage(),
    const FocusPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      drawer: const AppDrawer(),
      body: pages[state.activeTab],
      bottomNavigationBar: BottomNav(
        currentIndex: state.activeTab,
        onTap: state.setActiveTab,
      ),
    );
  }
}
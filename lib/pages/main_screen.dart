
import 'package:flutter/material.dart';
import 'package:habitquest/pages/profile_page.dart';
import 'package:provider/provider.dart';

import 'habit_page.dart';
import '../app_state.dart';
import '../widges/app_drawer.dart';
import 'calendar_page.dart';
import 'checklist_page.dart';
import 'focus_page.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: state.activeTab,
        onTap: (i) => context.read<AppState>().activeTab = i,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '清单'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: '视图'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: '习惯'),
          BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: '专注'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}

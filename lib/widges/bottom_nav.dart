import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: '清单'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: '视图'),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle_rounded), label: '习惯'),
        BottomNavigationBarItem(icon: Icon(Icons.local_fire_department_rounded), label: '专注'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: '我的'),
      ],
    );
  }
}
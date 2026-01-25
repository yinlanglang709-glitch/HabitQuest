import 'package:flutter/material.dart';

import 'models/chech_in.dart';
import 'models/habit.dart';
import 'models/memo.dart';
import 'models/user_settings.dart';
import 'services/local_db.dart';

class AppState extends ChangeNotifier {
  AppState(this.db);

  final LocalDb db;

  List<Habit> habits = [];
  List<CheckIn> checkIns = [];
  List<Memo> memos = [];
  UserSettings settings = UserSettings(isDarkMode: false, accentColor: 'blue');

  int activeTab = 2;

  Future<void> loadAll() async {
    habits = await db.getHabits(includeArchived: true);
    checkIns = await db.getCheckIns();
    memos = await db.getMemos();
    settings = await db.getSettings();
    notifyListeners();
  }

  void setActiveTab(int index) {
    activeTab = index;
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    await db.addHabit(habit);
    await loadAll();
  }

  Future<void> deleteHabit(String habitId, {required bool deleteCheckIns}) async {
    await db.deleteHabit(habitId, deleteCheckIns: deleteCheckIns);
    await loadAll();
  }

  Future<void> addCheckIn(CheckIn checkIn) async {
    await db.addCheckIn(checkIn);
    await loadAll();
  }

  Future<void> addMemo(Memo memo) async {
    await db.addMemo(memo);
    await loadAll();
  }

  Future<void> deleteMemo(String id) async {
    await db.deleteMemo(id);
    await loadAll();
  }

  Future<void> toggleDarkMode() async {
    settings = settings.copyWith(isDarkMode: !settings.isDarkMode);
    await db.updateSettings(settings);
    notifyListeners();
  }

  bool isHabitDoneToday(String habitId) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return checkIns.any((c) => c.habitId == habitId && c.date == today);
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/chech_in.dart';
import '../models/habit.dart';
import '../models/memo.dart';
import '../models/user_settings.dart';

class LocalDb {
  Database? _db;

  Future<void> init() async {
    final path = join(await getDatabasesPath(), 'habitquest.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE habits(
            id TEXT PRIMARY KEY,
            user_id TEXT,
            title TEXT,
            notes TEXT,
            icon TEXT,
            color TEXT,
            streak INTEGER,
            created_at TEXT,
            is_archived INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE check_ins(
            id TEXT PRIMARY KEY,
            habit_id TEXT,
            check_date TEXT,
            notes TEXT,
            timestamp TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE memos(
            id TEXT PRIMARY KEY,
            content TEXT,
            created_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE settings(
            id INTEGER PRIMARY KEY,
            is_dark_mode INTEGER,
            accent_color TEXT
          )
        ''');

        await db.insert(
            'settings', {'id': 1, 'is_dark_mode': 0, 'accent_color': 'blue'});

        await db.insert('habits', {
          'id': 'h1',
          'user_id': '1',
          'title': '思想1',
          'notes': '每日沉思，保持冷静',
          'icon': 'sun',
          'color': 'orange',
          'streak': 15,
          'created_at': DateTime.now().toIso8601String(),
        });
        await db.insert('habits', {
          'id': 'h2',
          'user_id': '1',
          'title': '脚跟靠拢起立50',
          'notes': '锻炼下肢力量',
          'icon': 'activity',
          'color': 'blue',
          'streak': 18,
          'created_at': DateTime.now().toIso8601String(),
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'ALTER TABLE habits ADD COLUMN is_archived INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<List<Habit>> getHabits({bool includeArchived = true}) async {
    final rows = await _db!.query(
      'habits',
      orderBy: 'created_at DESC',
      where: includeArchived ? null : 'is_archived = 0',
    );
    return rows.map(Habit.fromMap).toList();
  }

  Future<List<CheckIn>> getCheckIns() async {
    final rows = await _db!.query('check_ins');
    return rows.map(CheckIn.fromMap).toList();
  }

  Future<List<Memo>> getMemos() async {
    final rows = await _db!.query('memos', orderBy: 'created_at DESC');
    return rows.map(Memo.fromMap).toList();
  }

  Future<UserSettings> getSettings() async {
    final rows = await _db!.query('settings', where: 'id = ?', whereArgs: [1]);
    return UserSettings.fromMap(rows.first);
  }

  Future<void> updateSettings(UserSettings settings) async {
    await _db!
        .update('settings', settings.toMap(), where: 'id = ?', whereArgs: [1]);
  }

  Future<void> addHabit(Habit habit) async {
    await _db!.insert('habits', habit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> archiveHabit(String habitId) async {
    await _db!.update(
      'habits',
      {'is_archived': 1},
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }

  Future<void> deleteHabit(String habitId, {required bool deleteCheckIns}) async {
    await _db!.transaction((txn) async {
      if (deleteCheckIns) {
        await txn.delete('check_ins', where: 'habit_id = ?', whereArgs: [habitId]);
        await txn.delete('habits', where: 'id = ?', whereArgs: [habitId]);
      } else {
        await txn.update(
          'habits',
          {'is_archived': 1},
          where: 'id = ?',
          whereArgs: [habitId],
        );
      }
    });
  }

  Future<void> addCheckIn(CheckIn checkIn) async {
    final exists = await _db!.query(
      'check_ins',
      where: 'habit_id = ? AND check_date = ?',
      whereArgs: [checkIn.habitId, checkIn.date],
    );
    if (exists.isEmpty) {
      await _db!.insert('check_ins', checkIn.toMap());
      final habitRows = await _db!
          .query('habits', where: 'id = ?', whereArgs: [checkIn.habitId]);
      if (habitRows.isNotEmpty) {
        final habit = Habit.fromMap(habitRows.first);
        await _db!.update(
          'habits',
          habit.copyWith(streak: habit.streak + 1).toMap(),
          where: 'id = ?',
          whereArgs: [habit.id],
        );
      }
    }
  }

  Future<void> addMemo(Memo memo) async {
    await _db!.insert('memos', memo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteMemo(String id) async {
    await _db!.delete('memos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> exportData() async {
    final data = {
      'habits': (await getHabits()).map((h) => h.toMap()).toList(),
      'checkIns': (await getCheckIns()).map((c) => c.toMap()).toList(),
      'memos': (await getMemos()).map((m) => m.toMap()).toList(),
      'settings': (await getSettings()).toMap(),
    };

    final jsonStr = jsonEncode(data);
    final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonStr));

    final String? savedPath = await FilePicker.platform.saveFile(
      dialogTitle: '导出数据',
      fileName: 'habitquest_backup.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );
    if (savedPath == null) return;
  }

  Future<void> importData(File file) async {
    final jsonStr = await file.readAsString();
    final data = jsonDecode(jsonStr);

    await _db!.transaction((txn) async {
      await txn.delete('habits');
      await txn.delete('check_ins');
      await txn.delete('memos');

      for (final h in data['habits']) {
        final habitMap = Map<String, dynamic>.from(h);
        habitMap.putIfAbsent('is_archived', () => 0);
        await txn.insert('habits', habitMap);
      }
      for (final c in data['checkIns']) {
        await txn.insert('check_ins', Map<String, dynamic>.from(c));
      }
      for (final m in data['memos']) {
        await txn.insert('memos', Map<String, dynamic>.from(m));
      }
      await txn.update('settings', Map<String, dynamic>.from(data['settings']),
          where: 'id = ?', whereArgs: [1]);
    });
  }

  Future<String> getStoragePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
}

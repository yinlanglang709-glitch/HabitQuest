import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F8CFF), Color(0xFF7EDCFF)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xFF4F8CFF)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'HabitQuest',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle_rounded),
            title: const Text('打卡中心'),
            onTap: () {
              state.setActiveTab(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_rounded),
            title: const Text('清单清单'),
            onTap: () {
              state.setActiveTab(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_rounded),
            title: const Text('打卡视图'),
            onTap: () {
              state.setActiveTab(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_fire_department_rounded),
            title: const Text('番茄专注'),
            onTap: () {
              state.setActiveTab(3);
              Navigator.pop(context);
            },
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: const Text('导出记录'),
            onTap: () async {
              await state.db.exportData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('备份文件已保存到文档目录。')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_rounded),
            title: const Text('导入记录'),
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
              if (result?.files.single.path != null) {
                await state.db.importData(File(result!.files.single.path!));
                await state.loadAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('导入成功，数据已更新。')),
                  );
                }
              }
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Built with Passion • v1.2.0',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, letterSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}
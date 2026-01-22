import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/memo.dart';

import 'dart:io';

import 'package:file_picker/file_picker.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)]),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: Color(0xFF2F80ED), size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('打卡达人', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('持续自律，遇见更好的自己', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => state.toggleDarkMode(),
                  icon: Icon(state.settings.isDarkMode ? Icons.sunny : Icons.nightlight_round, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: '快捷入口'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _QuickAction(label: '备忘录', icon: Icons.sticky_note_2_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoPage()))),
              _QuickAction(label: '纪念日', icon: Icons.event_rounded),
              _QuickAction(label: '小组件', icon: Icons.grid_view_rounded),
              _QuickAction(label: '课程表', icon: Icons.menu_book_rounded),
              _QuickAction(label: '自习室', icon: Icons.coffee_rounded),
              _QuickAction(label: '个性化设置', icon: Icons.settings_rounded),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: '设置'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            label: '暗黑模式',
            trailing: Switch(value: state.settings.isDarkMode, onChanged: (_) => state.toggleDarkMode()),
          ),
          _SectionTitle(title: '数据安全'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.folder_open_rounded,
            label: '查看数据存储位置',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final path = await state.db.getStoragePath();
              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('数据存储位置'),
                  content: Text(path),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
                  ],
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.download_rounded,
            label: '导出记录',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              await state.db.exportData();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('备份文件已保存到文档目录。')),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.upload_rounded,
            label: '导入记录',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
              if (result?.files.single.path != null) {
                await state.db.importData(File(result!.files.single.path!));
                await state.loadAll();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('导入成功，数据已更新。')),
                );
              }
            },
          ),
          _SectionTitle(title: '其他'),
          const SizedBox(height: 8),
          _SettingsTile(icon: Icons.notifications_rounded, label: '提醒管理', trailing: const Icon(Icons.chevron_right_rounded)),
          _SettingsTile(icon: Icons.security_rounded, label: '数据安全', trailing: const Icon(Icons.chevron_right_rounded)),
          _SettingsTile(icon: Icons.help_outline_rounded, label: '帮助与反馈', trailing: const Icon(Icons.chevron_right_rounded)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.label, required this.trailing, this.onTap});

  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade500),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 2),
    );
  }
}

class MemoPage extends StatefulWidget {
  const MemoPage({super.key});

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('备忘录')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: '记下你的想法...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) return;
                    final memo = Memo(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      content: controller.text.trim(),
                      createdAt: DateTime.now().toIso8601String(),
                    );
                    context.read<AppState>().addMemo(memo);
                    controller.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.memos.isEmpty
                ? Center(
              child: Text('还没有任何备忘', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              itemCount: state.memos.length,
              itemBuilder: (context, index) {
                final memo = state.memos[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(memo.content, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text(memo.createdAt, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                        onPressed: () => context.read<AppState>().deleteMemo(memo.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
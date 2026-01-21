import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class ChecklistPage extends StatelessWidget {
  const ChecklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pending = state.habits.where((h) => !state.isHabitDoneToday(h.id)).toList();
    final completed = state.habits.where((h) => state.isHabitDoneToday(h.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('清单'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _SectionHeader(title: '待办', count: pending.length),
          const SizedBox(height: 8),
          ...pending.map(
                (h) => Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${h.title}${h.streak}天', style: const TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ),
          if (pending.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('全部完成了！', style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
            ),
          const SizedBox(height: 16),
          _SectionHeader(title: '已打卡', count: completed.length),
          const SizedBox(height: 8),
          ...completed.map(
                (h) => ListTile(
              leading: const Icon(Icons.check_circle_rounded, color: Colors.blue),
              title: Text(
                h.title,
                style: TextStyle(color: Colors.grey.shade500, decoration: TextDecoration.lineThrough),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(width: 6),
        Text('$count', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        const SizedBox(width: 6),
        Icon(Icons.expand_more, size: 16, color: Colors.grey.shade400),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/habit.dart';
import '../widges/add_habit_sheet.dart';
import '../widges/check_in_dialog.dart';
import '../widges/habit_icon.dart';
import '../widges/stats_dialog.dart';

class HabitPage extends StatelessWidget {
  const HabitPage({super.key});

  List<_DateInfo> _buildDateStrip() {
    final today = DateTime.now();
    return List.generate(7, (index) {
      final date = today.subtract(Duration(days: 3 - index));
      return _DateInfo(
        label: ['日', '一', '二', '三', '四', '五', '六'][date.weekday % 7],
        day: date.day,
        isToday: date.day == today.day && date.month == today.month,
      );
    });
  }

  Color _accent(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.redAccent;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.deepOrangeAccent;
      case 'purple':
        return Colors.deepPurpleAccent;
      case 'pink':
        return Colors.pinkAccent;
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dates = _buildDateStrip();
    final habits =
        state.habits.where((habit) => !habit.isArchived).toList();

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('习惯打卡'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_rounded),
            onPressed: () => showDialog(context: context, builder: (_) => const StatsDialog()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddHabitSheet(),
        ),
        label: const Text('新增'),
        icon: const Icon(Icons.add_rounded),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: dates
                    .map(
                      (d) => Column(
                    children: [
                      Text(
                        d.label,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: d.isToday ? Colors.blueAccent : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: d.isToday
                              ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]
                              : [],
                        ),
                        child: Text(
                          d.isToday ? '今' : d.day.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: d.isToday ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: habits.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flash_on_rounded, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text('还没有目标，开始自律人生吧', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  final accent = _accent(habit.color);
                  final done = state.isHabitDoneToday(habit.id);
                  return _HabitCard(
                    habit: habit,
                    accent: accent,
                    done: done,
                    onDelete: () => _showDeleteDialog(context, habit),
                    onTap: () {
                      if (!done) {
                        showDialog(context: context, builder: (_) => CheckInDialog(habit: habit));
                      }
                    },
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: habits.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Habit habit) async {
    bool deleteCheckIns = false;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('删除习惯'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('确定要删除「${habit.title}」吗？'),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: deleteCheckIns,
                  onChanged: (value) =>
                      setState(() => deleteCheckIns = value ?? false),
                  title: const Text('同时删除打卡记录'),
                ),
                if (deleteCheckIns)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '打卡数据不可恢复，请谨慎操作。',
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () {
                  context
                      .read<AppState>()
                      .deleteHabit(habit.id, deleteCheckIns: deleteCheckIns);
                  Navigator.pop(context);
                },
                child: const Text('删除'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.habit,
    required this.accent,
    required this.done,
    required this.onTap,
    required this.onDelete,
  });

  final Habit habit;
  final Color accent;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 10)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              buildHabitIcon(habit.icon, accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done ? Colors.grey : Colors.black87,
                      ),
                    ),
                    if (habit.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(habit.notes, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${habit.streak}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text('DAYS', style: TextStyle(color: Colors.grey.shade400, fontSize: 10, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.grey.shade500,
                tooltip: '删除习惯',
                onPressed: onDelete,
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: done ? Colors.green : Colors.transparent,
                  border: Border.all(color: done ? Colors.green : Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  done ? Icons.check_rounded : Icons.circle_outlined,
                  color: done ? Colors.white : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateInfo {
  final String label;
  final int day;
  final bool isToday;

  _DateInfo({required this.label, required this.day, required this.isToday});
}

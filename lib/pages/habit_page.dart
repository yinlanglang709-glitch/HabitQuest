import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/chech_in.dart';
import '../models/habit.dart';
import '../widges/add_habit_sheet.dart';
import '../widges/check_in_dialog.dart';
import '../widges/habit_icon.dart';
import '../widges/stats_dialog.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  DateTime _anchorDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  List<_DateInfo> _buildDateStrip() {
    return List.generate(7, (index) {
      final date = _anchorDate.subtract(Duration(days: 3 - index));
      return _DateInfo(
        label: ['日', '一', '二', '三', '四', '五', '六'][date.weekday % 7],
        day: date.day,
        isToday: _isSameDay(date, DateTime.now()),
        isSelected: _isSameDay(date, _selectedDate),
        date: date,
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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  void _shiftDateStrip(int days) {
    setState(() {
      final nextAnchor = _anchorDate.add(Duration(days: days));
      final today = DateTime.now();
      if (nextAnchor.isAfter(today)) {
        _anchorDate = DateTime(today.year, today.month, today.day);
      } else {
        _anchorDate = nextAnchor;
      }
      _selectedDate = _anchorDate;
    });
  }

  CheckIn? _checkInForDate(AppState state, Habit habit) {
    final dateStr = _formatDate(_selectedDate);
    try {
      return state.checkIns
          .firstWhere((c) => c.habitId == habit.id && c.date == dateStr);
    } catch (_) {
      return null;
    }
  }

  void _showCheckInDetail(
      BuildContext context, Habit habit, CheckIn? checkIn) {
    final dateLabel = _formatDate(_selectedDate);
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('打卡详情 • $dateLabel'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('习惯：${habit.title}'),
              const SizedBox(height: 8),
              if (checkIn == null)
                const Text('当日未打卡')
              else ...[
                Text('记录时间：${checkIn.timestamp.isEmpty ? '未记录' : checkIn.timestamp}'),
                const SizedBox(height: 6),
                Text('备注：${checkIn.notes.isEmpty ? '无' : checkIn.notes}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
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
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < 0) {
                  _shiftDateStrip(-7);
                } else if (details.primaryVelocity! > 0) {
                  _shiftDateStrip(7);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: dates
                      .map(
                        (d) => InkWell(
                      onTap: () => setState(() => _selectedDate = d.date),
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
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
                              color: d.isSelected
                                  ? Colors.blueAccent
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: d.isSelected
                                  ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]
                                  : [],
                            ),
                            child: Text(
                              d.isToday ? '今' : d.day.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: d.isSelected ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .toList(),
                ),
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
                  final checkIn = _checkInForDate(state, habit);
                  final done = checkIn != null;
                  return _HabitCard(
                    habit: habit,
                    accent: accent,
                    done: done,
                    onDelete: () => _showDeleteDialog(context, habit),
                    onShowDetail: () => _showCheckInDetail(context, habit, checkIn),
                    detailLabel: done
                        ? '已打卡 • ${checkIn!.timestamp.isEmpty ? '未记录时间' : checkIn.timestamp}'
                        : '未打卡',
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
    required this.onShowDetail,
    required this.detailLabel,
  });

  final Habit habit;
  final Color accent;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onShowDetail;
  final String detailLabel;

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
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: onShowDetail,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          detailLabel,
                          style: TextStyle(
                            color: done ? Colors.green.shade600 : Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
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
  final bool isSelected;
  final DateTime date;

  _DateInfo({
    required this.label,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.date,
  });
}

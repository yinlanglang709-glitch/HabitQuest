import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class StatsDialog extends StatelessWidget {
  const StatsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final activeHabits =
        state.habits.where((habit) => !habit.isArchived).toList();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayCheckIns = state.checkIns.where((c) => c.date == today).length;
    final total = state.checkIns.length;
    final best = activeHabits.isEmpty ? 0 : activeHabits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
    final rate = activeHabits.isEmpty ? 0 : (todayCheckIns / activeHabits.length * 100).round();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('打卡统计', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _StatCard(title: '今日完成', value: '$todayCheckIns/${activeHabits.length}', color: Colors.blueAccent, icon: Icons.check_circle_rounded),
                _StatCard(title: '最长连续', value: '$best', color: Colors.orangeAccent, icon: Icons.emoji_events_rounded),
                _StatCard(title: '累计打卡', value: '$total', color: Colors.green, icon: Icons.trending_up_rounded),
                _StatCard(title: '今日进度', value: '$rate%', color: Colors.purpleAccent, icon: Icons.calendar_month_rounded),
              ],
            ),
            const SizedBox(height: 12),
            Text('习惯排行榜', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
            const SizedBox(height: 8),
            ...() {
              final ranked = [...state.habits];
              ranked.removeWhere((habit) => habit.isArchived);
              ranked.sort((a, b) => b.streak.compareTo(a.streak));
              return ranked.take(3).map(
                    (h) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(h.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${h.streak} DAYS', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }(),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.color, required this.icon});

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, letterSpacing: 1.2)),
        ],
      ),
    );
  }
}

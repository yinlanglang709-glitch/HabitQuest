import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/chech_in.dart';
import '../models/habit.dart';

class CheckInDialog extends StatefulWidget {
  const CheckInDialog({super.key, required this.habit});

  final Habit habit;

  @override
  State<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<CheckInDialog> {
  final notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.blueAccent, size: 40),
            ),
            const SizedBox(height: 12),
            const Text('完成打卡', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('记录一下今日的感悟吧 (${widget.habit.title})', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '今天做得怎么样？...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final today = DateTime.now().toIso8601String().split('T')[0];
                      final checkIn = CheckIn(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        habitId: widget.habit.id,
                        date: today,
                        notes: notesController.text.trim(),
                        timestamp: DateTime.now().toIso8601String(),
                      );
                      context.read<AppState>().addCheckIn(checkIn);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                    child: const Text('确认打卡'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
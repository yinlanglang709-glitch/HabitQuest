import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/habit.dart';
import 'habit_icon.dart';

class AddHabitSheet extends StatefulWidget {
  const AddHabitSheet({super.key});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final titleController = TextEditingController();
  final notesController = TextEditingController();
  String selectedIcon = habitIcons.first.key;
  String selectedColor = 'blue';
  String? customPreview;
  bool isValid = false;

  @override
  void initState() {
    super.initState();
    titleController.addListener(_validate);
  }

  @override
  void dispose() {
    titleController.removeListener(_validate);
    titleController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _validate() {
    final valid = titleController.text.trim().isNotEmpty;
    if (valid != isValid) {
      setState(() => isValid = valid);
    }
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

  Future<void> _pickCustomIcon() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result?.files.single.path != null) {
      final bytes = await File(result!.files.single.path!).readAsBytes();
      final base64Str = base64Encode(bytes);
      setState(() {
        selectedIcon = 'custom:$base64Str';
        customPreview = base64Str;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    final themeColor = _accent(selectedColor);
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.6,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('新建目标',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: '目标名称',
                  hintText: '例如：每日阅读30分钟',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: '备注 (目标详情)',
                  hintText: '记录你的目标计划或要求...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('选择图标',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  TextButton.icon(
                    onPressed: _pickCustomIcon,
                    icon: const Icon(Icons.upload_rounded, size: 16),
                    label: const Text('自定义图片'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (customPreview != null)
                    _IconTile(
                      isSelected: selectedIcon.startsWith('custom:'),
                      selectedBorderColor: themeColor,
                      child: buildHabitIcon('custom:$customPreview', themeColor,
                          size: 44),
                      onTap: () => setState(
                          () => selectedIcon = 'custom:$customPreview'),
                    ),
                  ...habitIcons.map((iconData) {
                    final selected = selectedIcon == iconData.key;
                    return _IconTile(
                      isSelected: selected,
                      selectedBorderColor: themeColor,
                      child: Icon(
                        iconData.icon,
                        color: selected ? themeColor : Colors.grey.shade500,
                      ),
                      onTap: () => setState(() => selectedIcon = iconData.key),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
              const Text('主题色',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: [
                  for (final color in [
                    'blue',
                    'red',
                    'green',
                    'orange',
                    'purple',
                    'pink',
                    'indigo',
                    'amber'
                  ])
                    GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _accent(color),
                          shape: BoxShape.circle,
                          border: selectedColor == color
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: selectedColor == color
                              ? [
                                  BoxShadow(
                                      color: _accent(color).withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6))
                                ]
                              : [],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: !isValid
                    ? null
                    : () {
                        final habit = Habit(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          userId: '1',
                          title: titleController.text.trim(),
                          notes: notesController.text.trim(),
                          icon: selectedIcon,
                          color: selectedColor,
                          streak: 0,
                          createdAt: DateTime.now().toIso8601String(),
                        );
                        context.read<AppState>().addHabit(habit);
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('完成创建',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.child,
    required this.onTap,
    required this.isSelected,
    this.selectedBorderColor,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? selectedBorderColor;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? (selectedBorderColor ?? Colors.blueAccent)
        : Colors.grey.shade200;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white, // 方案A：始终白底
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}

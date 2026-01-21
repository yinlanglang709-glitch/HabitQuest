import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class HabitIconData {
  final String key;
  final IconData icon;
  final String label;

  const HabitIconData({required this.key, required this.icon, required this.label});
}

const habitIcons = [
  HabitIconData(key: 'sun', icon: Icons.wb_sunny_rounded, label: '阳光'),
  HabitIconData(key: 'activity', icon: Icons.directions_run_rounded, label: '运动'),
  HabitIconData(key: 'zap', icon: Icons.flash_on_rounded, label: '能量'),
  HabitIconData(key: 'clock', icon: Icons.timer_rounded, label: '时间'),
  HabitIconData(key: 'target', icon: Icons.track_changes_rounded, label: '目标'),
  HabitIconData(key: 'heart', icon: Icons.favorite_rounded, label: '健康'),
  HabitIconData(key: 'book', icon: Icons.menu_book_rounded, label: '阅读'),
  HabitIconData(key: 'coffee', icon: Icons.coffee_rounded, label: '咖啡'),
  HabitIconData(key: 'music', icon: Icons.music_note_rounded, label: '音乐'),
  HabitIconData(key: 'bike', icon: Icons.directions_bike_rounded, label: '骑行'),
  HabitIconData(key: 'camera', icon: Icons.photo_camera_rounded, label: '摄影'),
  HabitIconData(key: 'cloud', icon: Icons.cloud_rounded, label: '冥想'),
  HabitIconData(key: 'code', icon: Icons.code_rounded, label: '编码'),
  HabitIconData(key: 'dumbbell', icon: Icons.fitness_center_rounded, label: '健身'),
  HabitIconData(key: 'flame', icon: Icons.local_fire_department_rounded, label: '热情'),
  HabitIconData(key: 'gift', icon: Icons.card_giftcard_rounded, label: '奖励'),
  HabitIconData(key: 'moon', icon: Icons.nights_stay_rounded, label: '睡眠'),
  HabitIconData(key: 'phone', icon: Icons.phone_android_rounded, label: '手机'),
  HabitIconData(key: 'star', icon: Icons.star_rounded, label: '星标'),
];

HabitIconData fallbackIcon = habitIcons.first;

Widget buildHabitIcon(String iconKey, Color bgColor, {double size = 40}) {
  if (iconKey.startsWith('custom:')) {
    final base64Data = iconKey.split('custom:').last;
    try {
      final Uint8List bytes = base64Decode(base64Data);
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      return _iconContainer(fallbackIcon.icon, bgColor, size);
    }
  }

  final iconData = habitIcons.firstWhere(
        (icon) => icon.key == iconKey,
    orElse: () => fallbackIcon,
  );
  return _iconContainer(iconData.icon, bgColor, size);
}

Widget _iconContainer(IconData icon, Color bgColor, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: bgColor.withOpacity(0.15),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, color: bgColor, size: size * 0.55),
  );
}
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../models/habit.dart'; // 确保导入 Habit 模型

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  String _getMonthName(int month) {
    const List<String> names = [
      '一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'
    ];
    return names[month - 1];
  }

  // 获取该月有多少天
  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  // 辅助函数：格式化日期为 YYYY-MM-DD 字符串，用于和 CheckIn 中的 date 比对
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // 辅助函数：判断两个 DateTime 是否是同一天（忽略时分秒）
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    // 监听状态
    final state = context.watch<AppState>();

    final days = ['一', '二', '三', '四', '五', '六', '日'];
    DateTime _focusedDay = DateTime.now(); // 注意：在 Stateless 中这样写每次 build 都是 now
    final daysInMonth = _getDaysInMonth(_focusedDay);

    // 获取“今天”的 00:00:00 时间点，用于比较
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getMonthName(_focusedDay.month)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. 星期表头
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days
                  .map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                ),
              ))
                  .toList(),
            ),
          ),

          // 2. 日历主体
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // --- 布局计算 ---
                const int rowCount = 5;
                const double spacing = 4.0;
                final totalWidth = constraints.maxWidth;
                final totalHeight = constraints.maxHeight;
                final cellWidth = (totalWidth - (6 * spacing)) / 7;
                final cellHeight = (totalHeight - ((rowCount - 1) * spacing) - 10) / rowCount;
                final childAspectRatio = cellWidth / cellHeight;
                // --- 布局计算结束 ---

                return GridView.builder(
                  padding: const EdgeInsets.all(4),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: childAspectRatio,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                  ),
                  itemCount: daysInMonth,
                  itemBuilder: (context, index) {
                    final day = index + 1;

                    // 计算当前格子的具体日期对象
                    final cellDate = DateTime(_focusedDay.year, _focusedDay.month, day);
                    final isToday = _isSameDay(cellDate, today);

// 判断是否是未来日期
                    final isFuture = cellDate.isAfter(today);

// 准备要显示的习惯列表
                    List<Widget> habitWidgets = [];

                    if (!isFuture) {
                      // 如果是今天或过去
                      final dateStr = _formatDate(cellDate);

                      habitWidgets = state.habits.where((habit) {
                        // 每次都要 parse 一下才能比较
                        final createDateObj = DateTime.parse(habit.createdAt);

                        return createDateObj.isBefore(cellDate) || _isSameDay(createDateObj, cellDate);
                      })
                          .map((habit) {
                        // 【原有的映射逻辑】
                        // 检查该习惯在这一天是否已打卡
                        final isDone = state.checkIns.any((checkIn) =>
                        checkIn.habitId == habit.id && checkIn.date == dateStr
                        );

                        return _buildHabitItem(habit, isDone);
                      })
                          .toList();
                    }
                    // 如果是未来 (else)，habitWidgets 保持为空

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // A. 日期数字
                          Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 2),
                            child: Center(
                              child: Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? Colors.blueAccent
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isToday
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // B. 习惯列表 (支持滚动)
                          Expanded(
                            child: habitWidgets.isEmpty
                                ? const SizedBox()
                                : ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              physics: const BouncingScrollPhysics(),
                              children: habitWidgets,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 抽取出来的构建单个习惯条目的方法
  Widget _buildHabitItem(Habit habit, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        // 已打卡：灰色背景；未打卡：浅蓝背景
        color: isDone ? Colors.grey.shade200 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        habit.title,
        style: TextStyle(
          fontSize: 8,
          // 已打卡：灰色文字+删除线；未打卡：蓝色文字
          color: isDone ? Colors.grey.shade500 : Colors.blue,
          decoration: isDone ? TextDecoration.lineThrough : null,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

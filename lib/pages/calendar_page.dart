import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/habit.dart';
import '../widges/app_drawer.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();

  void _changeMonth(int increment) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + increment);
    });
  }

  String _getMonthName(int month) {
    const names = [
      '一月',
      '二月',
      '三月',
      '四月',
      '五月',
      '六月',
      '七月',
      '八月',
      '九月',
      '十月',
      '十一月',
      '十二月'
    ];
    return names[month - 1];
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final now = DateTime.now();

    final String titleText = (_focusedDay.year == now.year)
        ? _getMonthName(_focusedDay.month)
        : '${_focusedDay.year}年 ${_getMonthName(_focusedDay.month)}';

    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final daysInMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final int firstDayOffset = firstDayOfMonth.weekday - 1;
    final int totalCells = daysInMonth + firstDayOffset;
    final int totalRows = (totalCells / 7).ceil();

    return Scaffold(
      // ---------------------------------------------
      // ✅ 核心修改：直接使用你现有的 AppDrawer 组件
      // ---------------------------------------------
      drawer: const AppDrawer(),

      appBar: AppBar(
        // 这里保留了自定义图标逻辑，点击后会打开上面的 AppDrawer
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: '打开菜单',
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        centerTitle: true,
        title: Text(titleText,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: '回到今天',
            icon: const Icon(Icons.today_rounded),
            onPressed: () => setState(() => _focusedDay = DateTime.now()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildWeekHeader(),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! > 0) _changeMonth(-1);
                if (details.primaryVelocity! < 0) _changeMonth(1);
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double availableHeight = constraints.maxHeight;
                  final double availableWidth = constraints.maxWidth;
                  const double spacing = 4.0;
                  final double cellWidth = (availableWidth - (6 * spacing)) / 7;
                  final double cellHeight =
                      (availableHeight - ((totalRows - 1) * spacing)) /
                          totalRows;
                  final double childAspectRatio = cellWidth / cellHeight;

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: childAspectRatio,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                    ),
                    itemCount: totalCells,
                    itemBuilder: (context, index) {
                      if (index < firstDayOffset) return const SizedBox();
                      final day = index - firstDayOffset + 1;
                      final cellDate =
                          DateTime(_focusedDay.year, _focusedDay.month, day);
                      return _buildDayCell(cellDate, state,
                          isCompact: cellHeight < 60);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... 辅助方法 (_buildWeekHeader, _buildDayCell, _buildHabitItem) 保持不变 ...
  Widget _buildWeekHeader() {
    const days = ['一', '二', '三', '四', '五', '六', '日'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Row(
        children: days
            .map((d) => Expanded(
                  child: Center(
                    child: Text(d,
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDayCell(DateTime date, AppState state,
      {bool isCompact = false}) {
    // 这里只包含结构演示，逻辑同上一版
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = _isSameDay(date, today);
    final isFuture = date.isAfter(today);

    List<Widget> habitWidgets = [];
    if (!isFuture) {
      final dateStr = _formatDate(date);
      habitWidgets = state.habits.where((habit) {
        final createDate = DateTime.tryParse(habit.createdAt) ?? DateTime(2000);
        final createDateZero =
            DateTime(createDate.year, createDate.month, createDate.day);
        return !createDateZero.isAfter(date);
      }).map((habit) {
        final isDone = state.checkIns
            .any((c) => c.habitId == habit.id && c.date == dateStr);
        return _buildHabitItem(habit, isDone);
      }).toList();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: isToday ? Colors.blue.shade200 : Colors.grey.shade200,
            width: isToday ? 1.5 : 1),
        borderRadius: BorderRadius.circular(4),
        color: isToday ? Colors.blue.withOpacity(0.05) : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 2, bottom: 2),
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday ? Colors.blue : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isToday ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            child: habitWidgets.isEmpty
                ? const SizedBox()
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    children: habitWidgets,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitItem(Habit habit, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1.5),
      padding: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 2),
      decoration: BoxDecoration(
        color: isDone ? Colors.grey.shade200 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        habit.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 8,
          height: 1.1,
          color: isDone ? Colors.grey : Colors.blue.shade800,
          decoration: isDone ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}

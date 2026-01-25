import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models/habit.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // 当前聚焦的日期（用于控制日历显示哪个月）
  DateTime _focusedDay = DateTime.now();

  // 切换月份
  void _changeMonth(int increment) {
    setState(() {
      // 这里的逻辑会自动处理年份跨越（比如从12月+1变成明年的1月）
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + increment);
    });
  }

  // 辅助：获取月份名称
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

  // 辅助：格式化日期
  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  // 辅助：判断同一天
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // 1. 获取现实中的当前时间，用于判断是否显示年份
    final now = DateTime.now();

    // 2. 生成标题逻辑：如果是今年，只显示“X月”；如果不是今年，显示“20XX年 X月”
    final String titleText = (_focusedDay.year == now.year)
        ? _getMonthName(_focusedDay.month)
        : '${_focusedDay.year}年 ${_getMonthName(_focusedDay.month)}';

    // 3. 日历计算逻辑
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final daysInMonth =
        DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    // 计算月初的偏移量 (假设周一为第一列: Mon=1 -> offset=0)
    final int firstDayOffset = firstDayOfMonth.weekday - 1;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // 标题居中看起来更像日历应用
        title: Text(
          titleText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // 添加一个回到今天的按钮，方便用户迷路时返回
          IconButton(
            tooltip: '回到今天',
            icon: const Icon(Icons.today_rounded),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 星期表头
          _buildWeekHeader(),

          // 日历主体区域
          Expanded(
            child: GestureDetector(
              // 手势监听：左右滑动切换月份
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                // 速度 > 0 表示向右滑（看以前）
                if (details.primaryVelocity! > 0) {
                  _changeMonth(-1);
                }
                // 速度 < 0 表示向左滑（看未来）
                else if (details.primaryVelocity! < 0) {
                  _changeMonth(1);
                }
              },
              child: Container(
                color: Colors.transparent, // 确保空白区域也能响应点击
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.builder(
                  // 禁止 GridView 自身的滚动，完全依赖外部手势
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 0.65, // 稍微调高一点高度，让列表显示更多内容
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: daysInMonth + firstDayOffset,
                  itemBuilder: (context, index) {
                    // 渲染月初空白
                    if (index < firstDayOffset) return const SizedBox();

                    final day = index - firstDayOffset + 1;
                    final cellDate =
                        DateTime(_focusedDay.year, _focusedDay.month, day);
                    return _buildDayCell(cellDate, state);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeader() {
    const days = ['一', '二', '三', '四', '五', '六', '日'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: days
            .map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDayCell(DateTime date, AppState state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final isToday = _isSameDay(date, today);
    final isFuture = date.isAfter(today);

    // 筛选需要在该日期显示的习惯
    List<Widget> habitWidgets = [];

    if (!isFuture) {
      final dateStr = _formatDate(date);

      habitWidgets = state.habits.where((habit) {
        // 这里的 parse 最好放在 Model 层做缓存，这里演示直接 parse
        final createDate = DateTime.tryParse(habit.createdAt) ?? DateTime(2000);
        // 只有创建日期在当前日期之前（或当天）的习惯才显示
        // 使用 DateTime 比较，忽略时分秒差异最好（这里简化直接比）
        final createDateZero =
            DateTime(createDate.year, createDate.month, createDate.day);
        return !createDateZero.isAfter(date);
      }).map((habit) {
        // 检查是否打卡
        // 注意：请确保你的 checkIns 模型里有 date 字段且格式匹配 YYYY-MM-DD
        final isDone = state.checkIns
            .any((c) => c.habitId == habit.id && c.date == dateStr);
        return _buildHabitItem(habit, isDone);
      }).toList();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isToday ? Colors.blue.shade200 : Colors.grey.shade200,
          width: isToday ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        // 如果是今天，给一个淡淡的背景色
        color: isToday ? Colors.blue.withOpacity(0.05) : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 日期数字
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 2),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday ? Colors.blue : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          // 习惯小条目列表
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
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
      decoration: BoxDecoration(
        color: isDone ? Colors.grey.shade200 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        habit.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 8, // 字体设小一点以适应格子
          color: isDone ? Colors.grey : Colors.blue.shade800,
          decoration: isDone ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}

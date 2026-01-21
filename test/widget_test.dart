// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:habitquest/models/habit.dart';

void main() {
  test('Habit copyWith updates streak', () {
    final habit = Habit(
      id: '1',
      userId: 'u1',
      title: 'Read',
      notes: '',
      icon: 'book',
      color: 'blue',
      streak: 2,
      createdAt: '2026-01-01',
    );

    final updated = habit.copyWith(streak: 3);

    expect(updated.streak, 3);
    expect(updated.title, habit.title);
  });
}

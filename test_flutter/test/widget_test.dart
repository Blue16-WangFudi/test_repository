import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_vue/main.dart';

void main() {
  testWidgets('adds a todo item', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.text('Todo List'), findsOneWidget);
    expect(find.text('Buy milk'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Buy milk');
    await tester.tap(find.text('添加'));
    await tester.pump();

    expect(find.text('Buy milk'), findsOneWidget);
  });
}

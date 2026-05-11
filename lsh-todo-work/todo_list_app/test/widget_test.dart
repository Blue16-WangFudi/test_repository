import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list_app/main.dart';
import 'package:todo_list_app/todo_controller.dart';

void main() {
  testWidgets('shows an empty todo list', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.text('Todo List'), findsOneWidget);
    expect(find.text('No todos yet'), findsOneWidget);
    expect(find.text('Add your first task to get started.'), findsOneWidget);
  });

  testWidgets('adds a todo from the input field', (WidgetTester tester) async {
    final controller = TodoListController();
    await tester.pumpWidget(TodoApp(controller: controller));

    await tester.enterText(find.byKey(const Key('todo-input')), 'Buy milk');
    await tester.tap(find.byKey(const Key('add-todo-button')));
    await tester.pump();

    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('No todos yet'), findsNothing);
    expect(controller.totalCount, 1);
    expect(controller.activeCount, 1);
  });

  testWidgets('toggles a todo as completed', (WidgetTester tester) async {
    final controller = TodoListController()..add('Write widget tests');
    await tester.pumpWidget(TodoApp(controller: controller));

    await tester.tap(find.byKey(const Key('todo-checkbox-1')));
    await tester.pump();

    final checkbox = tester.widget<Checkbox>(
      find.byKey(const Key('todo-checkbox-1')),
    );
    expect(checkbox.value, isTrue);
    expect(controller.completedCount, 1);
  });

  testWidgets('deletes a todo item', (WidgetTester tester) async {
    final controller = TodoListController()..add('Remove me');
    await tester.pumpWidget(TodoApp(controller: controller));

    await tester.tap(find.byKey(const Key('delete-todo-1')));
    await tester.pump();

    expect(find.text('Remove me'), findsNothing);
    expect(find.text('No todos yet'), findsOneWidget);
    expect(controller.totalCount, 0);
  });
}

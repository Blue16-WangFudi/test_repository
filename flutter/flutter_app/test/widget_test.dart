import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/todo_app.dart';
import 'package:flutter_app/todo_models.dart';
import 'package:flutter_app/todo_repository.dart';

void main() {
  testWidgets('creates, toggles, edits, deletes, and filters todos', (
    WidgetTester tester,
  ) async {
    final repository = FakeTodoRepository();

    await tester.pumpWidget(TodoApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Write Flutter test');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Write Flutter test'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(repository.todos.single.completed, isTrue);

    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Todo title'),
      'Write widget test',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Write widget test'), findsOneWidget);

    await tester.tap(find.text('Active').last);
    await tester.pumpAndSettle();
    expect(find.text('No todos in this view.'), findsOneWidget);

    await tester.tap(find.text('Completed').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(repository.todos, isEmpty);
  });
}

class FakeTodoRepository implements TodoRepository {
  final List<Todo> todos = <Todo>[];

  @override
  Future<TodoSnapshot> list(TodoFilter filter) async {
    final filtered = todos.where((todo) {
      return switch (filter) {
        TodoFilter.active => !todo.completed,
        TodoFilter.completed => todo.completed,
        TodoFilter.all => true,
      };
    }).toList();
    final completed = todos.where((todo) => todo.completed).length;

    return TodoSnapshot(
      todos: filtered,
      stats: TodoStats(
        total: todos.length,
        active: todos.length - completed,
        completed: completed,
      ),
    );
  }

  @override
  Future<Todo> create(String title) async {
    final now = DateTime.utc(2026, 5, 8);
    final todo = Todo(
      id: '${todos.length + 1}',
      title: title.trim(),
      completed: false,
      createdAt: now,
      updatedAt: now,
    );
    todos.add(todo);
    return todo;
  }

  @override
  Future<Todo> update(String id, {String? title, bool? completed}) async {
    final index = todos.indexWhere((todo) => todo.id == id);
    final existing = todos[index];
    final updated = Todo(
      id: existing.id,
      title: title ?? existing.title,
      completed: completed ?? existing.completed,
      createdAt: existing.createdAt,
      updatedAt: DateTime.utc(2026, 5, 8, 1),
    );
    todos[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    todos.removeWhere((todo) => todo.id == id);
  }
}

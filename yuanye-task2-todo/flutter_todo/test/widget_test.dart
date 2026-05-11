import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/todo.dart';
import 'package:flutter_todo/todo_app.dart';
import 'package:flutter_todo/todo_repository.dart';

void main() {
  testWidgets('shows, adds, toggles, and deletes todos', (tester) async {
    final repository = FakeTodoRepository([
      const Todo(id: 1, title: '学习 Flutter', completed: false),
      const Todo(id: 2, title: '编写测试', completed: true),
    ]);

    await tester.pumpWidget(TodoApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Todo List'), findsOneWidget);
    expect(find.text('学习 Flutter'), findsOneWidget);
    expect(find.text('编写测试'), findsOneWidget);
    expect(
      tester.widget<Checkbox>(find.byKey(const Key('todoCheckbox-2'))).value,
      isTrue,
    );

    await tester.enterText(find.byKey(const Key('todoInput')), '连接后端');
    await tester.tap(find.byKey(const Key('addTodoButton')));
    await tester.pumpAndSettle();

    expect(find.text('连接后端'), findsOneWidget);
    expect(repository.todos.length, 3);

    await tester.tap(find.byKey(const Key('todoCheckbox-1')));
    await tester.pumpAndSettle();

    expect(repository.todos.first.completed, isTrue);
    expect(
      tester.widget<Checkbox>(find.byKey(const Key('todoCheckbox-1'))).value,
      isTrue,
    );

    await tester.tap(find.byKey(const Key('deleteTodo-2')));
    await tester.pumpAndSettle();

    expect(find.text('编写测试'), findsNothing);
    expect(repository.todos.map((todo) => todo.id), isNot(contains(2)));
  });

  testWidgets('validates empty todo title', (tester) async {
    await tester.pumpWidget(TodoApp(repository: FakeTodoRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('addTodoButton')));
    await tester.pumpAndSettle();

    expect(find.text('请输入 Todo 内容'), findsOneWidget);
  });
}

class FakeTodoRepository implements TodoRepository {
  FakeTodoRepository([List<Todo>? initialTodos]) : todos = initialTodos ?? [];

  final List<Todo> todos;
  var _nextId = 100;

  @override
  Future<List<Todo>> fetchTodos() async => List.of(todos);

  @override
  Future<Todo> addTodo(String title) async {
    final todo = Todo(id: _nextId++, title: title, completed: false);
    todos.add(todo);
    return todo;
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    final index = todos.indexWhere((item) => item.id == todo.id);
    todos[index] = todo;
    return todo;
  }

  @override
  Future<void> deleteTodo(int id) async {
    todos.removeWhere((todo) => todo.id == id);
  }
}

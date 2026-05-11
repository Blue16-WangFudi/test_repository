import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/todo.dart';
import 'package:flutter_todo/todo_app.dart';
import 'package:flutter_todo/todo_repository.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('todo flow works in the app shell', (tester) async {
    final repository = InMemoryTodoRepository();

    await tester.pumpWidget(TodoApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('暂无 Todo'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('todoInput')), '集成测试 Todo');
    await tester.tap(find.byKey(const Key('addTodoButton')));
    await tester.pumpAndSettle();

    expect(find.text('集成测试 Todo'), findsOneWidget);

    await tester.tap(find.byKey(const Key('todoCheckbox-1')));
    await tester.pumpAndSettle();
    expect(repository.todos.single.completed, isTrue);

    await tester.tap(find.byKey(const Key('deleteTodo-1')));
    await tester.pumpAndSettle();
    expect(find.text('暂无 Todo'), findsOneWidget);
  });
}

class InMemoryTodoRepository implements TodoRepository {
  final todos = <Todo>[];
  var _nextId = 1;

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

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/todo_controller.dart';
import 'package:flutter_app/todo_models.dart';
import 'package:flutter_app/todo_repository.dart';

void main() {
  test('loads, creates, toggles, renames, and deletes todos', () async {
    final repository = MemoryTodoRepository();
    final controller = TodoController(repository);

    await controller.load();
    expect(controller.snapshot.stats.total, 0);

    await controller.create('Write controller test');
    expect(controller.snapshot.todos.single.title, 'Write controller test');
    expect(controller.snapshot.stats.active, 1);

    await controller.toggle(controller.snapshot.todos.single);
    expect(controller.snapshot.stats.completed, 1);

    await controller.rename(controller.snapshot.todos.single, 'Update controller test');
    expect(controller.snapshot.todos.single.title, 'Update controller test');

    await controller.delete(controller.snapshot.todos.single);
    expect(controller.snapshot.todos, isEmpty);
  });
}

class MemoryTodoRepository implements TodoRepository {
  final List<Todo> todos = <Todo>[];

  @override
  Future<TodoSnapshot> list(TodoFilter filter) async {
    final completed = todos.where((todo) => todo.completed).length;
    return TodoSnapshot(
      todos: todos,
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
      title: title,
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
    final todo = todos[index];
    final updated = Todo(
      id: todo.id,
      title: title ?? todo.title,
      completed: completed ?? todo.completed,
      createdAt: todo.createdAt,
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

import 'todo.dart';

abstract class TodoRepository {
  Future<List<Todo>> fetchTodos();

  Future<Todo> addTodo(String title);

  Future<Todo> updateTodo(Todo todo);

  Future<void> deleteTodo(int id);
}

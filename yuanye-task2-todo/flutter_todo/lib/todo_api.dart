import 'dart:convert';

import 'package:http/http.dart' as http;

import 'todo.dart';
import 'todo_repository.dart';

class TodoApiException implements Exception {
  const TodoApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class HttpTodoRepository implements TodoRepository {
  HttpTodoRepository({required this.baseUrl, required this.client});

  final Uri baseUrl;
  final http.Client client;

  @override
  Future<List<Todo>> fetchTodos() async {
    final response = await client.get(baseUrl);
    _ensureSuccess(response, '加载 Todo 失败');

    final decoded = jsonDecode(response.body);
    final items = decoded is List ? decoded : decoded['data'] as List<dynamic>;
    return items
        .map((item) => Todo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Todo> addTodo(String title) async {
    final response = await client.post(
      baseUrl,
      headers: _jsonHeaders,
      body: jsonEncode({'title': title, 'completed': false}),
    );
    _ensureSuccess(response, '新增 Todo 失败');

    return Todo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    final response = await client.put(
      baseUrl.resolve('${baseUrl.path.endsWith('/') ? '' : '/'}${todo.id}'),
      headers: _jsonHeaders,
      body: jsonEncode(todo.toJson()),
    );
    _ensureSuccess(response, '更新 Todo 失败');

    return Todo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTodo(int id) async {
    final response = await client.delete(
      baseUrl.resolve('${baseUrl.path.endsWith('/') ? '' : '/'}$id'),
    );
    _ensureSuccess(response, '删除 Todo 失败');
  }

  static const _jsonHeaders = {'Content-Type': 'application/json'};

  static void _ensureSuccess(http.Response response, String fallbackMessage) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw TodoApiException('$fallbackMessage：HTTP ${response.statusCode}');
  }
}

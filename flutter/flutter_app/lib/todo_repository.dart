import 'dart:convert';

import 'package:http/http.dart' as http;

import 'todo_models.dart';

abstract class TodoRepository {
  Future<TodoSnapshot> list(TodoFilter filter);

  Future<Todo> create(String title);

  Future<Todo> update(
    String id, {
    String? title,
    bool? completed,
  });

  Future<void> delete(String id);
}

class TodoApiException implements Exception {
  const TodoApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class HttpTodoRepository implements TodoRepository {
  HttpTodoRepository({
    required this.baseUrl,
    required this.client,
  });

  final String baseUrl;
  final http.Client client;

  @override
  Future<TodoSnapshot> list(TodoFilter filter) async {
    final response = await client.get(
      _uri('/api/todos', <String, String>{'filter': filter.queryValue}),
    );
    return TodoSnapshot.fromJson(_decodeJson(response));
  }

  @override
  Future<Todo> create(String title) async {
    final response = await client.post(
      _uri('/api/todos'),
      headers: _jsonHeaders,
      body: jsonEncode(<String, Object?>{'title': title}),
    );
    return Todo.fromJson(_decodeJson(response));
  }

  @override
  Future<Todo> update(
    String id, {
    String? title,
    bool? completed,
  }) async {
    final payload = <String, Object?>{};

    if (title != null) {
      payload['title'] = title;
    }

    if (completed != null) {
      payload['completed'] = completed;
    }

    final response = await client.put(
      _uri('/api/todos/$id'),
      headers: _jsonHeaders,
      body: jsonEncode(payload),
    );
    return Todo.fromJson(_decodeJson(response));
  }

  @override
  Future<void> delete(String id) async {
    final response = await client.delete(_uri('/api/todos/$id'));

    if (response.statusCode != 204) {
      _decodeJson(response);
    }
  }

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalizedBaseUrl$path').replace(
      queryParameters: queryParameters,
    );
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TodoApiException(decoded['error'] as String? ?? 'Todo request failed');
    }

    return decoded;
  }
}

const _jsonHeaders = <String, String>{
  'Content-Type': 'application/json',
};

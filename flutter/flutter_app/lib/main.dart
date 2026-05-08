import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'todo_app.dart';
import 'todo_repository.dart';

void main() {
  const apiBaseUrl = String.fromEnvironment(
    'TODO_API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  runApp(
    TodoApp(
      repository: HttpTodoRepository(
        baseUrl: apiBaseUrl,
        client: http.Client(),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'todo_api.dart';
import 'todo_app.dart';

void main() {
  runApp(
    TodoApp(
      repository: HttpTodoRepository(
        baseUrl: Uri.parse('http://localhost:8080/api/todos'),
        client: http.Client(),
      ),
    ),
  );
}

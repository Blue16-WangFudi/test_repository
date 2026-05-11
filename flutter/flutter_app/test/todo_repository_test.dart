import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_app/todo_models.dart';
import 'package:flutter_app/todo_repository.dart';

void main() {
  test('lists todos through the Spring Boot API', () async {
    final repository = HttpTodoRepository(
      baseUrl: 'http://localhost:8080',
      client: MockClient((request) async {
        expect(request.url.toString(), 'http://localhost:8080/api/todos?filter=active');
        return http.Response(
          '''
          {
            "todos": [
              {
                "id": "1",
                "title": "Call Spring Boot",
                "completed": false,
                "createdAt": "2026-05-08T00:00:00Z",
                "updatedAt": "2026-05-08T00:00:00Z"
              }
            ],
            "stats": { "total": 1, "active": 1, "completed": 0 }
          }
          ''',
          200,
        );
      }),
    );

    final snapshot = await repository.list(TodoFilter.active);
    expect(snapshot.todos.single.title, 'Call Spring Boot');
  });

  test('throws API errors returned by the backend', () async {
    final repository = HttpTodoRepository(
      baseUrl: 'http://localhost:8080',
      client: MockClient((request) async {
        return http.Response('{"error":"Todo title is required"}', 400);
      }),
    );

    expect(
      () => repository.create(' '),
      throwsA(isA<TodoApiException>()),
    );
  });
}

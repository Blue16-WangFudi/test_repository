import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/todo_models.dart';

void main() {
  test('parses todo snapshot json', () {
    final snapshot = TodoSnapshot.fromJson({
      'todos': [
        {
          'id': '1',
          'title': 'Read API response',
          'completed': false,
          'createdAt': '2026-05-08T00:00:00Z',
          'updatedAt': '2026-05-08T00:00:00Z',
        },
      ],
      'stats': {
        'total': 1,
        'active': 1,
        'completed': 0,
      },
    });

    expect(snapshot.todos.single.title, 'Read API response');
    expect(snapshot.stats.active, 1);
  });
}

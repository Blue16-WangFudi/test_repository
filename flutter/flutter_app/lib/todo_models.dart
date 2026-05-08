enum TodoFilter {
  all,
  active,
  completed;

  String get queryValue => switch (this) {
        TodoFilter.all => 'all',
        TodoFilter.active => 'active',
        TodoFilter.completed => 'completed',
      };

  String get label => switch (this) {
        TodoFilter.all => 'All',
        TodoFilter.active => 'Active',
        TodoFilter.completed => 'Completed',
      };
}

class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      completed: json['completed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String title;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class TodoStats {
  const TodoStats({
    required this.total,
    required this.active,
    required this.completed,
  });

  factory TodoStats.fromJson(Map<String, dynamic> json) {
    return TodoStats(
      total: json['total'] as int,
      active: json['active'] as int,
      completed: json['completed'] as int,
    );
  }

  final int total;
  final int active;
  final int completed;
}

class TodoSnapshot {
  const TodoSnapshot({
    required this.todos,
    required this.stats,
  });

  factory TodoSnapshot.empty() {
    return const TodoSnapshot(
      todos: <Todo>[],
      stats: TodoStats(total: 0, active: 0, completed: 0),
    );
  }

  factory TodoSnapshot.fromJson(Map<String, dynamic> json) {
    final todosJson = json['todos'] as List<dynamic>;

    return TodoSnapshot(
      todos: todosJson
          .map((item) => Todo.fromJson(item as Map<String, dynamic>))
          .toList(),
      stats: TodoStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }

  final List<Todo> todos;
  final TodoStats stats;
}

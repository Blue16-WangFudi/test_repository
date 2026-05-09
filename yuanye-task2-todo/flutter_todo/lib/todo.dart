class Todo {
  const Todo({required this.id, required this.title, required this.completed});

  final int id;
  final String title;
  final bool completed;

  Todo copyWith({int? id, String? title, bool? completed}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      completed: json['completed'] == true || json['done'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'completed': completed};
  }

  Map<String, dynamic> toCreateJson() {
    return {'title': title, 'completed': completed};
  }
}

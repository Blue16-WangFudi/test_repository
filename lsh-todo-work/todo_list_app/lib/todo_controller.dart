import 'dart:collection';

import 'package:flutter/foundation.dart';

@immutable
class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final int id;
  final String title;
  final bool isCompleted;

  TodoItem copyWith({int? id, String? title, bool? isCompleted}) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TodoListController extends ChangeNotifier {
  final List<TodoItem> _items = <TodoItem>[];
  int _nextId = 1;

  UnmodifiableListView<TodoItem> get items => UnmodifiableListView(_items);

  int get totalCount => _items.length;
  int get completedCount => _items.where((item) => item.isCompleted).length;
  int get activeCount => totalCount - completedCount;
  bool get isEmpty => _items.isEmpty;

  TodoItem? add(String rawTitle) {
    final title = rawTitle.trim();
    if (title.isEmpty) {
      return null;
    }

    final item = TodoItem(id: _nextId++, title: title);
    _items.insert(0, item);
    notifyListeners();
    return item;
  }

  void toggle(int id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    _items[index] = _items[index].copyWith(
      isCompleted: !_items[index].isCompleted,
    );
    notifyListeners();
  }

  void remove(int id) {
    final removedCount = _items.length;
    _items.removeWhere((item) => item.id == id);
    if (_items.length != removedCount) {
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';

import 'todo_models.dart';
import 'todo_repository.dart';

class TodoController extends ChangeNotifier {
  TodoController(this.repository);

  final TodoRepository repository;

  TodoSnapshot snapshot = TodoSnapshot.empty();
  TodoFilter filter = TodoFilter.all;
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      snapshot = await repository.list(filter);
    } catch (exception) {
      error = exception.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setFilter(TodoFilter nextFilter) async {
    filter = nextFilter;
    await load();
  }

  Future<void> create(String title) async {
    await _mutate(() async {
      await repository.create(title);
    });
  }

  Future<void> toggle(Todo todo) async {
    await _mutate(() async {
      await repository.update(todo.id, completed: !todo.completed);
    });
  }

  Future<void> rename(Todo todo, String title) async {
    await _mutate(() async {
      await repository.update(todo.id, title: title);
    });
  }

  Future<void> delete(Todo todo) async {
    await _mutate(() => repository.delete(todo.id));
  }

  Future<void> _mutate(Future<void> Function() mutation) async {
    error = null;
    notifyListeners();

    try {
      await mutation();
      await load();
    } catch (exception) {
      error = exception.toString();
      notifyListeners();
    }
  }
}

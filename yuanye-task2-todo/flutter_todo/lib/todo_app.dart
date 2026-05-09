import 'package:flutter/material.dart';

import 'todo.dart';
import 'todo_repository.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key, required this.repository});

  final TodoRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: TodoListPage(repository: repository),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key, required this.repository});

  final TodoRepository repository;

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _todos = <Todo>[];
  var _loading = true;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final todos = await widget.repository.fetchTodos();
      if (!mounted) return;
      setState(() {
        _todos = todos;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _addTodo() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _controller.text.trim();
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final todo = await widget.repository.addTodo(title);
      if (!mounted) return;
      setState(() {
        _todos = [..._todos, todo];
        _saving = false;
      });
      _controller.clear();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _saving = false;
      });
    }
  }

  Future<void> _toggleTodo(Todo todo) async {
    final index = _todos.indexWhere((item) => item.id == todo.id);
    if (index == -1) return;

    final updated = todo.copyWith(completed: !todo.completed);
    setState(() {
      _todos = [..._todos.take(index), updated, ..._todos.skip(index + 1)];
      _error = null;
    });

    try {
      final saved = await widget.repository.updateTodo(updated);
      if (!mounted) return;
      setState(() {
        _todos = [..._todos.take(index), saved, ..._todos.skip(index + 1)];
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _todos = [..._todos.take(index), todo, ..._todos.skip(index + 1)];
        _error = error.toString();
      });
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    final previous = _todos;
    setState(() {
      _todos = _todos.where((item) => item.id != todo.id).toList();
      _error = null;
    });

    try {
      await widget.repository.deleteTodo(todo.id);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _todos = previous;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            key: const Key('refreshTodosButton'),
            tooltip: '刷新',
            onPressed: _loading ? null : _loadTodos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: const Key('todoInput'),
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '新增 Todo',
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _saving ? null : _addTodo(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '请输入 Todo 内容';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      key: const Key('addTodoButton'),
                      onPressed: _saving ? null : _addTodo,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: const Text('新增'),
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: MaterialBanner(
                  content: Text(_error!),
                  leading: const Icon(Icons.error_outline),
                  actions: [
                    TextButton(
                      onPressed: () => setState(() => _error = null),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              ),
            Expanded(child: _buildTodoList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_todos.isEmpty) {
      return const Center(child: Text('暂无 Todo'));
    }

    return ListView.separated(
      key: const Key('todoList'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _todos.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final todo = _todos[index];
        return ListTile(
          key: Key('todoItem-${todo.id}'),
          leading: Checkbox(
            key: Key('todoCheckbox-${todo.id}'),
            value: todo.completed,
            onChanged: (_) => _toggleTodo(todo),
          ),
          title: Text(
            todo.title,
            style: todo.completed
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
          trailing: IconButton(
            key: Key('deleteTodo-${todo.id}'),
            tooltip: '删除',
            onPressed: () => _deleteTodo(todo),
            icon: const Icon(Icons.delete_outline),
          ),
        );
      },
    );
  }
}

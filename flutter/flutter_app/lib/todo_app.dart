import 'package:flutter/material.dart';

import 'todo_controller.dart';
import 'todo_models.dart';
import 'todo_repository.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({
    required this.repository,
    super.key,
  });

  final TodoRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: TodoHomePage(repository: repository),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({
    required this.repository,
    super.key,
  });

  final TodoRepository repository;

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  late final TodoController controller;
  final titleController = TextEditingController();
  final editController = TextEditingController();
  String? editingId;

  @override
  void initState() {
    super.initState();
    controller = TodoController(widget.repository)..addListener(_onChanged);
    controller.load();
  }

  @override
  void dispose() {
    controller.removeListener(_onChanged);
    titleController.dispose();
    editController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _createTodo() async {
    final title = titleController.text;
    titleController.clear();
    await controller.create(title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatsRow(stats: controller.snapshot.stats),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Add a todo',
                    ),
                    onSubmitted: (_) => _createTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _createTodo,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<TodoFilter>(
              segments: TodoFilter.values
                  .map(
                    (filter) => ButtonSegment<TodoFilter>(
                      value: filter,
                      label: Text(filter.label),
                    ),
                  )
                  .toList(),
              selected: {controller.filter},
              onSelectionChanged: (selection) {
                controller.setFilter(selection.first);
              },
            ),
            if (controller.error != null) ...[
              const SizedBox(height: 12),
              Text(
                controller.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            if (controller.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (controller.snapshot.todos.isEmpty)
              const Text('No todos in this view.')
            else
              ...controller.snapshot.todos.map(_buildTodoTile),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoTile(Todo todo) {
    final isEditing = editingId == todo.id;

    if (isEditing) {
      return Card(
        child: ListTile(
          title: TextField(
            controller: editController,
            decoration: const InputDecoration(labelText: 'Todo title'),
            autofocus: true,
          ),
          trailing: Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    editingId = null;
                  });
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  await controller.rename(todo, editController.text);
                  setState(() {
                    editingId = null;
                  });
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: CheckboxListTile(
        value: todo.completed,
        title: Text(
          todo.title,
          style: todo.completed
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        onChanged: (_) => controller.toggle(todo),
        secondary: Wrap(
          spacing: 4,
          children: [
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  editingId = todo.id;
                  editController.text = todo.title;
                });
              },
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete),
              onPressed: () => controller.delete(todo),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final TodoStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(label: 'Total', value: stats.total),
        _Stat(label: 'Active', value: stats.active),
        _Stat(label: 'Completed', value: stats.completed),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(label),
              Text(
                '$value',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

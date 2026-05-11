import 'package:flutter/material.dart';

import 'todo_controller.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key, TodoListController? controller})
    : _controller = controller;

  final TodoListController? _controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        useMaterial3: true,
      ),
      home: TodoHomePage(controller: _controller ?? TodoListController()),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key, required this.controller});

  final TodoListController controller;

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTodosChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTodosChanged);
    _textController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _onTodosChanged() {
    setState(() {});
  }

  void _addTodo() {
    final item = widget.controller.add(_textController.text);
    if (item == null) {
      return;
    }

    _textController.clear();
    _inputFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TodoComposer(
                    controller: _textController,
                    focusNode: _inputFocusNode,
                    onSubmit: _addTodo,
                  ),
                  const SizedBox(height: 16),
                  _TodoSummary(
                    totalCount: widget.controller.totalCount,
                    activeCount: widget.controller.activeCount,
                    completedCount: widget.controller.completedCount,
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _TodoList(controller: widget.controller)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TodoComposer extends StatelessWidget {
  const _TodoComposer({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            key: const Key('todo-input'),
            controller: controller,
            focusNode: focusNode,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'New todo',
              hintText: 'Add a task',
            ),
            onSubmitted: (_) => onSubmit(),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 56,
          child: FilledButton.icon(
            key: const Key('add-todo-button'),
            onPressed: onSubmit,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ),
      ],
    );
  }
}

class _TodoSummary extends StatelessWidget {
  const _TodoSummary({
    required this.totalCount,
    required this.activeCount,
    required this.completedCount,
  });

  final int totalCount;
  final int activeCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        _SummaryItem(label: 'Total', value: totalCount, textTheme: textTheme),
        const SizedBox(width: 8),
        _SummaryItem(label: 'Active', value: activeCount, textTheme: textTheme),
        const SizedBox(width: 8),
        _SummaryItem(
          label: 'Done',
          value: completedCount,
          textTheme: textTheme,
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final String label;
  final int value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.labelMedium),
              const SizedBox(height: 2),
              Text(
                '$value',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodoList extends StatelessWidget {
  const _TodoList({required this.controller});

  final TodoListController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      itemCount: controller.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = controller.items[index];
        return _TodoTile(
          item: item,
          onChanged: () => controller.toggle(item.id),
          onDelete: () => controller.remove(item.id),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'No todos yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Add your first task to get started.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });

  final TodoItem item;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        key: Key('todo-${item.id}'),
        leading: Checkbox(
          key: Key('todo-checkbox-${item.id}'),
          value: item.isCompleted,
          onChanged: (_) => onChanged(),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            color: item.isCompleted ? colorScheme.outline : null,
          ),
        ),
        trailing: IconButton(
          key: Key('delete-todo-${item.id}'),
          tooltip: 'Delete ${item.title}',
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

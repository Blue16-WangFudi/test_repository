import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class Todo {
  Todo({required this.title, this.completed = false});

  final String title;
  bool completed;
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController controller = TextEditingController();

  final List<Todo> todos = [];

  void addTodo() {
    final title = controller.text.trim();

    if (title.isEmpty) return;

    setState(() {
      todos.add(Todo(title: title));
      controller.clear();
    });
  }

  void toggleTodo(int index) {
    setState(() {
      todos[index].completed = !todos[index].completed;
    });
  }

  void deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: '输入 Todo',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => addTodo(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: addTodo,
                  child: const Text('添加'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: todos.isEmpty
                  ? const Center(child: Text('暂无 Todo'))
                  : ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];

                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: todo.completed,
                              onChanged: (_) => toggleTodo(index),
                            ),
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                decoration: todo.completed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteTodo(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
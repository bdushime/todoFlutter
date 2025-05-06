// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/todo.dart';
import 'todo_detail_screen.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> _todos = [];
  String _filter = 'All'; // 'All', 'Completed', 'Pending'

  @override
  void initState() {
    super.initState();
    // Add some sample todos for demonstration
    _todos = [
      Todo(
        id: '1',
        title: 'Learn Flutter',
        description: 'Study widgets, state management, and more',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Todo(
        id: '2',
        title: 'Build Todo App',
        description: 'Create a beautiful and functional todo app',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  List<Todo> get _filteredTodos {
    switch (_filter) {
      case 'Completed':
        return _todos.where((todo) => todo.isCompleted).toList();
      case 'Pending':
        return _todos.where((todo) => !todo.isCompleted).toList();
      case 'All':
      default:
        return _todos;
    }
  }

  void _addTodo(String title, String? description) {
    setState(() {
      _todos.add(
        Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          description: description,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  void _toggleTodoCompletion(String id) {
    setState(() {
      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        _todos[todoIndex].isCompleted = !_todos[todoIndex].isCompleted;
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
  }

  void _showAddTodoDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Todo'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter todo title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter todo description',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _addTodo(
                  titleController.text,
                  descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _navigateToTodoDetails(Todo todo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TodoDetailScreen(
          todo: todo,
          onTodoUpdated: (updatedTodo) {
            setState(() {
              final index = _todos.indexWhere((t) => t.id == updatedTodo.id);
              if (index != -1) {
                _todos[index] = updatedTodo;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckMe'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'All',
                child: Text('All'),
              ),
              const PopupMenuItem(
                value: 'Completed',
                child: Text('Completed'),
              ),
              const PopupMenuItem(
                value: 'Pending',
                child: Text('Pending'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // User welcome section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(widget.user.avatar),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${widget.user.name}!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You have ${_todos.where((todo) => !todo.isCompleted).length} pending tasks',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filter == 'All',
                  onSelected: (selected) {
                    setState(() {
                      _filter = 'All';
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _filter == 'Pending',
                  onSelected: (selected) {
                    setState(() {
                      _filter = 'Pending';
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Completed'),
                  selected: _filter == 'Completed',
                  onSelected: (selected) {
                    setState(() {
                      _filter = 'Completed';
                    });
                  },
                ),
              ],
            ),
          ),

          // Todo list
          Expanded(
            child: _filteredTodos.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 70,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _filter == 'All'
                        ? 'No todos yet. Add your first one!'
                        : 'No ${_filter.toLowerCase()} todos.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = _filteredTodos[index];
                return Dismissible(
                  key: Key(todo.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteTodo(todo.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${todo.title} deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            setState(() {
                              _todos.insert(index, todo);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 1.0,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      leading: Checkbox(
                        value: todo.isCompleted,
                        onChanged: (bool? value) {
                          _toggleTodoCompletion(todo.id);
                        },
                        shape: const CircleBorder(),
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.isCompleted
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      subtitle: todo.description != null
                          ? Text(
                        todo.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: todo.isCompleted
                              ? Colors.grey
                              : Colors.grey[700],
                        ),
                      )
                          : null,
                      onTap: () => _navigateToTodoDetails(todo),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
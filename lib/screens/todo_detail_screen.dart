// lib/screens/todo_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TodoDetailScreen extends StatefulWidget {
  final Todo todo;
  final Function(Todo) onTodoUpdated;

  const TodoDetailScreen({
    Key? key,
    required this.todo,
    required this.onTodoUpdated,
  }) : super(key: key);

  @override
  _TodoDetailScreenState createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isCompleted;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description ?? '');
    _isCompleted = widget.todo.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Save changes when exiting edit mode
        final updatedTodo = Todo(
          id: widget.todo.id,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          isCompleted: _isCompleted,
          createdAt: widget.todo.createdAt,
        );
        widget.onTodoUpdated(updatedTodo);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Section
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      _isCompleted ? Icons.check_circle : Icons.schedule,
                      color: _isCompleted ? Colors.green : Colors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _isCompleted ? 'Completed' : 'Pending',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isCompleted ? Colors.green : Colors.orange,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isCompleted,
                      onChanged: _isEditing
                          ? (value) {
                        setState(() {
                          _isCompleted = value;
                        });
                      }
                          : null,
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title Section
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _isEditing
                ? TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter todo title',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            )
                : Text(
              _titleController.text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Description Section
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _isEditing
                ? TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter todo description (optional)',
              ),
              maxLines: 5,
            )
                : Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _descriptionController.text.isEmpty
                    ? 'No description'
                    : _descriptionController.text,
                style: TextStyle(
                  fontSize: 16,
                  color: _descriptionController.text.isEmpty
                      ? Colors.grey
                      : Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Created Date Section
            const Text(
              'Created On',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(widget.todo.createdAt),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
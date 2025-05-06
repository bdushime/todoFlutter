// lib/models/todo.dart
class Todo {
  final String id;
  final String title;
  String? description;
  bool isCompleted;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
  });
}
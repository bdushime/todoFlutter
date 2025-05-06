// lib/models/user.dart
class User {
  final String name;
  final String email;
  final String avatar;

  User({
    required this.name,
    required this.email,
    this.avatar = 'https://ui-avatars.com/api/?name=User',
  });
}
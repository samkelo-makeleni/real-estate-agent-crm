enum UserRole { admin, agent, viewer }

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String phone;
  final DateTime createdAt;
}

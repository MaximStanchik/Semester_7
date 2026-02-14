import 'role.dart';

class AppUser {
  String id;
  String name;
  UserRole role;
  String? email;
  String? photoUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.user,
      ),
      email: map['email'],
      photoUrl: map['photoUrl'],
    );
  }
}



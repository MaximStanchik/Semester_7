class UserProfile {
  final String uid;
  final String? email;
  final String name;
  final String role;
  final String? avatarUrl;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.role,
    this.email,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      name: (json['name'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'viewer',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

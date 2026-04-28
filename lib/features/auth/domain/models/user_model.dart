import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String userRole;
  final bool emailVerified;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.userRole = 'user',
    this.emailVerified = false,
    this.createdAt,
  });

  /// Check if user has admin privileges
  bool get isAdmin => userRole.trim().toLowerCase() == 'admin';

  /// Check if user is a mentor
  bool get isMentor => userRole.trim().toLowerCase() == 'mentor';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      photoUrl: json['photo_url'] as String?,
      userRole: json['user_role'] as String? ?? 'user',
      emailVerified: json['email_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'user_role': userRole,
      'email_verified': emailVerified,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? userRole,
    bool? emailVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      userRole: userRole ?? this.userRole,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, photoUrl, userRole, emailVerified, createdAt];
}

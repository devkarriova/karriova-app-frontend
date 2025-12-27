import 'package:equatable/equatable.dart';

/// Comment model - represents a comment on a post
class CommentModel extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userName;
  final String? userPhotoUrl;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userPhotoUrl,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userName: json['user_name'] as String?,
      userPhotoUrl: json['user_photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
    };
  }

  /// Get user initials from name
  String get userInitials {
    if (userName == null || userName!.isEmpty) return '?';
    final parts = userName!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return userName![0];
  }

  @override
  List<Object?> get props => [id, postId, userId, content, createdAt, updatedAt, userName, userPhotoUrl];
}

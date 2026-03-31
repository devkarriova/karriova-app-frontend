import 'package:equatable/equatable.dart';

enum NotificationType {
  like,
  comment,
  share,
  follow,
  mention,
  message,
}

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String actorId;
  final NotificationType type;
  final String? postId;
  final String? commentId;
  final String message;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final String? actorUsername;
  final String? actorFullName;
  final String? actorPhotoUrl;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.actorId,
    required this.type,
    this.postId,
    this.commentId,
    required this.message,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.actorUsername,
    this.actorFullName,
    this.actorPhotoUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      actorId: json['actor_id'] as String,
      type: _parseNotificationType(json['type'] as String),
      postId: json['post_id'] as String?,
      commentId: json['comment_id'] as String?,
      message: json['message'] as String,
      isRead: json['is_read'] as bool,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      actorUsername: json['actor_username'] as String?,
      actorFullName: json['actor_full_name'] as String?,
      actorPhotoUrl: json['actor_photo_url'] as String?,
    );
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'share':
        return NotificationType.share;
      case 'follow':
        return NotificationType.follow;
      case 'mention':
        return NotificationType.mention;
      case 'message':
        return NotificationType.message;
      default:
        return NotificationType.like;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'actor_id': actorId,
      'type': type.name,
      'post_id': postId,
      'comment_id': commentId,
      'message': message,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'actor_username': actorUsername,
      'actor_full_name': actorFullName,
      'actor_photo_url': actorPhotoUrl,
    };
  }

  String get actorInitials {
    if (actorFullName == null || actorFullName!.isEmpty) {
      return actorUsername?.isNotEmpty == true
          ? actorUsername![0].toUpperCase()
          : '?';
    }
    final parts = actorFullName!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return actorFullName!.isNotEmpty ? actorFullName![0].toUpperCase() : '?';
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        actorId,
        type,
        postId,
        commentId,
        message,
        isRead,
        readAt,
        createdAt,
        actorUsername,
        actorFullName,
        actorPhotoUrl,
      ];
}

import 'package:equatable/equatable.dart';

/// User search result model
class UserSearchResult extends Equatable {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String? headline;
  final String? photoUrl;
  final String? location;

  const UserSearchResult({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.headline,
    this.photoUrl,
    this.location,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? json['email']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? json['name']?.toString() ?? '',
      headline: json['headline']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      location: json['location']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'headline': headline,
      'photo_url': photoUrl,
      'location': location,
    };
  }

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [id, username, email, fullName, headline, photoUrl, location];
}

/// Post search result model
class PostSearchResult extends Equatable {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String username;
  final String fullName;
  final String? photoUrl;
  final int likeCount;
  final int commentCount;

  const PostSearchResult({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.username,
    required this.fullName,
    this.photoUrl,
    required this.likeCount,
    required this.commentCount,
  });

  factory PostSearchResult.fromJson(Map<String, dynamic> json) {
    return PostSearchResult(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      photoUrl: json['photo_url'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'username': username,
      'full_name': fullName,
      'photo_url': photoUrl,
      'like_count': likeCount,
      'comment_count': commentCount,
    };
  }

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        content,
        createdAt,
        username,
        fullName,
        photoUrl,
        likeCount,
        commentCount,
      ];
}

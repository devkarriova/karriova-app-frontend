import 'package:equatable/equatable.dart';

/// Post model - represents a social media post
class PostModel extends Equatable {
  final String id;
  final String userId;
  final String content;
  final List<String> mediaUrls;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.mediaUrls = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      mediaUrls: (json['media_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'media_urls': mediaUrls,
      'like_count': likeCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        content,
        mediaUrls,
        likeCount,
        commentCount,
        shareCount,
        isLiked,
        createdAt,
        updatedAt,
      ];
}

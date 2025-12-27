import 'package:equatable/equatable.dart';
import 'attachment_model.dart';

/// Post model - represents a social media post
class PostModel extends Equatable {
  final String id;
  final String userId;
  final String? userName;
  final String? userPhotoUrl;
  final String content;
  final List<String> mediaUrls;
  final List<AttachmentModel> attachments;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostModel({
    required this.id,
    required this.userId,
    this.userName,
    this.userPhotoUrl,
    required this.content,
    this.mediaUrls = const [],
    this.attachments = const [],
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
      userName: json['user_name'] as String?,
      userPhotoUrl: json['user_photo_url'] as String?,
      content: json['content'] as String,
      mediaUrls: (json['media_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
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
        userName,
        userPhotoUrl,
        content,
        mediaUrls,
        attachments,
        likeCount,
        commentCount,
        shareCount,
        isLiked,
        createdAt,
        updatedAt,
      ];

  // Helper to get all image URLs (from both mediaUrls and attachments)
  List<String> get allImageUrls {
    final attachmentUrls = attachments
        .where((a) => a.isImage)
        .map((a) => a.fileUrl)
        .toList();
    return [...mediaUrls, ...attachmentUrls];
  }
}

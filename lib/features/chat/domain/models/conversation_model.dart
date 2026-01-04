import 'package:equatable/equatable.dart';

/// Conversation model - represents a 1-to-1 chat conversation
class ConversationModel extends Equatable {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhoto;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;

  const ConversationModel({
    required this.id,
    required this.otherUserId,
    this.otherUserName = 'Unknown User',
    this.otherUserPhoto,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
    required this.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      otherUserId: json['other_user_id'] as String,
      otherUserName: json['other_user_name'] as String? ?? 'Unknown User',
      otherUserPhoto: json['other_user_photo'] as String?,
      lastMessage: json['last_message'] as String,
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      unreadCount: json['unread_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'other_user_id': otherUserId,
      'other_user_name': otherUserName,
      'other_user_photo': otherUserPhoto,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt.toIso8601String(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, otherUserId, otherUserName, otherUserPhoto, lastMessage, lastMessageAt, unreadCount, createdAt];
}

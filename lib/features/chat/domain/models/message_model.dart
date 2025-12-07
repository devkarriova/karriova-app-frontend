import 'package:equatable/equatable.dart';

/// Message type enum
enum MessageType {
  text,
  image,
  file,
}

/// Message model - represents a chat message
class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType messageType;
  final String? attachmentUrl;
  final bool isRead;
  final bool isDelivered;
  final DateTime createdAt;
  final DateTime? readAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.messageType = MessageType.text,
    this.attachmentUrl,
    this.isRead = false,
    this.isDelivered = false,
    required this.createdAt,
    this.readAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      messageType: _parseMessageType(json['message_type'] as String),
      attachmentUrl: json['attachment_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      isDelivered: json['is_delivered'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'message_type': messageType.name,
      'attachment_url': attachmentUrl,
      'is_read': isRead,
      'is_delivered': isDelivered,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  static MessageType _parseMessageType(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        receiverId,
        content,
        messageType,
        attachmentUrl,
        isRead,
        isDelivered,
        createdAt,
        readAt,
      ];
}

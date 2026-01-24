import '../../../../core/network/api_client.dart';
import '../../domain/models/conversation_model.dart';
import '../../domain/models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations({int limit = 20, int offset = 0});
  Future<ConversationModel> startConversation(String otherUserId);
  Future<List<MessageModel>> getMessages(String conversationId, {int limit = 50, int offset = 0});
  Future<MessageModel> sendMessage(String receiverId, String content, MessageType messageType, String? attachmentUrl);
  Future<void> markAsRead(String messageId);
  Future<void> markAsDelivered(String messageId);
  Future<void> deleteMessage(String messageId);
  Future<int> getTotalUnreadCount();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ConversationModel>> getConversations({int limit = 20, int offset = 0}) async {
    final response = await apiClient.get(
      '/chat/conversations',
      requiresAuth: true,
      queryParams: {'limit': limit.toString(), 'offset': offset.toString()},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get conversations');
    }

    final List<dynamic> conversations = response.data as List<dynamic>;
    return conversations.map((json) => ConversationModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<ConversationModel> startConversation(String otherUserId) async {
    final response = await apiClient.post(
      '/chat/conversations/$otherUserId',
      requiresAuth: true,
      body: {},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to start conversation');
    }

    return ConversationModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId, {int limit = 50, int offset = 0}) async {
    final response = await apiClient.get(
      '/chat/conversations/$conversationId/messages',
      requiresAuth: true,
      queryParams: {'limit': limit.toString(), 'offset': offset.toString()},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get messages');
    }

    final List<dynamic> messages = response.data as List<dynamic>;
    return messages.map((json) => MessageModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<MessageModel> sendMessage(String receiverId, String content, MessageType messageType, String? attachmentUrl) async {
    final response = await apiClient.post(
      '/chat/messages',
      requiresAuth: true,
      body: {
        'receiver_id': receiverId,
        'content': content,
        'message_type': messageType.name,
        if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      },
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to send message');
    }

    return MessageModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> markAsRead(String messageId) async {
    final response = await apiClient.put(
      '/chat/messages/$messageId/read',
      requiresAuth: true,
      body: {},
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to mark as read');
    }
  }

  @override
  Future<void> markAsDelivered(String messageId) async {
    final response = await apiClient.put(
      '/chat/messages/$messageId/delivered',
      requiresAuth: true,
      body: {},
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to mark as delivered');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    final response = await apiClient.delete(
      '/chat/messages/$messageId',
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to delete message');
    }
  }

  @override
  Future<int> getTotalUnreadCount() async {
    final response = await apiClient.get(
      '/chat/unread-count',
      requiresAuth: true,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get unread count');
    }

    return (response.data as Map<String, dynamic>)['unread_count'] as int? ?? 0;
  }
}

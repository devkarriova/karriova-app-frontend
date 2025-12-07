import 'package:dartz/dartz.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Repository interface for chat operations
abstract class ChatRepository {
  Future<Either<String, List<ConversationModel>>> getConversations({int limit = 20, int offset = 0});
  Future<Either<String, ConversationModel>> startConversation(String otherUserId);
  Future<Either<String, List<MessageModel>>> getMessages(String conversationId, {int limit = 50, int offset = 0});
  Future<Either<String, MessageModel>> sendMessage(String receiverId, String content, MessageType messageType, String? attachmentUrl);
  Future<Either<String, void>> markAsRead(String messageId);
  Future<Either<String, void>> markAsDelivered(String messageId);
  Future<Either<String, void>> deleteMessage(String messageId);

  // Real-time features (will be implemented with WebSocket/FCM)
  Stream<MessageModel>? get messageStream;
  void connectToRealtime(String userId);
  void disconnectFromRealtime();
}

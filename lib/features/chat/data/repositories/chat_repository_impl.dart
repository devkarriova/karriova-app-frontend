import 'package:dartz/dartz.dart';
import '../../domain/models/conversation_model.dart';
import '../../domain/models/message_model.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<ConversationModel>>> getConversations({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final conversations = await remoteDataSource.getConversations(
        limit: limit,
        offset: offset,
      );
      return Right(conversations);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ConversationModel>> startConversation(
    String otherUserId,
  ) async {
    try {
      final conversation = await remoteDataSource.startConversation(otherUserId);
      return Right(conversation);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<MessageModel>>> getMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final messages = await remoteDataSource.getMessages(
        conversationId,
        limit: limit,
        offset: offset,
      );
      return Right(messages);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MessageModel>> sendMessage(
    String receiverId,
    String content,
    MessageType messageType,
    String? attachmentUrl,
  ) async {
    try {
      final message = await remoteDataSource.sendMessage(
        receiverId,
        content,
        messageType,
        attachmentUrl,
      );
      return Right(message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> markAsRead(String messageId) async {
    try {
      await remoteDataSource.markAsRead(messageId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> markAsDelivered(String messageId) async {
    try {
      await remoteDataSource.markAsDelivered(messageId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteMessage(String messageId) async {
    try {
      await remoteDataSource.deleteMessage(messageId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Real-time features - to be implemented with WebSocket/FCM
  @override
  Stream<MessageModel>? get messageStream => null;

  @override
  void connectToRealtime(String userId) {
    // TODO: Implement WebSocket connection
  }

  @override
  void disconnectFromRealtime() {
    // TODO: Implement WebSocket disconnection
  }

  @override
  Future<Either<String, int>> getTotalUnreadCount() async {
    try {
      final count = await remoteDataSource.getTotalUnreadCount();
      return Right(count);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

import 'package:equatable/equatable.dart';
import '../../domain/models/message_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load conversations list
class ChatConversationsRequested extends ChatEvent {
  final bool isRefresh;

  const ChatConversationsRequested({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Event to load messages for a specific conversation
class ChatMessagesRequested extends ChatEvent {
  final String conversationId;
  final bool isRefresh;

  const ChatMessagesRequested({
    required this.conversationId,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [conversationId, isRefresh];
}

/// Event to send a message
class ChatMessageSent extends ChatEvent {
  final String conversationId;
  final String receiverId;
  final String content;
  final MessageType messageType;
  final String? attachmentUrl;

  const ChatMessageSent({
    required this.conversationId,
    required this.receiverId,
    required this.content,
    this.messageType = MessageType.text,
    this.attachmentUrl,
  });

  @override
  List<Object?> get props => [
        conversationId,
        receiverId,
        content,
        messageType,
        attachmentUrl,
      ];
}

/// Event to mark a message as read
class ChatMessageRead extends ChatEvent {
  final String messageId;

  const ChatMessageRead({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

/// Event to mark messages in a conversation as read
class ChatConversationMessagesRead extends ChatEvent {
  final String conversationId;
  final List<String> messageIds;

  const ChatConversationMessagesRead({
    required this.conversationId,
    required this.messageIds,
  });

  @override
  List<Object?> get props => [conversationId, messageIds];
}

/// Event to reset message send status to idle
class ChatMessageSendStatusReset extends ChatEvent {
  const ChatMessageSendStatusReset();
}

/// Event to start a new conversation
class ChatConversationStarted extends ChatEvent {
  final String otherUserId;

  const ChatConversationStarted({required this.otherUserId});

  @override
  List<Object?> get props => [otherUserId];
}

/// Event to connect to WebSocket
class ChatWebSocketConnectRequested extends ChatEvent {
  final String authToken;

  const ChatWebSocketConnectRequested({required this.authToken});

  @override
  List<Object?> get props => [authToken];
}

/// Event when WebSocket disconnects
class ChatWebSocketDisconnectRequested extends ChatEvent {
  const ChatWebSocketDisconnectRequested();
}

/// Event when a real-time message is received via WebSocket
class ChatWebSocketMessageReceived extends ChatEvent {
  final MessageModel message;

  const ChatWebSocketMessageReceived({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Event when WebSocket connection status changes
class ChatWebSocketConnectionChanged extends ChatEvent {
  final bool isConnected;

  const ChatWebSocketConnectionChanged({required this.isConnected});

  @override
  List<Object?> get props => [isConnected];
}

/// Event to clear the started conversation state
class ChatStartedConversationCleared extends ChatEvent {
  const ChatStartedConversationCleared();
}

import 'package:equatable/equatable.dart';
import '../../domain/models/conversation_model.dart';
import '../../domain/models/message_model.dart';

enum ChatStatus {
  initial,
  loading,
  success,
  error,
}

enum MessageSendStatus {
  idle,
  sending,
  success,
  error,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ConversationModel> conversations;
  final Map<String, List<MessageModel>> messagesMap;
  final Map<String, ChatStatus> conversationLoadingStates;
  final MessageSendStatus messageSendStatus;
  final String? errorMessage;
  final String? successMessage;
  final bool hasMoreConversations;
  final bool isWebSocketConnected;

  const ChatState({
    this.status = ChatStatus.initial,
    this.conversations = const [],
    this.messagesMap = const {},
    this.conversationLoadingStates = const {},
    this.messageSendStatus = MessageSendStatus.idle,
    this.errorMessage,
    this.successMessage,
    this.hasMoreConversations = true,
    this.isWebSocketConnected = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ConversationModel>? conversations,
    Map<String, List<MessageModel>>? messagesMap,
    Map<String, ChatStatus>? conversationLoadingStates,
    MessageSendStatus? messageSendStatus,
    String? errorMessage,
    String? successMessage,
    bool? hasMoreConversations,
    bool? isWebSocketConnected,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      messagesMap: messagesMap ?? this.messagesMap,
      conversationLoadingStates:
          conversationLoadingStates ?? this.conversationLoadingStates,
      messageSendStatus: messageSendStatus ?? this.messageSendStatus,
      errorMessage: errorMessage,
      successMessage: successMessage,
      hasMoreConversations: hasMoreConversations ?? this.hasMoreConversations,
      isWebSocketConnected: isWebSocketConnected ?? this.isWebSocketConnected,
    );
  }

  /// Get messages for a specific conversation
  List<MessageModel> getMessagesForConversation(String conversationId) {
    return messagesMap[conversationId] ?? [];
  }

  /// Get loading state for a specific conversation
  ChatStatus getConversationLoadingState(String conversationId) {
    return conversationLoadingStates[conversationId] ?? ChatStatus.initial;
  }

  /// Check if messages are loading for a conversation
  bool isConversationLoading(String conversationId) {
    return conversationLoadingStates[conversationId] == ChatStatus.loading;
  }

  @override
  List<Object?> get props => [
        status,
        conversations,
        messagesMap,
        conversationLoadingStates,
        messageSendStatus,
        errorMessage,
        successMessage,
        hasMoreConversations,
        isWebSocketConnected,
      ];
}

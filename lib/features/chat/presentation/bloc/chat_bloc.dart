import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/chat_websocket_service.dart';
import '../../domain/models/conversation_model.dart';
import '../../domain/models/message_model.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final ChatWebSocketService? webSocketService;
  StreamSubscription? _webSocketSubscription;
  StreamSubscription? _connectionSubscription;

  ChatBloc({
    required this.chatRepository,
    this.webSocketService,
  }) : super(const ChatState()) {
    on<ChatConversationsRequested>(_onConversationsRequested);
    on<ChatMessagesRequested>(_onMessagesRequested);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatMessageRead>(_onMessageRead);
    on<ChatConversationMessagesRead>(_onConversationMessagesRead);
    on<ChatConversationStarted>(_onConversationStarted);
    on<ChatMessageSendStatusReset>(_onMessageSendStatusReset);
    on<ChatStartedConversationCleared>(_onStartedConversationCleared);
    on<ChatWebSocketConnectRequested>(_onWebSocketConnect);
    on<ChatWebSocketDisconnectRequested>(_onWebSocketDisconnect);
    on<ChatWebSocketMessageReceived>(_onWebSocketMessageReceived);
    on<ChatWebSocketConnectionChanged>(_onWebSocketConnectionChanged);
  }

  @override
  Future<void> close() {
    _webSocketSubscription?.cancel();
    _connectionSubscription?.cancel();
    webSocketService?.disconnect();
    return super.close();
  }

  Future<void> _onConversationsRequested(
    ChatConversationsRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (event.isRefresh) {
      emit(state.copyWith(status: ChatStatus.loading, conversations: []));
    } else if (state.status == ChatStatus.initial) {
      emit(state.copyWith(status: ChatStatus.loading));
    }

    final result = await chatRepository.getConversations(limit: 20, offset: 0);

    result.fold(
      (error) {
        emit(state.copyWith(
          status: ChatStatus.error,
          errorMessage: error,
        ));
      },
      (conversations) {
        emit(state.copyWith(
          status: ChatStatus.success,
          conversations: conversations,
          hasMoreConversations: conversations.length >= 20,
        ));
      },
    );
  }

  Future<void> _onMessagesRequested(
    ChatMessagesRequested event,
    Emitter<ChatState> emit,
  ) async {
    // Update conversation loading state
    final updatedLoadingStates =
        Map<String, ChatStatus>.from(state.conversationLoadingStates);
    updatedLoadingStates[event.conversationId] = ChatStatus.loading;

    emit(state.copyWith(
      conversationLoadingStates: updatedLoadingStates,
    ));

    final result = await chatRepository.getMessages(
      event.conversationId,
      limit: 50,
      offset: 0,
    );

    result.fold(
      (error) {
        final errorStates =
            Map<String, ChatStatus>.from(state.conversationLoadingStates);
        errorStates[event.conversationId] = ChatStatus.error;
        emit(state.copyWith(
          conversationLoadingStates: errorStates,
          errorMessage: error,
        ));
      },
      (messages) {
        final updatedMessagesMap =
            Map<String, List<MessageModel>>.from(state.messagesMap);
        // Sort messages by creation date (oldest first for chat display)
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        updatedMessagesMap[event.conversationId] = messages;

        final successStates =
            Map<String, ChatStatus>.from(state.conversationLoadingStates);
        successStates[event.conversationId] = ChatStatus.success;

        emit(state.copyWith(
          messagesMap: updatedMessagesMap,
          conversationLoadingStates: successStates,
        ));
      },
    );
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(messageSendStatus: MessageSendStatus.sending));

    final result = await chatRepository.sendMessage(
      event.receiverId,
      event.content,
      event.messageType,
      event.attachmentUrl,
    );

    result.fold(
      (error) {
        emit(state.copyWith(
          messageSendStatus: MessageSendStatus.error,
          errorMessage: error,
        ));
      },
      (message) {
        // Use the conversation ID from the message response (for new conversations)
        final actualConversationId = message.conversationId;

        // Add the new message to the messages map using the actual conversation ID
        final updatedMessagesMap =
            Map<String, List<MessageModel>>.from(state.messagesMap);
        final conversationMessages = List<MessageModel>.from(
            updatedMessagesMap[actualConversationId] ?? []);
        conversationMessages.add(message);
        updatedMessagesMap[actualConversationId] = conversationMessages;

        // If this was a new conversation (event had empty conversationId),
        // also copy any messages that were added under empty key
        if (event.conversationId.isEmpty &&
            updatedMessagesMap.containsKey('')) {
          final emptyKeyMessages = updatedMessagesMap[''] ?? [];
          if (emptyKeyMessages.isNotEmpty) {
            conversationMessages.insertAll(
                0, emptyKeyMessages.where((m) => m.id != message.id));
            updatedMessagesMap.remove('');
          }
        }

        // Update the conversation in the list with the new last message
        final updatedConversations = state.conversations.map((conv) {
          if (conv.id == actualConversationId) {
            return conv;
          }
          return conv;
        }).toList();

        emit(state.copyWith(
          messageSendStatus: MessageSendStatus.success,
          messagesMap: updatedMessagesMap,
          conversations: updatedConversations,
          // Store the new conversation ID so the UI can access it
          lastCreatedConversationId:
              event.conversationId.isEmpty ? actualConversationId : null,
        ));
      },
    );
  }

  void _onMessageSendStatusReset(
    ChatMessageSendStatusReset event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      messageSendStatus: MessageSendStatus.idle,
      clearLastCreatedConversationId: true,
    ));
  }

  void _onStartedConversationCleared(
    ChatStartedConversationCleared event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(clearStartedConversation: true));
  }

  Future<void> _onMessageRead(
    ChatMessageRead event,
    Emitter<ChatState> emit,
  ) async {
    await chatRepository.markAsRead(event.messageId);
    // Optionally update local state to mark message as read
  }

  Future<void> _onConversationMessagesRead(
    ChatConversationMessagesRead event,
    Emitter<ChatState> emit,
  ) async {
    // Mark all unread messages in the conversation as read
    for (final messageId in event.messageIds) {
      await chatRepository.markAsRead(messageId);
    }

    // Update local state to mark messages as read
    final updatedMessagesMap =
        Map<String, List<MessageModel>>.from(state.messagesMap);
    final conversationMessages = updatedMessagesMap[event.conversationId] ?? [];

    final updatedMessages = conversationMessages.map((message) {
      if (event.messageIds.contains(message.id)) {
        // Create a new message with isRead = true
        return MessageModel(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          receiverId: message.receiverId,
          content: message.content,
          messageType: message.messageType,
          attachmentUrl: message.attachmentUrl,
          isRead: true,
          isDelivered: message.isDelivered,
          createdAt: message.createdAt,
          readAt: DateTime.now(),
        );
      }
      return message;
    }).toList();

    updatedMessagesMap[event.conversationId] = updatedMessages;

    emit(state.copyWith(messagesMap: updatedMessagesMap));
  }

  Future<void> _onConversationStarted(
    ChatConversationStarted event,
    Emitter<ChatState> emit,
  ) async {
    final result = await chatRepository.startConversation(event.otherUserId);

    result.fold(
      (error) => emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: error,
      )),
      (conversation) {
        // Check if conversation already exists in list
        final existingIndex = state.conversations.indexWhere(
          (c) => c.id == conversation.id,
        );
        
        List<ConversationModel> updatedConversations;
        if (existingIndex >= 0) {
          // Already in list, don't duplicate
          updatedConversations = state.conversations;
        } else {
          // Add to beginning of list
          updatedConversations = [conversation, ...state.conversations];
        }
        
        emit(state.copyWith(
          status: ChatStatus.success,
          conversations: updatedConversations,
          startedConversation: conversation, // Store the started conversation
        ));
      },
    );
  }

  // WebSocket event handlers
  Future<void> _onWebSocketConnect(
    ChatWebSocketConnectRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (webSocketService == null) return;

    // Connect to WebSocket
    await webSocketService!.connect(event.authToken);

    // Listen to incoming messages
    _webSocketSubscription =
        webSocketService!.messageStream.listen((wsMessage) {
      // Convert WebSocket message to domain message and add to BLoC
      if (wsMessage.type == WebSocketMessageType.message) {
        final message = MessageModel(
          id: wsMessage.messageId ?? DateTime.now().toString(),
          conversationId: wsMessage.conversationId ?? '',
          senderId: wsMessage.senderId,
          receiverId: wsMessage.receiverId,
          content: wsMessage.content ?? '',
          messageType: MessageType.text,
          isRead: false,
          isDelivered: true,
          createdAt: wsMessage.timestamp,
        );
        add(ChatWebSocketMessageReceived(message: message));
      }
    });

    // Listen to connection changes
    _connectionSubscription =
        webSocketService!.connectionStream.listen((isConnected) {
      add(ChatWebSocketConnectionChanged(isConnected: isConnected));
    });
  }

  void _onWebSocketDisconnect(
    ChatWebSocketDisconnectRequested event,
    Emitter<ChatState> emit,
  ) {
    _webSocketSubscription?.cancel();
    _connectionSubscription?.cancel();
    webSocketService?.disconnect();
    emit(state.copyWith(isWebSocketConnected: false));
  }

  void _onWebSocketMessageReceived(
    ChatWebSocketMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    // Add message to the appropriate conversation
    final updatedMessagesMap =
        Map<String, List<MessageModel>>.from(state.messagesMap);
    final conversationMessages = List<MessageModel>.from(
        updatedMessagesMap[event.message.conversationId] ?? []);

    // Only add if not already in list (prevent duplicates)
    if (!conversationMessages.any((m) => m.id == event.message.id)) {
      conversationMessages.add(event.message);
      conversationMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      updatedMessagesMap[event.message.conversationId] = conversationMessages;

      emit(state.copyWith(messagesMap: updatedMessagesMap));
    }
  }

  void _onWebSocketConnectionChanged(
    ChatWebSocketConnectionChanged event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(isWebSocketConnected: event.isConnected));
  }
}

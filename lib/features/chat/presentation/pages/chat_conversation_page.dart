import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/models/message_model.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';

/// Chat conversation page - displays messages in a conversation
class ChatConversationPage extends StatefulWidget {
  final String conversationId;
  final String otherUserId;

  const ChatConversationPage({
    super.key,
    required this.conversationId,
    required this.otherUserId,
  });

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatBloc>()
        ..add(ChatMessagesRequested(conversationId: widget.conversationId)),
      child: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }

          // Scroll to bottom when new message is sent successfully
          if (state.messageSendStatus == MessageSendStatus.success) {
            _scrollToBottom();
          }

          // Mark messages as read when conversation loads
          if (state.getConversationLoadingState(widget.conversationId) ==
              ChatStatus.success) {
            final messages =
                state.getMessagesForConversation(widget.conversationId);
            final authState = context.read<AuthBloc>().state;
            if (authState.user != null) {
              final unreadMessageIds = messages
                  .where((msg) =>
                      !msg.isRead &&
                      msg.receiverId == authState.user!.id &&
                      msg.senderId == widget.otherUserId)
                  .map((msg) => msg.id)
                  .toList();

              if (unreadMessageIds.isNotEmpty) {
                context.read<ChatBloc>().add(
                      ChatConversationMessagesRead(
                        conversationId: widget.conversationId,
                        messageIds: unreadMessageIds,
                      ),
                    );
              }
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getUserName(widget.otherUserId),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.surface,
              elevation: 0,
            ),
            body: Column(
              children: [
                Expanded(
                  child: _buildMessagesList(context, state),
                ),
                _buildMessageInput(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, ChatState state) {
    final isLoading =
        state.isConversationLoading(widget.conversationId) &&
            state.getMessagesForConversation(widget.conversationId).isEmpty;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    final messages = state.getMessagesForConversation(widget.conversationId);

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Send a message to start the conversation',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    // Scroll to bottom when messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUserId = authState.user?.id;

        return Container(
          color: AppColors.background,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isSentByMe = message.senderId == currentUserId;

              return MessageBubble(
                message: message,
                isSentByMe: isSentByMe,
                senderName: isSentByMe
                    ? authState.user?.name
                    : _getUserName(widget.otherUserId),
                senderPhotoUrl: isSentByMe
                    ? authState.user?.photoUrl
                    : _getUserPhotoUrl(widget.otherUserId),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(BuildContext context, ChatState state) {
    final isSending = state.messageSendStatus == MessageSendStatus.sending;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  enabled: !isSending,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: isSending ? null : () => _sendMessage(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    context.read<ChatBloc>().add(
          ChatMessageSent(
            conversationId: widget.conversationId,
            receiverId: widget.otherUserId,
            content: content,
            messageType: MessageType.text,
          ),
        );

    _messageController.clear();
  }

  // Helper method to get user name
  // TODO: In a real app, you would fetch user details from a user repository
  String _getUserName(String userId) {
    // For now, return a placeholder name
    // In production, this should come from a user cache or API
    return 'User $userId';
  }

  // Helper method to get user photo URL
  // TODO: In a real app, you would fetch user details from a user repository
  String? _getUserPhotoUrl(String userId) {
    // For now, return null
    // In production, this should come from a user cache or API
    return null;
  }
}

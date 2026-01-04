import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
/// Modern UI with gradient header, elegant input, and smooth animations
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

class _ChatConversationPageState extends State<ChatConversationPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late final ChatBloc _chatBloc;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _chatBloc = getIt<ChatBloc>();

    // Load messages for this conversation
    _chatBloc.add(ChatMessagesRequested(conversationId: widget.conversationId));

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _isTyping) {
        setState(() => _isTyping = hasText);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: BlocConsumer<ChatBloc, ChatState>(
        listenWhen: (previous, current) {
          // Only listen when relevant state changes
          return previous.errorMessage != current.errorMessage ||
              previous.messageSendStatus != current.messageSendStatus ||
              previous.getConversationLoadingState(widget.conversationId) !=
                  current.getConversationLoadingState(widget.conversationId);
        },
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.errorMessage!)),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }

          if (state.messageSendStatus == MessageSendStatus.success) {
            _scrollToBottom();
          }

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
            backgroundColor: AppColors.background,
            appBar: _buildModernAppBar(context),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Expanded(
                    child: _buildMessagesList(context, state),
                  ),
                  _buildMessageInput(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                _buildUserAvatar(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getUserName(widget.otherUserId),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onPressed: () {
                    // TODO: Show options menu
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    final photoUrl = _getUserPhotoUrl(widget.otherUserId);
    final name = _getUserName(widget.otherUserId);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.secondary.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: photoUrl != null && photoUrl.isNotEmpty
          ? CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(photoUrl),
              backgroundColor: AppColors.surfaceVariant,
            )
          : Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildMessagesList(BuildContext context, ChatState state) {
    final isLoading = state.isConversationLoading(widget.conversationId) &&
        state.getMessagesForConversation(widget.conversationId).isEmpty;

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading messages...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final messages = state.getMessagesForConversation(widget.conversationId);

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.waving_hand_rounded,
                  size: 48,
                  color: AppColors.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Say Hello! 👋',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start your conversation with\n${_getUserName(widget.otherUserId)}',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUserId = authState.user?.id;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.background,
                AppColors.surfaceVariant.withOpacity(0.3),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isSentByMe = message.senderId == currentUserId;

              // Determine if this is first/last in a group of same sender
              final isFirstInGroup = index == 0 ||
                  messages[index - 1].senderId != message.senderId;
              final isLastInGroup = index == messages.length - 1 ||
                  messages[index + 1].senderId != message.senderId;

              return MessageBubble(
                message: message,
                isSentByMe: isSentByMe,
                senderName: isSentByMe
                    ? authState.user?.name
                    : _getUserName(widget.otherUserId),
                senderPhotoUrl: isSentByMe
                    ? authState.user?.photoUrl
                    : _getUserPhotoUrl(widget.otherUserId),
                isFirstInGroup: isFirstInGroup,
                isLastInGroup: isLastInGroup,
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
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment button
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 22,
                  color: AppColors.textSecondary,
                ),
              ),
              onPressed: () {
                // TODO: Show attachment options
              },
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 8),
          // Message input field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _inputFocusNode.hasFocus
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _inputFocusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                enabled: !isSending,
                onSubmitted: (_) => _sendMessage(context),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isSending ? null : () => _sendMessage(context),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _isTyping
                        ? const LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _isTyping ? null : AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                    boxShadow: _isTyping
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isSending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            size: 22,
                            color: _isTyping
                                ? Colors.white
                                : AppColors.textTertiary,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

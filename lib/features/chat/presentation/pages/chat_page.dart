import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../follow/domain/models/follow_model.dart';
import '../../../follow/presentation/bloc/follow_bloc.dart';
import '../../../follow/presentation/bloc/follow_event.dart';
import '../../../follow/presentation/bloc/follow_state.dart';
import '../../domain/models/conversation_model.dart';
import '../../domain/models/message_model.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/message_bubble.dart';

/// Unified Chat Page with split view
/// Left side: Conversation list
/// Right side: Active conversation
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ChatBloc>()
            ..add(const ChatConversationsRequested()),
        ),
        BlocProvider(
          create: (context) => getIt<FollowBloc>()
            ..add(LoadFollowingEvent(currentUserId, refresh: true)),
        ),
      ],
      child: const _ChatPageView(),
    );
  }
}

class _ChatPageView extends StatefulWidget {
  const _ChatPageView();

  @override
  State<_ChatPageView> createState() => _ChatPageViewState();
}

class _ChatPageViewState extends State<_ChatPageView> {
  String? _selectedConversationId;
  String? _selectedOtherUserId;
  String? _selectedUserName;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectConversation(String conversationId, String otherUserId, String userName) {
    setState(() {
      _selectedConversationId = conversationId;
      _selectedOtherUserId = otherUserId;
      _selectedUserName = userName;
    });

    // Load messages for the selected conversation
    if (conversationId.isNotEmpty) {
      context.read<ChatBloc>().add(ChatMessagesRequested(conversationId: conversationId));
    }
  }

  void _startNewConversation(FollowUserModel user) {
    setState(() {
      _selectedConversationId = '';
      _selectedOtherUserId = user.id;
      _selectedUserName = user.name;
    });
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
    return Scaffold(
      body: Row(
        children: [
          // Left panel - Conversation list
          SizedBox(
            width: 350,
            child: _buildConversationListPanel(),
          ),
          // Divider
          Container(
            width: 1,
            color: AppColors.border,
          ),
          // Right panel - Conversation view
          Expanded(
            child: _buildConversationPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationListPanel() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
          ),
          child: Row(
            children: [
              const Text(
                'Messages',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.search, size: 22),
                onPressed: () => context.push('/search'),
                tooltip: 'Find people',
              ),
            ],
          ),
        ),
        // Conversation list
        Expanded(
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state.status == ChatStatus.loading && state.conversations.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state.conversations.isEmpty) {
                return _buildEmptyConversationList();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ChatBloc>().add(
                        const ChatConversationsRequested(isRefresh: true),
                      );
                },
                color: AppColors.primary,
                child: ListView.builder(
                  itemCount: state.conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = state.conversations[index];
                    final isSelected = _selectedConversationId == conversation.id;
                    
                    return _buildConversationItem(conversation, isSelected);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConversationItem(ConversationModel conversation, bool isSelected) {
    return Container(
      color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      child: ConversationTile(
        conversation: conversation,
        otherUserName: _getUserName(conversation.otherUserId),
        otherUserPhotoUrl: _getUserPhotoUrl(conversation.otherUserId),
        onTap: () {
          _selectConversation(
            conversation.id,
            conversation.otherUserId,
            _getUserName(conversation.otherUserId),
          );
        },
      ),
    );
  }

  Widget _buildEmptyConversationList() {
    return BlocBuilder<FollowBloc, FollowState>(
      builder: (context, followState) {
        return CustomScrollView(
          slivers: [
            // Header message
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: AppColors.textTertiary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No conversations yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Start a conversation with someone you follow',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Section header
            if (followState.following.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'People you follow',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

            // List of followed users
            if (followState.following.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final user = followState.following[index];
                    return _buildFollowedUserTile(user);
                  },
                  childCount: followState.following.length,
                ),
              ),

            // Loading state
            if (followState.status == FollowStatus.loading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),

            // Empty following list
            if (followState.following.isEmpty &&
                followState.status != FollowStatus.loading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Follow people to start conversations',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/search'),
                        icon: const Icon(Icons.search, size: 18),
                        label: const Text('Find People'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFollowedUserTile(FollowUserModel user) {
    final isSelected = _selectedOtherUserId == user.id;
    
    return Container(
      color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.surfaceVariant,
          backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null || user.photoUrl!.isEmpty
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: user.headline != null && user.headline!.isNotEmpty
            ? Text(
                user.headline!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        onTap: () => _startNewConversation(user),
      ),
    );
  }

  Widget _buildConversationPanel() {
    if (_selectedOtherUserId == null) {
      return _buildNoConversationSelected();
    }

    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state.messageSendStatus == MessageSendStatus.success) {
          _scrollToBottom();
          // Refresh conversations to get the new one
          context.read<ChatBloc>().add(const ChatConversationsRequested(isRefresh: true));
        }

        // Mark messages as read
        if (_selectedConversationId != null &&
            _selectedConversationId!.isNotEmpty &&
            state.getConversationLoadingState(_selectedConversationId!) == ChatStatus.success) {
          final messages = state.getMessagesForConversation(_selectedConversationId!);
          final authState = context.read<AuthBloc>().state;
          if (authState.user != null) {
            final unreadMessageIds = messages
                .where((msg) =>
                    !msg.isRead &&
                    msg.receiverId == authState.user!.id &&
                    msg.senderId == _selectedOtherUserId)
                .map((msg) => msg.id)
                .toList();

            if (unreadMessageIds.isNotEmpty) {
              context.read<ChatBloc>().add(
                    ChatConversationMessagesRead(
                      conversationId: _selectedConversationId!,
                      messageIds: unreadMessageIds,
                    ),
                  );
            }
          }
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // Conversation header
            _buildConversationHeader(),
            // Divider
            Container(height: 1, color: AppColors.border.withOpacity(0.5)),
            // Messages
            Expanded(
              child: _buildMessagesList(state),
            ),
            // Message input
            _buildMessageInput(state),
          ],
        );
      },
    );
  }

  Widget _buildNoConversationSelected() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.textTertiary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a conversation from the left to start messaging',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceVariant,
            child: Text(
              _selectedUserName?.isNotEmpty == true
                  ? _selectedUserName![0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedUserName ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show conversation options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatState state) {
    // For new conversations (no ID yet)
    if (_selectedConversationId == null || _selectedConversationId!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Start a conversation with $_selectedUserName',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Send a message to begin',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    final isLoading = state.isConversationLoading(_selectedConversationId!) &&
        state.getMessagesForConversation(_selectedConversationId!).isEmpty;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final messages = state.getMessagesForConversation(_selectedConversationId!);

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
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

    // Scroll to bottom when messages load
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUserId = authState.user?.id;

        return Container(
          color: AppColors.background,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isSentByMe = message.senderId == currentUserId;

              return MessageBubble(
                message: message,
                isSentByMe: isSentByMe,
                senderName: isSentByMe ? authState.user?.name : _selectedUserName,
                senderPhotoUrl: isSentByMe ? authState.user?.photoUrl : null,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(ChatState state) {
    final isSending = state.messageSendStatus == MessageSendStatus.sending;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                enabled: !isSending,
                onSubmitted: (_) => _sendMessage(),
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
              onPressed: isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _selectedOtherUserId == null) return;

    context.read<ChatBloc>().add(
          ChatMessageSent(
            conversationId: _selectedConversationId ?? '',
            receiverId: _selectedOtherUserId!,
            content: content,
            messageType: MessageType.text,
          ),
        );

    _messageController.clear();
  }

  String _getUserName(String userId) {
    // TODO: Fetch from user cache/API
    return 'User ${userId.substring(0, 8)}';
  }

  String? _getUserPhotoUrl(String userId) {
    return null;
  }
}

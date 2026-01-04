import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
class ChatPage extends StatefulWidget {
  final String? initialUserId;
  final String? initialUserName;

  const ChatPage({
    super.key,
    this.initialUserId,
    this.initialUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatBloc _chatBloc;
  late final FollowBloc _followBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = getIt<ChatBloc>();
    _followBloc = getIt<FollowBloc>();

    // Only load data if bloc is in initial state
    if (_chatBloc.state.status == ChatStatus.initial) {
      _chatBloc.add(const ChatConversationsRequested());
    }

    // Only load following if bloc hasn't loaded yet
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';
    if (_followBloc.state.status == FollowStatus.initial) {
      _followBloc.add(LoadFollowingEvent(currentUserId, refresh: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _chatBloc),
        BlocProvider.value(value: _followBloc),
      ],
      child: _ChatPageView(
        initialUserId: widget.initialUserId,
        initialUserName: widget.initialUserName,
      ),
    );
  }
}

class _ChatPageView extends StatefulWidget {
  final String? initialUserId;
  final String? initialUserName;

  const _ChatPageView({
    this.initialUserId,
    this.initialUserName,
  });

  @override
  State<_ChatPageView> createState() => _ChatPageViewState();
}

class _ChatPageViewState extends State<_ChatPageView> {
  String? _selectedConversationId;
  String? _selectedOtherUserId;
  String? _selectedUserName;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // If initial user is provided, we'll check for existing conversation
    // after conversations are loaded (handled in BlocListener below)
    if (widget.initialUserId != null) {
      _selectedOtherUserId = widget.initialUserId;
      _selectedUserName = widget.initialUserName ?? 'User';
      // Don't set _selectedConversationId yet - wait for conversations to load
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _selectConversation(
      String conversationId, String otherUserId, String userName) {
    setState(() {
      _selectedConversationId = conversationId;
      _selectedOtherUserId = otherUserId;
      _selectedUserName = userName;
    });

    // Load messages for the selected conversation
    if (conversationId.isNotEmpty) {
      context
          .read<ChatBloc>()
          .add(ChatMessagesRequested(conversationId: conversationId));
    }
  }

  void _startNewConversation(FollowUserModel user) {
    // Check if a conversation already exists with this user in LOCAL state
    final chatState = context.read<ChatBloc>().state;
    final existingConversation = chatState.conversations.firstWhere(
      (conv) => conv.otherUserId == user.id,
      orElse: () => ConversationModel(
        id: '',
        otherUserId: '',
        lastMessage: '',
        lastMessageAt: DateTime.now(),
        unreadCount: 0,
        createdAt: DateTime.now(),
      ),
    );

    if (existingConversation.id.isNotEmpty) {
      // Conversation already exists locally - select it
      _selectConversation(existingConversation.id, user.id, user.name);
    } else {
      // No conversation found locally - call backend to get or create
      // Store temp user info for display while loading
      setState(() {
        _selectedOtherUserId = user.id;
        _selectedUserName = user.name;
        _selectedConversationId = null; // null = loading state
      });
      
      // Call backend API to get or create conversation
      context.read<ChatBloc>().add(
        ChatConversationStarted(otherUserId: user.id),
      );
    }
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
              if (state.status == ChatStatus.loading &&
                  state.conversations.isEmpty) {
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
                child: Builder(
                  builder: (context) {
                    return ListView.builder(
                      // Add 1 for pending/loading conversation if selected
                      itemCount: state.conversations.length + 
                          ((_selectedConversationId == null || _selectedConversationId!.isEmpty) && 
                           _selectedOtherUserId != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show pending new conversation at the top while loading or new
                        if ((_selectedConversationId == null || _selectedConversationId!.isEmpty) && 
                            _selectedOtherUserId != null &&
                            index == 0) {
                          return _buildPendingConversationItem();
                        }
                        
                        // Adjust index for existing conversations
                        final adjustedIndex = ((_selectedConversationId == null || _selectedConversationId!.isEmpty) && 
                            _selectedOtherUserId != null) ? index - 1 : index;
                        
                        final conversation = state.conversations[adjustedIndex];
                        final isSelected =
                            _selectedConversationId == conversation.id;

                        return _buildConversationItem(conversation, isSelected);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPendingConversationItem() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {}, // Already selected
        splashColor: AppColors.primary.withOpacity(0.08),
        highlightColor: AppColors.primary.withOpacity(0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            border: const Border(
              left: BorderSide(
                color: AppColors.primary,
                width: 3,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar matching ConversationTile style
              Stack(
                children: [
                  Container(
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
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        _selectedUserName?.isNotEmpty == true
                            ? _selectedUserName![0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedUserName ?? 'New Conversation',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Loading spinner or "NEW" badge
                        if (_selectedConversationId == null)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedConversationId == null 
                          ? 'Loading conversation...'
                          : 'Start a new conversation',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItem(
      ConversationModel conversation, bool isSelected) {
    return Container(
      color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      child: ConversationTile(
        conversation: conversation,
        otherUserName: conversation.otherUserName,
        otherUserPhotoUrl: conversation.otherUserPhoto,
        onTap: () {
          _selectConversation(
            conversation.id,
            conversation.otherUserId,
            conversation.otherUserName,
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
      listenWhen: (previous, current) {
        // Listen when message send status changes, conversation started, or messages load
        final prevConvState = _selectedConversationId != null && _selectedConversationId!.isNotEmpty
            ? previous.getConversationLoadingState(_selectedConversationId!)
            : null;
        final currConvState = _selectedConversationId != null && _selectedConversationId!.isNotEmpty
            ? current.getConversationLoadingState(_selectedConversationId!)
            : null;
        
        // Also listen when conversations are first loaded (for initial user from profile)
        final conversationsJustLoaded = previous.conversations.isEmpty && 
            current.conversations.isNotEmpty;
        
        return previous.messageSendStatus != current.messageSendStatus ||
            previous.startedConversation != current.startedConversation ||
            conversationsJustLoaded ||
            (prevConvState != ChatStatus.success && currConvState == ChatStatus.success);
      },
      listener: (context, state) {
        // Check if we came from a profile and conversations just loaded
        if (widget.initialUserId != null && 
            _selectedConversationId == null &&
            state.conversations.isNotEmpty) {
          // Look for existing conversation with this user
          final existingConv = state.conversations.firstWhere(
            (conv) => conv.otherUserId == widget.initialUserId,
            orElse: () => ConversationModel(
              id: '',
              otherUserId: '',
              lastMessage: '',
              lastMessageAt: DateTime.now(),
              unreadCount: 0,
              createdAt: DateTime.now(),
            ),
          );
          
          if (existingConv.id.isNotEmpty) {
            // Found existing conversation - select it
            setState(() {
              _selectedConversationId = existingConv.id;
              _selectedUserName = existingConv.otherUserName.isNotEmpty 
                  ? existingConv.otherUserName 
                  : _selectedUserName;
            });
            // Load messages
            context.read<ChatBloc>().add(
              ChatMessagesRequested(conversationId: existingConv.id),
            );
          } else {
            // No existing conversation - set empty string to show "new conversation" state
            setState(() {
              _selectedConversationId = '';
            });
          }
        }
        
        // Handle started conversation (from ChatConversationStarted event)
        if (state.startedConversation != null &&
            _selectedOtherUserId == state.startedConversation!.otherUserId) {
          final conv = state.startedConversation!;
          setState(() {
            _selectedConversationId = conv.id;
          });
          // Load messages for this conversation
          context.read<ChatBloc>().add(
            ChatMessagesRequested(conversationId: conv.id),
          );
          // Clear the started conversation state
          context.read<ChatBloc>().add(const ChatStartedConversationCleared());
        }
        
        if (state.messageSendStatus == MessageSendStatus.success) {
          _scrollToBottom();
          // Refresh conversations to get the new one
          context
              .read<ChatBloc>()
              .add(const ChatConversationsRequested(isRefresh: true));

          // If this was a new conversation, update the selected conversation ID
          if (state.lastCreatedConversationId != null &&
              (_selectedConversationId == null ||
                  _selectedConversationId!.isEmpty)) {
            setState(() {
              _selectedConversationId = state.lastCreatedConversationId;
            });
            // Load messages for the new conversation
            context.read<ChatBloc>().add(
                  ChatMessagesRequested(
                      conversationId: state.lastCreatedConversationId!),
                );
          }
          
          // Reset the message send status so we can detect the next send
          context.read<ChatBloc>().add(const ChatMessageSendStatusReset());
        }
        
        // Mark messages as read when conversation messages first load
        if (_selectedConversationId != null &&
            _selectedConversationId!.isNotEmpty &&
            state.getConversationLoadingState(_selectedConversationId!) ==
                ChatStatus.success) {
          final messages =
              state.getMessagesForConversation(_selectedConversationId!);
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
      buildWhen: (previous, current) {
        // Only rebuild when relevant state changes (not just messageSendStatus)
        return previous.messagesMap != current.messagesMap ||
            previous.conversationLoadingStates != current.conversationLoadingStates ||
            previous.status != current.status ||
            previous.startedConversation != current.startedConversation;
      },
      builder: (context, state) {
        // NOTE: Mark messages as read logic moved to a separate method that's called
        // only when conversation is selected, not on every rebuild
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
                senderName:
                    isSentByMe ? authState.user?.name : _selectedUserName,
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
    final isLoading = _selectedConversationId == null; // Waiting for conversation to load
    final canSend = !isSending && !isLoading;

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
              child: Focus(
                onKeyEvent: (node, event) {
                  // Handle Enter key press (without Shift)
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter &&
                      !HardwareKeyboard.instance.isShiftPressed) {
                    // Enter without Shift - send message
                    if (canSend) {
                      _sendMessage();
                      return KeyEventResult.handled; // Prevent newline
                    }
                  }
                  return KeyEventResult.ignored; // Let other keys through
                },
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: isLoading ? 'Loading conversation...' : 'Type a message...',
                    hintStyle: const TextStyle(color: AppColors.textTertiary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  enabled: canSend,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: canSend ? AppColors.primary : AppColors.primary.withOpacity(0.5),
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
              onPressed: canSend ? () {
                _sendMessage();
              } : null,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    // Don't send if no content or no receiver
    if (content.isEmpty) {
      return;
    }
    if (_selectedOtherUserId == null) {
      return;
    }
    
    // Don't send if conversation is still loading (null means loading)
    if (_selectedConversationId == null) {
      return;
    }

    context.read<ChatBloc>().add(
          ChatMessageSent(
            // Empty string means new conversation - backend will create it
            conversationId: _selectedConversationId!,
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

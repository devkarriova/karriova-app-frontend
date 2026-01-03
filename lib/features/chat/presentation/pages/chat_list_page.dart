import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../follow/domain/models/follow_model.dart';
import '../../../follow/presentation/bloc/follow_bloc.dart';
import '../../../follow/presentation/bloc/follow_event.dart';
import '../../../follow/presentation/bloc/follow_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/conversation_tile.dart';
import 'chat_conversation_page.dart';

/// Chat list page - displays list of conversations
class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user ID from auth bloc
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
      child: const _ChatListView(),
    );
  }
}

class _ChatListView extends StatelessWidget {
  const _ChatListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ChatStatus.loading && state.conversations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state.status == ChatStatus.error && state.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Failed to load conversations',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(
                            const ChatConversationsRequested(isRefresh: true),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.conversations.isEmpty) {
            return _buildEmptyStateWithSuggestions(context);
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
                return ConversationTile(
                  conversation: conversation,
                  otherUserName: _getUserName(conversation.otherUserId),
                  otherUserPhotoUrl: _getUserPhotoUrl(conversation.otherUserId),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatConversationPage(
                          conversationId: conversation.id,
                          otherUserId: conversation.otherUserId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
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

  Widget _buildEmptyStateWithSuggestions(BuildContext context) {
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
                      size: 64,
                      color: AppColors.textTertiary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No conversations yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start a conversation with someone you follow',
                      style: TextStyle(
                        fontSize: 14,
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
                      fontSize: 16,
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
                    return _buildUserTile(context, user);
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
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Navigate to search using GoRouter
                          context.push('/search');
                        },
                        icon: const Icon(Icons.search),
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

  Widget _buildUserTile(BuildContext context, FollowUserModel user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.surfaceVariant,
        backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
            ? NetworkImage(user.photoUrl!)
            : null,
        child: user.photoUrl == null || user.photoUrl!.isEmpty
            ? Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              )
            : null,
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: user.headline != null && user.headline!.isNotEmpty
          ? Text(
              user.headline!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
        onPressed: () {
          // Start a new conversation with this user
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatConversationPage(
                conversationId: '', // Empty means new conversation
                otherUserId: user.id,
              ),
            ),
          );
        },
        tooltip: 'Start conversation',
      ),
      onTap: () {
        // Start a new conversation with this user
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationPage(
              conversationId: '', // Empty means new conversation
              otherUserId: user.id,
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
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
    return BlocProvider(
      create: (context) => getIt<ChatBloc>()
        ..add(const ChatConversationsRequested()),
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
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start a conversation to see it here',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            );
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
}

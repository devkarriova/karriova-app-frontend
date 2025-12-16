import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/header/app_header.dart';
import '../../../../core/widgets/navigation/app_navigation_bar.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import '../widgets/create_post_card.dart';
import '../widgets/post_card.dart';

/// Activity feed page - Enterprise-level implementation with BLoC pattern
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FeedBloc>()..add(const FeedLoadRequested()),
      child: const _FeedPageContent(),
    );
  }
}

class _FeedPageContent extends StatefulWidget {
  const _FeedPageContent();

  @override
  State<_FeedPageContent> createState() => _FeedPageContentState();
}

class _FeedPageContentState extends State<_FeedPageContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && context.read<FeedBloc>().state.canLoadMore) {
      context.read<FeedBloc>().add(const FeedLoadMoreRequested());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        children: [
          AppNavigationBar(currentRoute: AppRouter.feed),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.55,
                ),
                child: BlocConsumer<FeedBloc, FeedState>(
                  listener: (context, state) {
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    if (state.successMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.successMessage!),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.status == FeedStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == FeedStatus.error && state.posts.isEmpty) {
                      return _buildErrorState(context);
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<FeedBloc>().add(const FeedRefreshRequested());
                        await context.read<FeedBloc>().stream.firstWhere(
                              (s) => s.status != FeedStatus.refreshing,
                            );
                      },
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: state.posts.isEmpty ? 2 : state.posts.length + 2,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // Get current user from AuthBloc
                              final authState = context.watch<AuthBloc>().state;
                              final user = authState.user;

                              return CreatePostCard(
                                userInitials: _generateUserInitials(user?.name, user?.email),
                                userImageUrl: user?.photoUrl,
                                onPostTap: (content, images) {
                                  if (content.isNotEmpty || images.isNotEmpty) {
                                    context.read<FeedBloc>().add(
                                          FeedPostCreated(
                                            content: content,
                                            images: images,
                                          ),
                                        );
                                  }
                                },
                              );
                            }

                            // Show empty state after CreatePostCard when there are no posts
                            if (state.posts.isEmpty && index == 1) {
                              return Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: _buildEmptyFeedMessage(),
                              );
                            }

                            if (index == state.posts.length + 1) {
                              return state.status == FeedStatus.loadingMore
                                  ? const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(child: CircularProgressIndicator()),
                                    )
                                  : const SizedBox.shrink();
                            }

                            final post = state.posts[index - 1];
                            return PostCard(
                              userName: 'User ${post.userId}',
                              userTitle: 'User Title',
                              timeAgo: _getTimeAgo(post.createdAt),
                              content: post.content,
                              hashtags: _extractHashtags(post.content),
                              likes: post.likeCount,
                              comments: post.commentCount,
                              shares: post.shareCount,
                              userInitials: 'U',
                              imageUrls: post.attachments.map((a) => a.fileUrl).toList(),
                              onLike: () {
                                context.read<FeedBloc>().add(
                                      FeedPostLikeToggled(
                                        postId: post.id,
                                        isCurrentlyLiked: post.isLiked,
                                      ),
                                    );
                              },
                              onComment: () {},
                              onShare: () {
                                context.read<FeedBloc>().add(FeedPostShared(postId: post.id));
                              },
                              onSave: () {},
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Failed to load feed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            context.read<FeedBloc>().state.errorMessage ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<FeedBloc>().add(const FeedLoadRequested()),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFeedMessage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No posts yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Be the first to create a post!', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 365) return '${(difference.inDays / 365).floor()}y ago';
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()}mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  List<String> _extractHashtags(String content) {
    final regex = RegExp(r'#\w+');
    return regex.allMatches(content).map((m) => m.group(0)!).toList();
  }

  String _generateUserInitials(String? name, String? email) {
    // Try to generate from name first
    if (name != null && name.trim().isNotEmpty) {
      final nameParts = name.trim().split(RegExp(r'\s+'));
      if (nameParts.length >= 2) {
        return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
      } else if (nameParts[0].length >= 2) {
        return nameParts[0].substring(0, 2).toUpperCase();
      } else if (nameParts[0].isNotEmpty) {
        return nameParts[0][0].toUpperCase();
      }
    }

    // Fallback to email
    if (email != null && email.isNotEmpty) {
      final emailParts = email.split('@');
      if (emailParts[0].length >= 2) {
        return emailParts[0].substring(0, 2).toUpperCase();
      } else if (emailParts[0].isNotEmpty) {
        return emailParts[0][0].toUpperCase();
      }
    }

    // Final fallback
    return '?';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/models/comment_model.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import 'post_card.dart';

/// Post card with inline expandable comments
class PostCardWithComments extends StatefulWidget {
  final String postId;
  final String userName;
  final String userTitle;
  final String timeAgo;
  final String content;
  final List<String> hashtags;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final String userInitials;
  final String? userImageUrl;
  final List<String> imageUrls;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const PostCardWithComments({
    super.key,
    required this.postId,
    required this.userName,
    required this.userTitle,
    required this.timeAgo,
    required this.content,
    this.hashtags = const [],
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
    required this.userInitials,
    this.userImageUrl,
    this.imageUrls = const [],
    this.onLike,
    this.onShare,
    this.onSave,
  });

  @override
  State<PostCardWithComments> createState() => _PostCardWithCommentsState();
}

class _PostCardWithCommentsState extends State<PostCardWithComments> with TickerProviderStateMixin {
  bool _isCommentsExpanded = false;
  bool _commentsLoaded = false;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScale;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _sendButtonController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  void _toggleComments() {
    setState(() {
      _isCommentsExpanded = !_isCommentsExpanded;
    });

    if (_isCommentsExpanded && !_commentsLoaded) {
      context.read<FeedBloc>().add(FeedCommentFetchRequested(postId: widget.postId));
      setState(() {
        _commentsLoaded = true;
      });
    }
  }

  void _addComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    // Trigger send button animation
    _sendButtonController.forward().then((_) {
      if (mounted) {
        _sendButtonController.reverse();
      }
    });

    context.read<FeedBloc>().add(
          FeedCommentAddRequested(
            postId: widget.postId,
            content: content,
          ),
        );

    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Original Post Card (without comment button callback)
          PostCard(
            userName: widget.userName,
            userTitle: widget.userTitle,
            timeAgo: widget.timeAgo,
            content: widget.content,
            hashtags: widget.hashtags,
            likes: widget.likes,
            comments: widget.comments,
            shares: widget.shares,
            isLiked: widget.isLiked,
            userInitials: widget.userInitials,
            userImageUrl: widget.userImageUrl,
            imageUrls: widget.imageUrls,
            onLike: widget.onLike,
            onComment: _toggleComments, // Toggle inline comments
            onShare: widget.onShare,
            onSave: widget.onSave,
          ),

          // Inline Comments Section
          if (_isCommentsExpanded) ...[
            const Divider(height: 1),
            BlocBuilder<FeedBloc, FeedState>(
              builder: (context, state) {
                final isLoading = state.commentsLoading[widget.postId] ?? false;
                final comments = state.comments[widget.postId] ?? [];

                if (isLoading && comments.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Comments list
                    if (comments.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: comments.length > 3 && !_commentsLoaded
                            ? 3
                            : comments.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          indent: 60,
                        ),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return _CommentItem(comment: comment);
                        },
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No comments yet. Be the first to comment!',
                          style: TextStyle(
                            fontSize: AppDimensions.fontSM,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                    // Show more button if there are more comments
                    if (comments.length > 3 && !_commentsLoaded)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _commentsLoaded = true;
                          });
                        },
                        child: Text(
                          'View all ${comments.length} comments',
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSM,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                    // Add comment input
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceVariant,
                        border: Border(
                          top: BorderSide(color: AppColors.divider),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              widget.userInitials.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: AppDimensions.fontSM,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              focusNode: _commentFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Write a comment...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: AppDimensions.fontSM,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                suffixIcon: AnimatedBuilder(
                                  animation: _sendButtonScale,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _sendButtonScale.value,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.send,
                                          size: 20,
                                          color: AppColors.primary,
                                        ),
                                        onPressed: _addComment,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _addComment(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual comment item widget
class _CommentItem extends StatelessWidget {
  final CommentModel comment;

  const _CommentItem({required this.comment});

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            backgroundImage: comment.userPhotoUrl != null && comment.userPhotoUrl!.isNotEmpty
                ? NetworkImage(comment.userPhotoUrl!)
                : null,
            child: comment.userPhotoUrl == null || comment.userPhotoUrl!.isEmpty
                ? Text(
                    comment.userInitials.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: AppDimensions.fontSM,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // User name
                      Text(
                        comment.userName ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSM,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Time ago
                      Text(
                        _getTimeAgo(comment.createdAt),
                        style: TextStyle(
                          fontSize: AppDimensions.fontXS,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Comment text
                  Text(
                    comment.content,
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSM,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

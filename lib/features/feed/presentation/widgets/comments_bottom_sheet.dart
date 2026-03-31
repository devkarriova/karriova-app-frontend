import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/models/comment_model.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';

/// Comments bottom sheet - displays comments for a post
class CommentsBottomSheet extends StatefulWidget {
  final String postId;

  const CommentsBottomSheet({
    super.key,
    required this.postId,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Fetch comments when sheet opens
    _refreshComments();
  }

  @override
  void didUpdateWidget(CommentsBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh comments if postId changes
    if (oldWidget.postId != widget.postId) {
      _refreshComments();
    }
  }

  void _refreshComments() {
    context.read<FeedBloc>().add(FeedCommentFetchRequested(postId: widget.postId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    context.read<FeedBloc>().add(
          FeedCommentAddRequested(
            postId: widget.postId,
            content: content,
          ),
        );

    _commentController.clear();

    // Scroll to bottom after adding comment
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: AppDimensions.fontXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          // Comments list
          Expanded(
            child: BlocBuilder<FeedBloc, FeedState>(
              builder: (context, state) {
                final isLoading = state.commentsLoading[widget.postId] ?? false;
                final comments = state.comments[widget.postId] ?? [];

                if (isLoading && comments.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet',
                          style: TextStyle(
                            fontSize: AppDimensions.fontLG,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to comment!',
                          style: TextStyle(
                            fontSize: AppDimensions.fontMD,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshComments();
                    // Wait a bit for the comments to load
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  color: AppColors.primary,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: comments.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return _CommentItem(comment: comment);
                    },
                  ),
                );
              },
            ),
          ),

          // Comment input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: AppDimensions.fontMD,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addComment,
                    icon: const Icon(Icons.send),
                    color: AppColors.primary,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      padding: const EdgeInsets.all(12),
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
            radius: 20,
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
                      fontSize: AppDimensions.fontMD,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // User name
                    Text(
                      comment.userName ?? 'Unknown User',
                      style: const TextStyle(
                        fontSize: AppDimensions.fontMD,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Time ago
                    Text(
                      _getTimeAgo(comment.createdAt),
                      style: TextStyle(
                        fontSize: AppDimensions.fontSM,
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
                    fontSize: AppDimensions.fontMD,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

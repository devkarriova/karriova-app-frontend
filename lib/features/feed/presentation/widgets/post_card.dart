import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Post card widget - displays a single post in the feed
class PostCard extends StatelessWidget {
  final String userName;
  final String userTitle;
  final String timeAgo;
  final String content;
  final List<String> hashtags;
  final int likes;
  final int comments;
  final int shares;
  final String userInitials;
  final String? userImageUrl;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const PostCard({
    super.key,
    required this.userName,
    required this.userTitle,
    required this.timeAgo,
    required this.content,
    this.hashtags = const [],
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    required this.userInitials,
    this.userImageUrl,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
  });

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - User info and time
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  backgroundImage: userImageUrl != null
                      ? NetworkImage(userImageUrl!)
                      : null,
                  child: userImageUrl == null
                      ? Text(
                          userInitials.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: AppDimensions.fontXL,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontLG,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userTitle,
                        style: TextStyle(
                          fontSize: AppDimensions.fontSM,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: AppDimensions.fontXS,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: AppDimensions.fontMD,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Hashtags
          if (hashtags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: hashtags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontSM,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Engagement stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '$likes likes',
                  style: TextStyle(
                    fontSize: AppDimensions.fontSM,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$comments comments',
                  style: TextStyle(
                    fontSize: AppDimensions.fontSM,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$shares shares',
                  style: TextStyle(
                    fontSize: AppDimensions.fontSM,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 4),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: Icons.favorite_border,
                  label: 'Like',
                  onTap: onLike,
                ),
                _ActionButton(
                  icon: Icons.comment_outlined,
                  label: 'Comment',
                  onTap: onComment,
                ),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: onShare,
                ),
                _ActionButton(
                  icon: Icons.bookmark_border,
                  label: 'Save',
                  onTap: onSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button widget for post interactions
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppDimensions.iconXS, color: Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: AppDimensions.fontMD,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

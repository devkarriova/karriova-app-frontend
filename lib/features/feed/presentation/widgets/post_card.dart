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
  final bool isLiked;
  final String userInitials;
  final String? userImageUrl;
  final List<String> imageUrls;
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
    this.isLiked = false,
    required this.userInitials,
    this.userImageUrl,
    this.imageUrls = const [],
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
                  backgroundImage: userImageUrl != null && userImageUrl!.isNotEmpty
                      ? NetworkImage(userImageUrl!)
                      : null,
                  child: userImageUrl == null || userImageUrl!.isEmpty
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

          // Post Content with hashtag highlighting
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildContentWithHashtags(),
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

          // Post Images
          if (imageUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildImageGrid(),
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
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: 'Like',
                  onTap: onLike,
                  color: isLiked ? Colors.red : Colors.grey[700],
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

  /// Build content text with highlighted hashtags
  Widget _buildContentWithHashtags() {
    final RegExp hashtagRegex = RegExp(r'#\w+');
    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in hashtagRegex.allMatches(content)) {
      // Add normal text before hashtag
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: content.substring(lastMatchEnd, match.start),
            style: const TextStyle(
              fontSize: AppDimensions.fontMD,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }

      // Add hashtag with primary color
      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(
            fontSize: AppDimensions.fontMD,
            height: 1.5,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add remaining text
    if (lastMatchEnd < content.length) {
      spans.add(
        TextSpan(
          text: content.substring(lastMatchEnd),
          style: const TextStyle(
            fontSize: AppDimensions.fontMD,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans.isEmpty ? [
        TextSpan(
          text: content,
          style: const TextStyle(
            fontSize: AppDimensions.fontMD,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
        ),
      ] : spans),
    );
  }

  /// Build image grid based on number of images
  Widget _buildImageGrid() {
    final imageCount = imageUrls.length;

    if (imageCount == 0) return const SizedBox.shrink();

    if (imageCount == 1) {
      // Single image - full width
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrls[0],
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 250,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 250,
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (imageCount == 2) {
      // Two images - side by side
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(child: _buildImageItem(imageUrls[0], 200)),
            const SizedBox(width: 4),
            Expanded(child: _buildImageItem(imageUrls[1], 200)),
          ],
        ),
      );
    } else if (imageCount == 3) {
      // Three images - 1 large on left, 2 stacked on right
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildImageItem(imageUrls[0], 250),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildImageItem(imageUrls[1], 123),
                  const SizedBox(height: 4),
                  _buildImageItem(imageUrls[2], 123),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // 4+ images - 2x2 grid with counter for remaining
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: imageCount > 4 ? 4 : imageCount,
          itemBuilder: (context, index) {
            if (index == 3 && imageCount > 4) {
              // Show "+N more" overlay on 4th image
              return Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageItem(imageUrls[index], 150),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '+${imageCount - 4}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return _buildImageItem(imageUrls[index], 150);
          },
        ),
      );
    }
  }

  /// Build individual image item
  Widget _buildImageItem(String url, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Action button widget for post interactions with animations
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      _controller.forward().then((_) {
        if (mounted) {
          _controller.reverse();
        }
      });
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? Colors.grey[700];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(8),
              splashColor: (widget.color ?? AppColors.primary).withOpacity(0.2),
              highlightColor: (widget.color ?? AppColors.primary).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: _iconScaleAnimation.value,
                      child: Icon(
                        widget.icon,
                        size: AppDimensions.iconXS,
                        color: buttonColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: AppDimensions.fontMD,
                        fontWeight: FontWeight.w500,
                        color: buttonColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

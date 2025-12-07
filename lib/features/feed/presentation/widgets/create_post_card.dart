import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Create post card widget - allows users to create a new post
class CreatePostCard extends StatefulWidget {
  final String userInitials;
  final String? userImageUrl;
  final VoidCallback? onImageTap;
  final Function(String)? onPostTap;

  const CreatePostCard({
    super.key,
    required this.userInitials,
    this.userImageUrl,
    this.onImageTap,
    this.onPostTap,
  });

  @override
  State<CreatePostCard> createState() => _CreatePostCardState();
}

class _CreatePostCardState extends State<CreatePostCard> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input field with avatar
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  backgroundImage: widget.userImageUrl != null
                      ? NetworkImage(widget.userImageUrl!)
                      : null,
                  child: widget.userImageUrl == null
                      ? Text(
                          widget.userInitials.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Input field
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts, achievements, or questions with the community...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons row
            Row(
              children: [
                _ActionButton(
                  icon: Icons.image_outlined,
                  label: 'Image',
                  onTap: widget.onImageTap,
                ),
                const Spacer(),
                // Post button
                IconButton(
                  onPressed: () {
                    if (widget.onPostTap != null && _textController.text.trim().isNotEmpty) {
                      widget.onPostTap!(_textController.text.trim());
                      _textController.clear();
                    }
                  },
                  icon: const Icon(Icons.send, size: 22),
                  color: AppColors.primary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Action button widget for create post options
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
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

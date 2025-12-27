import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/message_model.dart';

/// Message bubble widget - displays a single message
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSentByMe;
  final String? senderName;
  final String? senderPhotoUrl;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    this.senderName,
    this.senderPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByMe) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isSentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(context),
                const SizedBox(height: 4),
                _buildTimestamp(),
              ],
            ),
          ),
          if (isSentByMe) ...[
            const SizedBox(width: 8),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (senderPhotoUrl != null && senderPhotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(senderPhotoUrl!),
      );
    }

    // Show initials if name is available
    final initials = _getInitials(senderName ?? 'U');
    return CircleAvatar(
      radius: 16,
      backgroundColor: isSentByMe ? AppColors.primary : AppColors.surfaceVariant,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSentByMe ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSentByMe ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isSentByMe ? 16 : 4),
          bottomRight: Radius.circular(isSentByMe ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageContent(),
          if (message.isRead && isSentByMe) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.done_all,
                  size: 14,
                  color: isSentByMe ? Colors.white70 : AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Read',
                  style: TextStyle(
                    fontSize: 10,
                    color: isSentByMe ? Colors.white70 : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.messageType) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 15,
            color: isSentByMe ? Colors.white : AppColors.textPrimary,
            height: 1.4,
          ),
        );
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.attachmentUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.attachmentUrl!,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 150,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.broken_image),
                    );
                  },
                ),
              ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  color: isSentByMe ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ],
        );
      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file,
              size: 18,
              color: isSentByMe ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  color: isSentByMe ? Colors.white : AppColors.textPrimary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        );
    }
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Text(
        _formatTime(message.createdAt),
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time only
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat('EEE h:mm a').format(dateTime);
    } else {
      // Older - show date
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

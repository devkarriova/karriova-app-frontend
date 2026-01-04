import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/message_model.dart';

/// Message bubble widget - displays a single message
/// Modern design with gradient sent messages, smooth corners, and elegant typography
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSentByMe;
  final String? senderName;
  final String? senderPhotoUrl;
  final bool showAvatar;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    this.senderName,
    this.senderPhotoUrl,
    this.showAvatar = true,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isSentByMe ? 60 : 16,
        right: isSentByMe ? 16 : 60,
        top: isFirstInGroup ? 8 : 2,
        bottom: isLastInGroup ? 8 : 2,
      ),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByMe && showAvatar && isLastInGroup) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ] else if (!isSentByMe && showAvatar) ...[
            const SizedBox(width: 40), // Placeholder for avatar alignment
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isSentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(context),
                if (isLastInGroup) ...[
                  const SizedBox(height: 4),
                  _buildTimestamp(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (senderPhotoUrl != null && senderPhotoUrl!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(senderPhotoUrl!),
          backgroundColor: AppColors.surfaceVariant,
        ),
      );
    }

    // Show initials with gradient
    final initials = _getInitials(senderName ?? 'U');
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isSentByMe ? 20 : (isLastInGroup ? 6 : 20)),
      bottomRight: Radius.circular(isSentByMe ? (isLastInGroup ? 6 : 20) : 20),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isSentByMe
            ? const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSentByMe ? null : AppColors.surface,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: isSentByMe
                ? AppColors.primary.withOpacity(0.25)
                : Colors.black.withOpacity(0.06),
            blurRadius: isSentByMe ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: isSentByMe
            ? null
            : Border.all(color: AppColors.border.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageContent(),
          if (message.isRead && isSentByMe) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.done_all,
                        size: 12,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Seen',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
            letterSpacing: 0.1,
          ),
        );
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.attachmentUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Image.network(
                    message.attachmentUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 200,
                        height: 150,
                        decoration: BoxDecoration(
                          color: isSentByMe
                              ? Colors.white.withOpacity(0.2)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color:
                                isSentByMe ? Colors.white : AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 150,
                        decoration: BoxDecoration(
                          color: isSentByMe
                              ? Colors.white.withOpacity(0.2)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 32,
                              color: isSentByMe
                                  ? Colors.white70
                                  : AppColors.textTertiary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image unavailable',
                              style: TextStyle(
                                fontSize: 12,
                                color: isSentByMe
                                    ? Colors.white70
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  color: isSentByMe ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ],
        );
      case MessageType.file:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSentByMe
                ? Colors.white.withOpacity(0.15)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSentByMe
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  size: 20,
                  color: isSentByMe ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isSentByMe ? Colors.white : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to open',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSentByMe
                            ? Colors.white70
                            : AppColors.textTertiary,
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

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

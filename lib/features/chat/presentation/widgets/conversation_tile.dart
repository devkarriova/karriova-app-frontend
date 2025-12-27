import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/conversation_model.dart';

/// Conversation tile widget - displays a conversation in the list
class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherUserName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(conversation.lastMessageAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: conversation.unreadCount > 0
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          fontWeight: conversation.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: conversation.unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                          ),
                          child: Text(
                            conversation.unreadCount > 99
                                ? '99+'
                                : conversation.unreadCount.toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (otherUserPhotoUrl != null && otherUserPhotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(otherUserPhotoUrl!),
      );
    }

    // Show initials
    final initials = _getInitials(otherUserName);
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
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
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat('EEE').format(dateTime);
    } else {
      // Older - show date
      return DateFormat('MMM d').format(dateTime);
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

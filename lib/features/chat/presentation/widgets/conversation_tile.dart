import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/conversation_model.dart';

/// Conversation tile widget - displays a conversation in the list
/// Modern design with online status, gradient accents, and smooth animations
class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final VoidCallback onTap;
  final bool isOnline;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    required this.onTap,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withOpacity(0.08),
        highlightColor: AppColors.primary.withOpacity(0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: hasUnread
                ? AppColors.primary.withOpacity(0.03)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: hasUnread ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            otherUserName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  hasUnread ? FontWeight.w700 : FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildTimeIndicator(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage,
                            style: TextStyle(
                              fontSize: 14,
                              color: hasUnread
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight:
                                  hasUnread ? FontWeight.w500 : FontWeight.w400,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 12),
                          _buildUnreadBadge(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeIndicator() {
    final hasUnread = conversation.unreadCount > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:
            hasUnread ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _formatTime(conversation.lastMessageAt),
        style: TextStyle(
          fontSize: 11,
          color: hasUnread ? AppColors.primary : AppColors.textTertiary,
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(minWidth: 22),
      child: Text(
        conversation.unreadCount > 99
            ? '99+'
            : conversation.unreadCount.toString(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.secondary.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(2),
          child: _buildAvatarContent(),
        ),
        if (isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (otherUserPhotoUrl != null && otherUserPhotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage(otherUserPhotoUrl!),
        backgroundColor: AppColors.surfaceVariant,
      );
    }

    // Show initials with gradient background
    final initials = _getInitials(otherUserName);
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
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
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

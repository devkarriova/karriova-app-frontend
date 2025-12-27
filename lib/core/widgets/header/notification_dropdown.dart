import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../../features/notifications/presentation/bloc/notification_event.dart';
import '../../../features/notifications/presentation/bloc/notification_state.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';

/// Dropdown modal showing recent notifications
class NotificationDropdown extends StatelessWidget {
  const NotificationDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: AppDimensions.fontLG,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dropdown
                    context.go('/notifications'); // Navigate to full page
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: AppDimensions.fontSM,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notification list (recent 5)
          Flexible(
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state.status == NotificationStatus.loading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state.status == NotificationStatus.error) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load notifications',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                if (state.notifications.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: AppDimensions.fontMD,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Show only first 5 notifications
                final recentNotifications = state.notifications.take(5).toList();

                return ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: recentNotifications.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final notification = recentNotifications[index];
                    return _NotificationItem(
                      title: notification.actorFullName ?? notification.actorUsername ?? 'Someone',
                      message: notification.message,
                      time: _getTimeAgo(notification.createdAt),
                      isRead: notification.isRead,
                      icon: _getNotificationIcon(notification.type.name),
                      iconColor: _getNotificationColor(notification.type.name),
                      onTap: () {
                        // Mark as read when tapped
                        context.read<NotificationBloc>().add(
                              NotificationMarkAsReadRequested(
                                notificationId: notification.id,
                              ),
                            );
                        Navigator.pop(context); // Close dropdown
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'follow':
        return Icons.person_add;
      case 'mention':
        return Icons.alternate_email;
      case 'share':
        return Icons.share;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'follow':
        return Colors.green;
      case 'mention':
        return Colors.orange;
      case 'share':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()}mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}

/// Individual notification item widget
class _NotificationItem extends StatefulWidget {
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  State<_NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<_NotificationItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: widget.isRead
            ? (_isHovered ? Colors.grey[50] : Colors.white)
            : (_isHovered ? AppColors.primary.withOpacity(0.08) : AppColors.primary.withOpacity(0.05)),
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color: widget.iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: AppDimensions.fontSM,
                          fontWeight: widget.isRead ? FontWeight.normal : FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: AppDimensions.fontXS,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.time,
                        style: TextStyle(
                          fontSize: AppDimensions.fontXS,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                // Unread indicator
                if (!widget.isRead)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

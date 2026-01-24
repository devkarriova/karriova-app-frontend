import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/header/app_header.dart';
import '../../domain/models/notification_model.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

/// Minimalist notifications page with BLoC integration
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<NotificationBloc>()
        ..add(const NotificationsLoadRequested()),
      child: const _NotificationsPageContent(),
    );
  }
}

class _NotificationsPageContent extends StatelessWidget {
  const _NotificationsPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(),
      body: Column(
        children: [
          // Notifications header with title and actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (state.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              state.unreadCount.toString(),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const Spacer(),
                // Filter toggle
                BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    return IconButton(
                      icon: Icon(
                        state.showOnlyUnread
                            ? Icons.filter_alt
                            : Icons.filter_alt_outlined,
                        color: state.showOnlyUnread
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      onPressed: () {
                        context
                            .read<NotificationBloc>()
                            .add(const NotificationFilterToggled());
                      },
                      tooltip: 'Filter unread',
                    );
                  },
                ),
                // Mark all as read
                BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    return IconButton(
                      icon: const Icon(Icons.done_all, color: AppColors.textSecondary),
                      onPressed: state.unreadCount > 0
                          ? () {
                              context
                                  .read<NotificationBloc>()
                                  .add(const NotificationMarkAllAsReadRequested());
                            }
                          : null,
                      tooltip: 'Mark all as read',
                    );
                  },
                ),
              ],
            ),
          ),
          // Notification list
          Expanded(
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state.status == NotificationStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

          if (state.status == NotificationStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'An error occurred',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      context
                          .read<NotificationBloc>()
                          .add(const NotificationsLoadRequested(isRefresh: true));
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Filter notifications based on showOnlyUnread
          final displayedNotifications = state.showOnlyUnread
              ? state.notifications.where((n) => !n.isRead).toList()
              : state.notifications;

          if (displayedNotifications.isEmpty) {
            return _buildEmptyState(
              icon: state.showOnlyUnread
                  ? Icons.notifications_none
                  : Icons.notifications_outlined,
              title: state.showOnlyUnread
                  ? 'No unread notifications'
                  : 'No notifications yet',
              subtitle: state.showOnlyUnread
                  ? 'You\'re all caught up!'
                  : 'When you get notifications, they\'ll show up here',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<NotificationBloc>()
                  .add(const NotificationsLoadRequested(isRefresh: true));
              // Wait for loading to complete
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: displayedNotifications.length +
                  (state.hasMore && !state.showOnlyUnread ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                // Load more indicator
                if (index == displayedNotifications.length) {
                  if (state.isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: OutlinedButton(
                        onPressed: () {
                          context
                              .read<NotificationBloc>()
                              .add(const NotificationsLoadMoreRequested());
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text('Load more'),
                      ),
                    ),
                  );
                }

                final notification = displayedNotifications[index];
                return _buildNotificationCard(
                  context: context,
                  notification: notification,
                  onTap: () => _handleNotificationTap(context, notification),
                  onDelete: () => _handleNotificationDelete(context, notification),
                );
              },
            ),
          );
                },
              ),
            ),
          ],
        ),
      );
    }

  Widget _buildNotificationCard({
    required BuildContext context,
    required NotificationModel notification,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    final IconData icon;
    final Color iconColor;

    switch (notification.type) {
      case NotificationType.like:
        icon = Icons.favorite;
        iconColor = Colors.red;
        break;
      case NotificationType.comment:
        icon = Icons.chat_bubble;
        iconColor = AppColors.primary;
        break;
      case NotificationType.follow:
        icon = Icons.person_add;
        iconColor = AppColors.secondary;
        break;
      case NotificationType.mention:
        icon = Icons.alternate_email;
        iconColor = AppColors.info;
        break;
      case NotificationType.message:
        icon = Icons.mail;
        iconColor = AppColors.primary;
        break;
      case NotificationType.connectionRequest:
        icon = Icons.person_add_alt;
        iconColor = AppColors.secondary;
        break;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: AppColors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete notification'),
              content: const Text('Are you sure you want to delete this notification?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: InkWell(
        onTap: () {
          // Mark as read when tapped
          if (!notification.isRead) {
            context
                .read<NotificationBloc>()
                .add(NotificationMarkAsReadRequested(notificationId: notification.id));
          }
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead ? AppColors.white : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.divider
                  : AppColors.primary.withOpacity(0.2),
              width: notification.isRead ? 1 : 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Actor avatar with notification icon
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.surfaceVariant,
                    backgroundImage: notification.actorPhotoUrl != null
                        ? NetworkImage(notification.actorPhotoUrl!)
                        : null,
                    child: notification.actorPhotoUrl == null
                        ? Text(
                            notification.actorInitials,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: Icon(
                        icon,
                        size: 12,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text: notification.actorFullName ?? notification.actorUsername,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: ' ${notification.message}',
                            style: TextStyle(
                              color: notification.isRead
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.getTimeAgo(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Unread indicator
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(
      BuildContext context, NotificationModel notification) {
    // TODO: Navigate to relevant screen based on notification type
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped: ${notification.type.name}'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleNotificationDelete(
      BuildContext context, NotificationModel notification) {
    context
        .read<NotificationBloc>()
        .add(NotificationDeleteRequested(notificationId: notification.id));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

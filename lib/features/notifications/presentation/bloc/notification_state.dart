import 'package:equatable/equatable.dart';
import '../../domain/models/notification_model.dart';

enum NotificationStatus {
  initial,
  loading,
  success,
  error,
  loadingMore,
}

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool showOnlyUnread;
  final String? errorMessage;
  final bool hasMore;
  final int currentOffset;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.showOnlyUnread = false,
    this.errorMessage,
    this.hasMore = true,
    this.currentOffset = 0,
  });

  bool get isLoading => status == NotificationStatus.loading;
  bool get isLoadingMore => status == NotificationStatus.loadingMore;
  bool get hasError => status == NotificationStatus.error;
  bool get hasNotifications => notifications.isNotEmpty;

  List<NotificationModel> get filteredNotifications {
    if (showOnlyUnread) {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications;
  }

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? showOnlyUnread,
    String? errorMessage,
    bool? hasMore,
    int? currentOffset,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      showOnlyUnread: showOnlyUnread ?? this.showOnlyUnread,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        unreadCount,
        showOnlyUnread,
        errorMessage,
        hasMore,
        currentOffset,
      ];
}

import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Load notifications
class NotificationsLoadRequested extends NotificationEvent {
  final bool isRefresh;

  const NotificationsLoadRequested({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Load more notifications (pagination)
class NotificationsLoadMoreRequested extends NotificationEvent {
  const NotificationsLoadMoreRequested();
}

/// Refresh unread count
class UnreadCountRefreshRequested extends NotificationEvent {
  const UnreadCountRefreshRequested();
}

/// Mark notification as read
class NotificationMarkAsReadRequested extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsReadRequested({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read
class NotificationMarkAllAsReadRequested extends NotificationEvent {
  const NotificationMarkAllAsReadRequested();
}

/// Delete notification
class NotificationDeleteRequested extends NotificationEvent {
  final String notificationId;

  const NotificationDeleteRequested({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Toggle filter (show only unread)
class NotificationFilterToggled extends NotificationEvent {
  const NotificationFilterToggled();
}

/// Connect to WebSocket for real-time notifications
class NotificationWebSocketConnectRequested extends NotificationEvent {
  const NotificationWebSocketConnectRequested();
}

/// Disconnect from WebSocket
class NotificationWebSocketDisconnectRequested extends NotificationEvent {
  const NotificationWebSocketDisconnectRequested();
}

/// Notification received via WebSocket
class NotificationReceivedViaWebSocket extends NotificationEvent {
  final dynamic notification;

  const NotificationReceivedViaWebSocket({required this.notification});

  @override
  List<Object?> get props => [notification];
}

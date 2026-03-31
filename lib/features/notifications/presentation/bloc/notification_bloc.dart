import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/datasources/notification_websocket_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;
  final NotificationWebSocketService? notificationWebSocketService;
  static const int _pageSize = 20;
  StreamSubscription? _notificationStreamSubscription;

  NotificationBloc({
    required this.notificationRepository,
    this.notificationWebSocketService,
  }) : super(const NotificationState()) {
    on<NotificationsLoadRequested>(_onLoadNotifications);
    on<NotificationsLoadMoreRequested>(_onLoadMore);
    on<UnreadCountRefreshRequested>(_onRefreshUnreadCount);
    on<NotificationMarkAsReadRequested>(_onMarkAsRead);
    on<NotificationMarkAllAsReadRequested>(_onMarkAllAsRead);
    on<NotificationDeleteRequested>(_onDeleteNotification);
    on<NotificationFilterToggled>(_onFilterToggled);
    on<NotificationWebSocketConnectRequested>(_onWebSocketConnect);
    on<NotificationWebSocketDisconnectRequested>(_onWebSocketDisconnect);
    on<NotificationReceivedViaWebSocket>(_onNotificationReceivedViaWebSocket);
  }

  Future<void> _onLoadNotifications(
    NotificationsLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (event.isRefresh) {
      emit(state.copyWith(
        status: NotificationStatus.loading,
        currentOffset: 0,
      ));
    } else {
      emit(state.copyWith(status: NotificationStatus.loading));
    }

    final result = await notificationRepository.getNotifications(
      limit: _pageSize,
      offset: 0,
    );

    // Extract the result value
    final notifications = result.fold<List<NotificationModel>?>(
      (error) {
        emit(state.copyWith(
          status: NotificationStatus.error,
          errorMessage: error,
        ));
        return null;
      },
      (data) => data,
    );

    // If we got notifications, fetch unread count and emit
    if (notifications != null) {
      final countResult = await notificationRepository.getUnreadCount();
      final unreadCount = countResult.fold((l) => 0, (r) => r);

      emit(state.copyWith(
        status: NotificationStatus.success,
        notifications: notifications,
        unreadCount: unreadCount,
        hasMore: notifications.length >= _pageSize,
        currentOffset: notifications.length,
      ));
    }
  }

  Future<void> _onLoadMore(
    NotificationsLoadMoreRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(status: NotificationStatus.loadingMore));

    final result = await notificationRepository.getNotifications(
      limit: _pageSize,
      offset: state.currentOffset,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: error,
      )),
      (newNotifications) {
        final updatedList = List.of(state.notifications)..addAll(newNotifications);
        emit(state.copyWith(
          status: NotificationStatus.success,
          notifications: updatedList,
          hasMore: newNotifications.length >= _pageSize,
          currentOffset: updatedList.length,
        ));
      },
    );
  }

  Future<void> _onRefreshUnreadCount(
    UnreadCountRefreshRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await notificationRepository.getUnreadCount();
    result.fold(
      (error) => null, // Silently fail for background updates
      (count) => emit(state.copyWith(unreadCount: count)),
    );
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await notificationRepository.markAsRead(event.notificationId);

    result.fold(
      (error) => emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: error,
      )),
      (_) {
        // Update the notification in the list
        final updatedNotifications = state.notifications.map((n) {
          if (n.id == event.notificationId) {
            return NotificationModel(
              id: n.id,
              userId: n.userId,
              actorId: n.actorId,
              type: n.type,
              postId: n.postId,
              commentId: n.commentId,
              message: n.message,
              isRead: true,
              readAt: DateTime.now(),
              createdAt: n.createdAt,
              actorUsername: n.actorUsername,
              actorFullName: n.actorFullName,
              actorPhotoUrl: n.actorPhotoUrl,
            );
          }
          return n;
        }).toList();

        emit(state.copyWith(
          notifications: updatedNotifications,
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
        ));
      },
    );
  }

  Future<void> _onMarkAllAsRead(
    NotificationMarkAllAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await notificationRepository.markAllAsRead();

    result.fold(
      (error) => emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: error,
      )),
      (_) {
        // Mark all notifications as read
        final updatedNotifications = state.notifications.map((n) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            actorId: n.actorId,
            type: n.type,
            postId: n.postId,
            commentId: n.commentId,
            message: n.message,
            isRead: true,
            readAt: DateTime.now(),
            createdAt: n.createdAt,
            actorUsername: n.actorUsername,
            actorFullName: n.actorFullName,
            actorPhotoUrl: n.actorPhotoUrl,
          );
        }).toList();

        emit(state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        ));
      },
    );
  }

  Future<void> _onDeleteNotification(
    NotificationDeleteRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final result =
        await notificationRepository.deleteNotification(event.notificationId);

    result.fold(
      (error) => emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: error,
      )),
      (_) {
        // Remove notification from list
        final updatedNotifications = state.notifications
            .where((n) => n.id != event.notificationId)
            .toList();

        // Decrease unread count if the deleted notification was unread
        final deletedNotification = state.notifications
            .firstWhere((n) => n.id == event.notificationId);
        final newUnreadCount = deletedNotification.isRead
            ? state.unreadCount
            : state.unreadCount - 1;

        emit(state.copyWith(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount > 0 ? newUnreadCount : 0,
        ));
      },
    );
  }

  void _onFilterToggled(
    NotificationFilterToggled event,
    Emitter<NotificationState> emit,
  ) {
    emit(state.copyWith(showOnlyUnread: !state.showOnlyUnread));
  }

  Future<void> _onWebSocketConnect(
    NotificationWebSocketConnectRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (notificationWebSocketService == null) return;

    try {
      await notificationWebSocketService!.connect();

      // Listen to notification stream
      _notificationStreamSubscription?.cancel();
      _notificationStreamSubscription = notificationWebSocketService!.notificationStream.listen(
        (notification) {
          add(NotificationReceivedViaWebSocket(notification: notification));
        },
      );
    } catch (e) {
      // Connection failed - will retry automatically
    }
  }

  void _onWebSocketDisconnect(
    NotificationWebSocketDisconnectRequested event,
    Emitter<NotificationState> emit,
  ) {
    _notificationStreamSubscription?.cancel();
    notificationWebSocketService?.disconnect();
  }

  void _onNotificationReceivedViaWebSocket(
    NotificationReceivedViaWebSocket event,
    Emitter<NotificationState> emit,
  ) {
    // Add new notification to the top of the list
    final newNotification = event.notification as NotificationModel;
    final updatedNotifications = [newNotification, ...state.notifications];

    // Increment unread count
    final newUnreadCount = state.unreadCount + 1;

    emit(state.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    ));
  }

  @override
  Future<void> close() {
    _notificationStreamSubscription?.cancel();
    return super.close();
  }
}

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../domain/models/notification_model.dart';

part 'notification_remote_datasource.g.dart';

@RestApi()
abstract class NotificationRemoteDataSource {
  factory NotificationRemoteDataSource(Dio dio, {String baseUrl}) =
      _NotificationRemoteDataSource;

  @GET('/notifications')
  Future<NotificationsResponse> getNotifications(
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  @GET('/notifications/unread-count')
  Future<UnreadCountResponse> getUnreadCount();

  @PUT('/notifications/{id}/read')
  Future<void> markAsRead(@Path('id') String notificationId);

  @PUT('/notifications/read-all')
  Future<void> markAllAsRead();

  @DELETE('/notifications/{id}')
  Future<void> deleteNotification(@Path('id') String notificationId);
}

class NotificationsResponse {
  final List<NotificationModel> notifications;
  final int count;

  NotificationsResponse({required this.notifications, required this.count});

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      notifications: (json['notifications'] as List?)
              ?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
    );
  }
}

class UnreadCountResponse {
  final int unreadCount;

  UnreadCountResponse({required this.unreadCount});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}

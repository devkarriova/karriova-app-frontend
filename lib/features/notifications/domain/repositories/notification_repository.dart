import 'package:dartz/dartz.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<Either<String, List<NotificationModel>>> getNotifications({
    required int limit,
    required int offset,
  });

  Future<Either<String, int>> getUnreadCount();

  Future<Either<String, void>> markAsRead(String notificationId);

  Future<Either<String, void>> markAllAsRead();

  Future<Either<String, void>> deleteNotification(String notificationId);
}

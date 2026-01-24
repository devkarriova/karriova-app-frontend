import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<NotificationModel>>> getNotifications({
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await remoteDataSource.getNotifications(limit, offset);
      return Right(response.notifications);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to fetch notifications');
    } catch (e) {
      return const Left('An unexpected error occurred');
    }
  }

  @override
  Future<Either<String, int>> getUnreadCount() async {
    try {
      final response = await remoteDataSource.getUnreadCount();
      return Right(response.unreadCount);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to fetch unread count');
    } catch (e) {
      return const Left('An unexpected error occurred');
    }
  }

  @override
  Future<Either<String, void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to mark as read');
    } catch (e) {
      return const Left('An unexpected error occurred');
    }
  }

  @override
  Future<Either<String, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to mark all as read');
    } catch (e) {
      return const Left('An unexpected error occurred');
    }
  }

  @override
  Future<Either<String, void>> deleteNotification(String notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to delete notification');
    } catch (e) {
      return const Left('An unexpected error occurred');
    }
  }
}

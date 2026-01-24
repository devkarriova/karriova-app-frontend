import 'package:dartz/dartz.dart';
import '../../domain/models/event_model.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

/// Implementation of AdminRepository
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  String _handleError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }

  @override
  Future<Either<String, EventListResponse>> getEvents({
    int limit = 20,
    int offset = 0,
    String? status,
    String? search,
  }) async {
    try {
      final result = await remoteDataSource.getEvents(
        limit: limit,
        offset: offset,
        status: status,
        search: search,
      );
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, EventModel>> getEvent(String eventId) async {
    try {
      final result = await remoteDataSource.getEvent(eventId);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, EventModel>> createEvent(Map<String, dynamic> eventData) async {
    try {
      final result = await remoteDataSource.createEvent(eventData);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, EventModel>> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    try {
      final result = await remoteDataSource.updateEvent(eventId, eventData);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> deleteEvent(String eventId) async {
    try {
      await remoteDataSource.deleteEvent(eventId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> publishEvent(String eventId) async {
    try {
      await remoteDataSource.publishEvent(eventId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> toggleEventFeatured(String eventId, bool featured) async {
    try {
      await remoteDataSource.toggleEventFeatured(eventId, featured);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, List<EventCategoryModel>>> getEventCategories() async {
    try {
      final result = await remoteDataSource.getEventCategories();
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
}

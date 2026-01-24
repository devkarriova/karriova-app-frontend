import 'package:dartz/dartz.dart';
import '../models/event_model.dart';

/// Admin repository interface
abstract class AdminRepository {
  // Event Management
  Future<Either<String, EventListResponse>> getEvents({
    int limit = 20,
    int offset = 0,
    String? status,
    String? search,
  });

  Future<Either<String, EventModel>> getEvent(String eventId);

  Future<Either<String, EventModel>> createEvent(Map<String, dynamic> eventData);

  Future<Either<String, EventModel>> updateEvent(String eventId, Map<String, dynamic> eventData);

  Future<Either<String, void>> deleteEvent(String eventId);

  Future<Either<String, void>> publishEvent(String eventId);

  Future<Either<String, void>> toggleEventFeatured(String eventId, bool featured);

  Future<Either<String, List<EventCategoryModel>>> getEventCategories();
}

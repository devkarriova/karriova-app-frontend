import '../../../../core/network/api_client.dart';
import '../../domain/models/event_model.dart';

/// Admin remote data source for API calls
abstract class AdminRemoteDataSource {
  // Event Management
  Future<EventListResponse> getEvents({
    int limit = 20,
    int offset = 0,
    String? status,
    String? search,
  });

  Future<EventModel> getEvent(String eventId);

  Future<EventModel> createEvent(Map<String, dynamic> eventData);

  Future<EventModel> updateEvent(String eventId, Map<String, dynamic> eventData);

  Future<void> deleteEvent(String eventId);

  Future<void> publishEvent(String eventId);

  Future<void> toggleEventFeatured(String eventId, bool featured);

  Future<List<EventCategoryModel>> getEventCategories();
}

/// Implementation of AdminRemoteDataSource
class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<EventListResponse> getEvents({
    int limit = 20,
    int offset = 0,
    String? status,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await apiClient.get(
      '/admin/events',
      requiresAuth: true,
      queryParams: queryParams,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get events');
    }

    return EventListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<EventModel> getEvent(String eventId) async {
    final response = await apiClient.get(
      '/admin/events/$eventId',
      requiresAuth: true,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get event');
    }

    return EventModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<EventModel> createEvent(Map<String, dynamic> eventData) async {
    final response = await apiClient.post(
      '/admin/events',
      requiresAuth: true,
      body: eventData,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to create event');
    }

    return EventModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<EventModel> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    final response = await apiClient.put(
      '/admin/events/$eventId',
      requiresAuth: true,
      body: eventData,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to update event');
    }

    return EventModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final response = await apiClient.delete(
      '/admin/events/$eventId',
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to delete event');
    }
  }

  @override
  Future<void> publishEvent(String eventId) async {
    final response = await apiClient.put(
      '/admin/events/$eventId/publish',
      requiresAuth: true,
      body: {},
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to publish event');
    }
  }

  @override
  Future<void> toggleEventFeatured(String eventId, bool featured) async {
    final response = await apiClient.put(
      '/admin/events/$eventId/feature',
      requiresAuth: true,
      body: {'featured': featured},
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to update featured status');
    }
  }

  @override
  Future<List<EventCategoryModel>> getEventCategories() async {
    final response = await apiClient.get(
      '/admin/events/categories',
      requiresAuth: true,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get categories');
    }

    final List<dynamic> categories = response.data as List<dynamic>;
    return categories
        .map((json) => EventCategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

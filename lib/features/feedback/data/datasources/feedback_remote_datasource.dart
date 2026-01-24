import '../../../../core/network/api_client.dart';
import '../../domain/models/feedback_models.dart';

/// Remote data source interface for feedback feature
abstract class FeedbackRemoteDataSource {
  /// Create a new support ticket
  Future<SupportTicket> createTicket(CreateTicketRequest request);

  /// Get user's own tickets
  Future<TicketListResponse> getMyTickets({int page = 1, int pageSize = 20});

  /// Get a specific ticket by ID
  Future<SupportTicket> getTicket(String ticketId);

  /// Add a response to a ticket (user)
  Future<TicketResponse> addResponse(String ticketId, String message);

  // Admin methods

  /// Get all tickets (admin)
  Future<TicketListResponse> getAllTickets({
    int page = 1,
    int pageSize = 20,
    TicketStatus? status,
    TicketCategory? category,
    TicketPriority? priority,
    String? userId,
  });

  /// Get ticket details (admin)
  Future<SupportTicket> getTicketDetails(String ticketId);

  /// Add admin response to ticket
  Future<TicketResponse> addAdminResponse(String ticketId, String message);

  /// Update ticket status/priority (admin)
  Future<void> updateTicket(
    String ticketId, {
    TicketStatus? status,
    TicketPriority? priority,
    String? assignedTo,
  });

  /// Get ticket statistics (admin)
  Future<TicketStats> getTicketStats();
}

/// Implementation of feedback remote data source
class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final ApiClient _apiClient;

  FeedbackRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<SupportTicket> createTicket(CreateTicketRequest request) async {
    final response = await _apiClient.post(
      '/feedback/tickets',
      requiresAuth: true,
      body: request.toJson(),
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to create ticket');
    }
    return SupportTicket.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TicketListResponse> getMyTickets({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      '/feedback/tickets/my?page=$page&page_size=$pageSize',
      requiresAuth: true,
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to fetch tickets');
    }
    return TicketListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SupportTicket> getTicket(String ticketId) async {
    final response = await _apiClient.get(
      '/feedback/tickets/$ticketId',
      requiresAuth: true,
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to fetch ticket');
    }
    return SupportTicket.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TicketResponse> addResponse(String ticketId, String message) async {
    final response = await _apiClient.post(
      '/feedback/tickets/$ticketId/responses',
      requiresAuth: true,
      body: {'message': message},
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to add response');
    }
    return TicketResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // Admin methods

  @override
  Future<TicketListResponse> getAllTickets({
    int page = 1,
    int pageSize = 20,
    TicketStatus? status,
    TicketCategory? category,
    TicketPriority? priority,
    String? userId,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (status != null) queryParams['status'] = status.toJson();
    if (category != null) queryParams['category'] = category.toJson();
    if (priority != null) queryParams['priority'] = priority.toJson();
    if (userId != null) queryParams['user_id'] = userId;

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final response = await _apiClient.get(
      '/admin/feedback/tickets?$queryString',
      requiresAuth: true,
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to fetch tickets');
    }
    return TicketListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SupportTicket> getTicketDetails(String ticketId) async {
    final response = await _apiClient.get(
      '/admin/feedback/tickets/$ticketId',
      requiresAuth: true,
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to fetch ticket');
    }
    return SupportTicket.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TicketResponse> addAdminResponse(
      String ticketId, String message) async {
    final response = await _apiClient.post(
      '/admin/feedback/tickets/$ticketId/responses',
      requiresAuth: true,
      body: {'message': message},
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to add response');
    }
    return TicketResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> updateTicket(
    String ticketId, {
    TicketStatus? status,
    TicketPriority? priority,
    String? assignedTo,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status.toJson();
    if (priority != null) body['priority'] = priority.toJson();
    if (assignedTo != null) body['assigned_to'] = assignedTo;

    final response = await _apiClient.patch(
      '/admin/feedback/tickets/$ticketId',
      requiresAuth: true,
      body: body,
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to update ticket');
    }
  }

  @override
  Future<TicketStats> getTicketStats() async {
    final response = await _apiClient.get(
      '/admin/feedback/stats',
      requiresAuth: true,
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to fetch stats');
    }
    return TicketStats.fromJson(response.data as Map<String, dynamic>);
  }
}

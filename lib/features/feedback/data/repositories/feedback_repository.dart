import '../datasources/feedback_remote_datasource.dart';
import '../../domain/models/feedback_models.dart';

/// Repository for feedback operations
class FeedbackRepository {
  final FeedbackRemoteDataSource _remoteDataSource;

  FeedbackRepository({required FeedbackRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  /// Create a new support ticket
  Future<SupportTicket> createTicket(CreateTicketRequest request) {
    return _remoteDataSource.createTicket(request);
  }

  /// Get user's own tickets
  Future<TicketListResponse> getMyTickets({int page = 1, int pageSize = 20}) {
    return _remoteDataSource.getMyTickets(page: page, pageSize: pageSize);
  }

  /// Get a specific ticket by ID
  Future<SupportTicket> getTicket(String ticketId) {
    return _remoteDataSource.getTicket(ticketId);
  }

  /// Add a response to a ticket (user)
  Future<TicketResponse> addResponse(String ticketId, String message) {
    return _remoteDataSource.addResponse(ticketId, message);
  }

  // Admin methods

  /// Get all tickets (admin)
  Future<TicketListResponse> getAllTickets({
    int page = 1,
    int pageSize = 20,
    TicketStatus? status,
    TicketCategory? category,
    TicketPriority? priority,
    String? userId,
  }) {
    return _remoteDataSource.getAllTickets(
      page: page,
      pageSize: pageSize,
      status: status,
      category: category,
      priority: priority,
      userId: userId,
    );
  }

  /// Get ticket details (admin)
  Future<SupportTicket> getTicketDetails(String ticketId) {
    return _remoteDataSource.getTicketDetails(ticketId);
  }

  /// Add admin response to ticket
  Future<TicketResponse> addAdminResponse(String ticketId, String message) {
    return _remoteDataSource.addAdminResponse(ticketId, message);
  }

  /// Update ticket status/priority (admin)
  Future<void> updateTicket(
    String ticketId, {
    TicketStatus? status,
    TicketPriority? priority,
    String? assignedTo,
  }) {
    return _remoteDataSource.updateTicket(
      ticketId,
      status: status,
      priority: priority,
      assignedTo: assignedTo,
    );
  }

  /// Get ticket statistics (admin)
  Future<TicketStats> getTicketStats() {
    return _remoteDataSource.getTicketStats();
  }
}

import 'package:equatable/equatable.dart';
import '../../domain/models/feedback_models.dart';

/// Events for admin feedback management BLoC
abstract class AdminFeedbackEvent extends Equatable {
  const AdminFeedbackEvent();

  @override
  List<Object?> get props => [];
}

/// Load all tickets with optional filters
class LoadAllTickets extends AdminFeedbackEvent {
  final int page;
  final int pageSize;
  final TicketStatus? status;
  final TicketCategory? category;
  final TicketPriority? priority;

  const LoadAllTickets({
    this.page = 1,
    this.pageSize = 20,
    this.status,
    this.category,
    this.priority,
  });

  @override
  List<Object?> get props => [page, pageSize, status, category, priority];
}

/// Load ticket details
class LoadAdminTicketDetails extends AdminFeedbackEvent {
  final String ticketId;

  const LoadAdminTicketDetails(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

/// Update ticket status
class UpdateTicketStatus extends AdminFeedbackEvent {
  final String ticketId;
  final TicketStatus status;

  const UpdateTicketStatus({required this.ticketId, required this.status});

  @override
  List<Object?> get props => [ticketId, status];
}

/// Update ticket priority
class UpdateTicketPriority extends AdminFeedbackEvent {
  final String ticketId;
  final TicketPriority priority;

  const UpdateTicketPriority({required this.ticketId, required this.priority});

  @override
  List<Object?> get props => [ticketId, priority];
}

/// Add admin response to ticket
class AddAdminTicketResponse extends AdminFeedbackEvent {
  final String ticketId;
  final String message;

  const AddAdminTicketResponse({required this.ticketId, required this.message});

  @override
  List<Object?> get props => [ticketId, message];
}

/// Load ticket statistics
class LoadTicketStats extends AdminFeedbackEvent {
  const LoadTicketStats();
}

/// Clear selected ticket
class ClearAdminSelectedTicket extends AdminFeedbackEvent {
  const ClearAdminSelectedTicket();
}

/// Apply filters
class ApplyTicketFilters extends AdminFeedbackEvent {
  final TicketStatus? status;
  final TicketCategory? category;
  final TicketPriority? priority;

  const ApplyTicketFilters({
    this.status,
    this.category,
    this.priority,
  });

  @override
  List<Object?> get props => [status, category, priority];
}

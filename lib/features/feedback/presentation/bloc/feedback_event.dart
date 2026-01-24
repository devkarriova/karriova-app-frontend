import 'package:equatable/equatable.dart';
import '../../domain/models/feedback_models.dart';

/// Events for user feedback BLoC
abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object?> get props => [];
}

/// Load user's tickets
class LoadMyTickets extends FeedbackEvent {
  final int page;
  final int pageSize;

  const LoadMyTickets({this.page = 1, this.pageSize = 20});

  @override
  List<Object?> get props => [page, pageSize];
}

/// Create a new ticket
class CreateTicket extends FeedbackEvent {
  final CreateTicketRequest request;

  const CreateTicket(this.request);

  @override
  List<Object?> get props => [request];
}

/// Load ticket details
class LoadTicketDetails extends FeedbackEvent {
  final String ticketId;

  const LoadTicketDetails(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

/// Add response to ticket
class AddTicketResponse extends FeedbackEvent {
  final String ticketId;
  final String message;

  const AddTicketResponse({required this.ticketId, required this.message});

  @override
  List<Object?> get props => [ticketId, message];
}

/// Clear current ticket selection
class ClearSelectedTicket extends FeedbackEvent {
  const ClearSelectedTicket();
}

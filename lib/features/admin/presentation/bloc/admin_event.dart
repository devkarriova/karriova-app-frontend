import 'package:equatable/equatable.dart';
import '../../domain/models/event_model.dart';

/// Admin BLoC events
abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

/// Load events list
class LoadEventsEvent extends AdminEvent {
  final int limit;
  final int offset;
  final String? status;
  final String? search;

  const LoadEventsEvent({
    this.limit = 20,
    this.offset = 0,
    this.status,
    this.search,
  });

  @override
  List<Object?> get props => [limit, offset, status, search];
}

/// Refresh events list
class RefreshEventsEvent extends AdminEvent {
  const RefreshEventsEvent();
}

/// Load single event
class LoadEventEvent extends AdminEvent {
  final String eventId;

  const LoadEventEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// Create new event
class CreateEventEvent extends AdminEvent {
  final Map<String, dynamic> eventData;

  const CreateEventEvent(this.eventData);

  @override
  List<Object?> get props => [eventData];
}

/// Update existing event
class UpdateEventEvent extends AdminEvent {
  final String eventId;
  final Map<String, dynamic> eventData;

  const UpdateEventEvent(this.eventId, this.eventData);

  @override
  List<Object?> get props => [eventId, eventData];
}

/// Delete event
class DeleteEventEvent extends AdminEvent {
  final String eventId;

  const DeleteEventEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// Publish event
class PublishEventEvent extends AdminEvent {
  final String eventId;

  const PublishEventEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// Toggle event featured status
class ToggleEventFeaturedEvent extends AdminEvent {
  final String eventId;
  final bool featured;

  const ToggleEventFeaturedEvent(this.eventId, this.featured);

  @override
  List<Object?> get props => [eventId, featured];
}

/// Load event categories
class LoadCategoriesEvent extends AdminEvent {
  const LoadCategoriesEvent();
}

/// Clear form state
class ClearFormStateEvent extends AdminEvent {
  const ClearFormStateEvent();
}

/// Set selected event for editing
class SelectEventForEditEvent extends AdminEvent {
  final EventModel? event;

  const SelectEventForEditEvent(this.event);

  @override
  List<Object?> get props => [event];
}

/// Update filter
class UpdateFilterEvent extends AdminEvent {
  final String? status;
  final String? search;

  const UpdateFilterEvent({this.status, this.search});

  @override
  List<Object?> get props => [status, search];
}

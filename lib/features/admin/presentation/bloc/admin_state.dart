import 'package:equatable/equatable.dart';
import '../../domain/models/event_model.dart';

/// Form status enum
enum FormStatus { initial, loading, success, failure }

/// Admin BLoC state
class AdminState extends Equatable {
  // Event list state
  final List<EventModel> events;
  final int totalEvents;
  final int totalPages;
  final int currentPage;
  final bool isLoadingEvents;
  final String? eventsError;

  // Categories
  final List<EventCategoryModel> categories;
  final bool isLoadingCategories;

  // Filters
  final String? statusFilter;
  final String? searchQuery;

  // Selected event for viewing/editing
  final EventModel? selectedEvent;
  final bool isLoadingEvent;

  // Form state
  final FormStatus formStatus;
  final String? formError;
  final String? formSuccessMessage;

  const AdminState({
    this.events = const [],
    this.totalEvents = 0,
    this.totalPages = 0,
    this.currentPage = 1,
    this.isLoadingEvents = false,
    this.eventsError,
    this.categories = const [],
    this.isLoadingCategories = false,
    this.statusFilter,
    this.searchQuery,
    this.selectedEvent,
    this.isLoadingEvent = false,
    this.formStatus = FormStatus.initial,
    this.formError,
    this.formSuccessMessage,
  });

  AdminState copyWith({
    List<EventModel>? events,
    int? totalEvents,
    int? totalPages,
    int? currentPage,
    bool? isLoadingEvents,
    String? eventsError,
    List<EventCategoryModel>? categories,
    bool? isLoadingCategories,
    String? statusFilter,
    String? searchQuery,
    EventModel? selectedEvent,
    bool? isLoadingEvent,
    FormStatus? formStatus,
    String? formError,
    String? formSuccessMessage,
    bool clearEventsError = false,
    bool clearFormError = false,
    bool clearSelectedEvent = false,
    bool clearFormSuccessMessage = false,
  }) {
    return AdminState(
      events: events ?? this.events,
      totalEvents: totalEvents ?? this.totalEvents,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      isLoadingEvents: isLoadingEvents ?? this.isLoadingEvents,
      eventsError: clearEventsError ? null : (eventsError ?? this.eventsError),
      categories: categories ?? this.categories,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedEvent: clearSelectedEvent ? null : (selectedEvent ?? this.selectedEvent),
      isLoadingEvent: isLoadingEvent ?? this.isLoadingEvent,
      formStatus: formStatus ?? this.formStatus,
      formError: clearFormError ? null : (formError ?? this.formError),
      formSuccessMessage: clearFormSuccessMessage
          ? null
          : (formSuccessMessage ?? this.formSuccessMessage),
    );
  }

  @override
  List<Object?> get props => [
        events,
        totalEvents,
        totalPages,
        currentPage,
        isLoadingEvents,
        eventsError,
        categories,
        isLoadingCategories,
        statusFilter,
        searchQuery,
        selectedEvent,
        isLoadingEvent,
        formStatus,
        formError,
        formSuccessMessage,
      ];
}

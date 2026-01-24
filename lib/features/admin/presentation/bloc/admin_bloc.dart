import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

/// Admin BLoC for event management
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository adminRepository;

  static const int _pageSize = 20;

  AdminBloc({required this.adminRepository}) : super(const AdminState()) {
    on<LoadEventsEvent>(_onLoadEvents);
    on<RefreshEventsEvent>(_onRefreshEvents);
    on<LoadEventEvent>(_onLoadEvent);
    on<CreateEventEvent>(_onCreateEvent);
    on<UpdateEventEvent>(_onUpdateEvent);
    on<DeleteEventEvent>(_onDeleteEvent);
    on<PublishEventEvent>(_onPublishEvent);
    on<ToggleEventFeaturedEvent>(_onToggleEventFeatured);
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<ClearFormStateEvent>(_onClearFormState);
    on<SelectEventForEditEvent>(_onSelectEventForEdit);
    on<UpdateFilterEvent>(_onUpdateFilter);
  }

  Future<void> _onLoadEvents(
    LoadEventsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoadingEvents: true, clearEventsError: true));

    final result = await adminRepository.getEvents(
      limit: event.limit,
      offset: event.offset,
      status: event.status ?? state.statusFilter,
      search: event.search ?? state.searchQuery,
    );

    result.fold(
      (error) => emit(state.copyWith(
        isLoadingEvents: false,
        eventsError: error,
      )),
      (response) => emit(state.copyWith(
        isLoadingEvents: false,
        events: response.events,
        totalEvents: response.total,
        totalPages: response.totalPages,
        currentPage: (event.offset ~/ _pageSize) + 1,
      )),
    );
  }

  Future<void> _onRefreshEvents(
    RefreshEventsEvent event,
    Emitter<AdminState> emit,
  ) async {
    add(LoadEventsEvent(
      limit: _pageSize,
      offset: 0,
      status: state.statusFilter,
      search: state.searchQuery,
    ));
  }

  Future<void> _onLoadEvent(
    LoadEventEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoadingEvent: true));

    final result = await adminRepository.getEvent(event.eventId);

    result.fold(
      (error) => emit(state.copyWith(
        isLoadingEvent: false,
        formError: error,
      )),
      (eventModel) => emit(state.copyWith(
        isLoadingEvent: false,
        selectedEvent: eventModel,
      )),
    );
  }

  Future<void> _onCreateEvent(
    CreateEventEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.loading, clearFormError: true));

    final result = await adminRepository.createEvent(event.eventData);

    result.fold(
      (error) => emit(state.copyWith(
        formStatus: FormStatus.failure,
        formError: error,
      )),
      (createdEvent) {
        emit(state.copyWith(
          formStatus: FormStatus.success,
          formSuccessMessage: 'Event created successfully',
          selectedEvent: createdEvent,
        ));
        // Refresh the events list
        add(const RefreshEventsEvent());
      },
    );
  }

  Future<void> _onUpdateEvent(
    UpdateEventEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.loading, clearFormError: true));

    final result = await adminRepository.updateEvent(
      event.eventId,
      event.eventData,
    );

    result.fold(
      (error) => emit(state.copyWith(
        formStatus: FormStatus.failure,
        formError: error,
      )),
      (updatedEvent) {
        emit(state.copyWith(
          formStatus: FormStatus.success,
          formSuccessMessage: 'Event updated successfully',
          selectedEvent: updatedEvent,
        ));
        // Refresh the events list
        add(const RefreshEventsEvent());
      },
    );
  }

  Future<void> _onDeleteEvent(
    DeleteEventEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.loading, clearFormError: true));

    final result = await adminRepository.deleteEvent(event.eventId);

    result.fold(
      (error) => emit(state.copyWith(
        formStatus: FormStatus.failure,
        formError: error,
      )),
      (_) {
        emit(state.copyWith(
          formStatus: FormStatus.success,
          formSuccessMessage: 'Event deleted successfully',
          clearSelectedEvent: true,
        ));
        // Refresh the events list
        add(const RefreshEventsEvent());
      },
    );
  }

  Future<void> _onPublishEvent(
    PublishEventEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.loading, clearFormError: true));

    final result = await adminRepository.publishEvent(event.eventId);

    result.fold(
      (error) => emit(state.copyWith(
        formStatus: FormStatus.failure,
        formError: error,
      )),
      (_) {
        emit(state.copyWith(
          formStatus: FormStatus.success,
          formSuccessMessage: 'Event published successfully',
        ));
        // Refresh the events list
        add(const RefreshEventsEvent());
      },
    );
  }

  Future<void> _onToggleEventFeatured(
    ToggleEventFeaturedEvent event,
    Emitter<AdminState> emit,
  ) async {
    final result = await adminRepository.toggleEventFeatured(
      event.eventId,
      event.featured,
    );

    result.fold(
      (error) => emit(state.copyWith(formError: error)),
      (_) {
        emit(state.copyWith(
          formSuccessMessage: event.featured
              ? 'Event marked as featured'
              : 'Event unfeatured',
        ));
        // Refresh the events list
        add(const RefreshEventsEvent());
      },
    );
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(isLoadingCategories: true));

    final result = await adminRepository.getEventCategories();

    result.fold(
      (error) => emit(state.copyWith(isLoadingCategories: false)),
      (categories) => emit(state.copyWith(
        isLoadingCategories: false,
        categories: categories,
      )),
    );
  }

  void _onClearFormState(
    ClearFormStateEvent event,
    Emitter<AdminState> emit,
  ) {
    emit(state.copyWith(
      formStatus: FormStatus.initial,
      clearFormError: true,
      clearFormSuccessMessage: true,
    ));
  }

  void _onSelectEventForEdit(
    SelectEventForEditEvent event,
    Emitter<AdminState> emit,
  ) {
    emit(state.copyWith(
      selectedEvent: event.event,
      clearSelectedEvent: event.event == null,
      formStatus: FormStatus.initial,
      clearFormError: true,
    ));
  }

  void _onUpdateFilter(
    UpdateFilterEvent event,
    Emitter<AdminState> emit,
  ) {
    emit(state.copyWith(
      statusFilter: event.status,
      searchQuery: event.search,
    ));
    add(const RefreshEventsEvent());
  }
}

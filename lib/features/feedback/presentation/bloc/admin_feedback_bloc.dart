import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/feedback_repository.dart';
import 'admin_feedback_event.dart';
import 'admin_feedback_state.dart';

/// BLoC for admin feedback/support ticket management
class AdminFeedbackBloc extends Bloc<AdminFeedbackEvent, AdminFeedbackState> {
  final FeedbackRepository _repository;

  AdminFeedbackBloc({required FeedbackRepository repository})
      : _repository = repository,
        super(const AdminFeedbackState()) {
    on<LoadAllTickets>(_onLoadAllTickets);
    on<LoadAdminTicketDetails>(_onLoadAdminTicketDetails);
    on<UpdateTicketStatus>(_onUpdateTicketStatus);
    on<UpdateTicketPriority>(_onUpdateTicketPriority);
    on<AddAdminTicketResponse>(_onAddAdminTicketResponse);
    on<LoadTicketStats>(_onLoadTicketStats);
    on<ClearAdminSelectedTicket>(_onClearAdminSelectedTicket);
    on<ApplyTicketFilters>(_onApplyTicketFilters);
  }

  Future<void> _onLoadAllTickets(
    LoadAllTickets event,
    Emitter<AdminFeedbackState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final response = await _repository.getAllTickets(
        page: event.page,
        pageSize: event.pageSize,
        status: event.status ?? state.statusFilter,
        category: event.category ?? state.categoryFilter,
        priority: event.priority ?? state.priorityFilter,
      );
      emit(state.copyWith(
        isLoading: false,
        tickets: response.tickets,
        totalCount: response.totalCount,
        currentPage: response.page,
        pageSize: response.pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadAdminTicketDetails(
    LoadAdminTicketDetails event,
    Emitter<AdminFeedbackState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final ticket = await _repository.getTicketDetails(event.ticketId);
      emit(state.copyWith(
        isLoading: false,
        selectedTicket: ticket,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateTicketStatus(
    UpdateTicketStatus event,
    Emitter<AdminFeedbackState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      await _repository.updateTicket(event.ticketId, status: event.status);
      emit(state.copyWith(isUpdating: false));
      // Reload ticket details if it's selected
      if (state.selectedTicket?.id == event.ticketId) {
        add(LoadAdminTicketDetails(event.ticketId));
      }
      // Reload list
      add(LoadAllTickets(page: state.currentPage));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateTicketPriority(
    UpdateTicketPriority event,
    Emitter<AdminFeedbackState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      await _repository.updateTicket(event.ticketId, priority: event.priority);
      emit(state.copyWith(isUpdating: false));
      // Reload ticket details if it's selected
      if (state.selectedTicket?.id == event.ticketId) {
        add(LoadAdminTicketDetails(event.ticketId));
      }
      // Reload list
      add(LoadAllTickets(page: state.currentPage));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAddAdminTicketResponse(
    AddAdminTicketResponse event,
    Emitter<AdminFeedbackState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      await _repository.addAdminResponse(event.ticketId, event.message);
      emit(state.copyWith(isUpdating: false));
      // Reload ticket details
      add(LoadAdminTicketDetails(event.ticketId));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadTicketStats(
    LoadTicketStats event,
    Emitter<AdminFeedbackState> emit,
  ) async {
    try {
      final stats = await _repository.getTicketStats();
      emit(state.copyWith(stats: stats));
    } catch (e) {
      // Stats are non-critical, don't show error
    }
  }

  void _onClearAdminSelectedTicket(
    ClearAdminSelectedTicket event,
    Emitter<AdminFeedbackState> emit,
  ) {
    emit(state.copyWith(clearSelectedTicket: true));
  }

  void _onApplyTicketFilters(
    ApplyTicketFilters event,
    Emitter<AdminFeedbackState> emit,
  ) {
    emit(state.copyWith(
      statusFilter: event.status,
      categoryFilter: event.category,
      priorityFilter: event.priority,
      clearStatusFilter: event.status == null,
      clearCategoryFilter: event.category == null,
      clearPriorityFilter: event.priority == null,
    ));
    add(const LoadAllTickets());
  }
}

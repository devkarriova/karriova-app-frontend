import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/feedback_repository.dart';
import 'feedback_event.dart';
import 'feedback_state.dart';

/// BLoC for user feedback/support tickets
class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackRepository _repository;

  FeedbackBloc({required FeedbackRepository repository})
      : _repository = repository,
        super(const FeedbackState()) {
    on<LoadMyTickets>(_onLoadMyTickets);
    on<CreateTicket>(_onCreateTicket);
    on<LoadTicketDetails>(_onLoadTicketDetails);
    on<AddTicketResponse>(_onAddTicketResponse);
    on<ClearSelectedTicket>(_onClearSelectedTicket);
  }

  Future<void> _onLoadMyTickets(
    LoadMyTickets event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final response = await _repository.getMyTickets(
        page: event.page,
        pageSize: event.pageSize,
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

  Future<void> _onCreateTicket(
    CreateTicket event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true, submitSuccess: false));

    try {
      await _repository.createTicket(event.request);
      emit(state.copyWith(
        isSubmitting: false,
        submitSuccess: true,
      ));
      // Reload tickets
      add(const LoadMyTickets());
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadTicketDetails(
    LoadTicketDetails event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final ticket = await _repository.getTicket(event.ticketId);
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

  Future<void> _onAddTicketResponse(
    AddTicketResponse event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await _repository.addResponse(event.ticketId, event.message);
      emit(state.copyWith(isSubmitting: false));
      // Reload ticket details
      add(LoadTicketDetails(event.ticketId));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      ));
    }
  }

  void _onClearSelectedTicket(
    ClearSelectedTicket event,
    Emitter<FeedbackState> emit,
  ) {
    emit(state.copyWith(clearSelectedTicket: true));
  }
}

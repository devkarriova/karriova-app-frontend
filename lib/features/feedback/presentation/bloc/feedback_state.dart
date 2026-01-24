import 'package:equatable/equatable.dart';
import '../../domain/models/feedback_models.dart';

/// State for user feedback BLoC
class FeedbackState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<SupportTicket> tickets;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final SupportTicket? selectedTicket;
  final bool isSubmitting;
  final bool submitSuccess;

  const FeedbackState({
    this.isLoading = false,
    this.error,
    this.tickets = const [],
    this.totalCount = 0,
    this.currentPage = 1,
    this.pageSize = 20,
    this.selectedTicket,
    this.isSubmitting = false,
    this.submitSuccess = false,
  });

  FeedbackState copyWith({
    bool? isLoading,
    String? error,
    List<SupportTicket>? tickets,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    SupportTicket? selectedTicket,
    bool? isSubmitting,
    bool? submitSuccess,
    bool clearError = false,
    bool clearSelectedTicket = false,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      tickets: tickets ?? this.tickets,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      selectedTicket:
          clearSelectedTicket ? null : (selectedTicket ?? this.selectedTicket),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasMore => currentPage < totalPages;

  @override
  List<Object?> get props => [
        isLoading,
        error,
        tickets,
        totalCount,
        currentPage,
        pageSize,
        selectedTicket,
        isSubmitting,
        submitSuccess,
      ];
}

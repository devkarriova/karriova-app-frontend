import 'package:equatable/equatable.dart';
import '../../domain/models/feedback_models.dart';

/// State for admin feedback management BLoC
class AdminFeedbackState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<SupportTicket> tickets;
  final int totalCount;
  final int currentPage;
  final int pageSize;
  final SupportTicket? selectedTicket;
  final TicketStats? stats;
  final bool isUpdating;

  // Filters
  final TicketStatus? statusFilter;
  final TicketCategory? categoryFilter;
  final TicketPriority? priorityFilter;

  const AdminFeedbackState({
    this.isLoading = false,
    this.error,
    this.tickets = const [],
    this.totalCount = 0,
    this.currentPage = 1,
    this.pageSize = 20,
    this.selectedTicket,
    this.stats,
    this.isUpdating = false,
    this.statusFilter,
    this.categoryFilter,
    this.priorityFilter,
  });

  AdminFeedbackState copyWith({
    bool? isLoading,
    String? error,
    List<SupportTicket>? tickets,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    SupportTicket? selectedTicket,
    TicketStats? stats,
    bool? isUpdating,
    TicketStatus? statusFilter,
    TicketCategory? categoryFilter,
    TicketPriority? priorityFilter,
    bool clearError = false,
    bool clearSelectedTicket = false,
    bool clearStatusFilter = false,
    bool clearCategoryFilter = false,
    bool clearPriorityFilter = false,
  }) {
    return AdminFeedbackState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      tickets: tickets ?? this.tickets,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      selectedTicket:
          clearSelectedTicket ? null : (selectedTicket ?? this.selectedTicket),
      stats: stats ?? this.stats,
      isUpdating: isUpdating ?? this.isUpdating,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      categoryFilter:
          clearCategoryFilter ? null : (categoryFilter ?? this.categoryFilter),
      priorityFilter:
          clearPriorityFilter ? null : (priorityFilter ?? this.priorityFilter),
    );
  }

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasMore => currentPage < totalPages;
  bool get hasFilters =>
      statusFilter != null || categoryFilter != null || priorityFilter != null;

  @override
  List<Object?> get props => [
        isLoading,
        error,
        tickets,
        totalCount,
        currentPage,
        pageSize,
        selectedTicket,
        stats,
        isUpdating,
        statusFilter,
        categoryFilter,
        priorityFilter,
      ];
}

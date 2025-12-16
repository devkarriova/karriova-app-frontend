import 'package:equatable/equatable.dart';
import '../../domain/models/post_model.dart';

enum FeedStatus {
  initial,
  loading,
  loadingMore,
  success,
  error,
  refreshing,
}

class FeedState extends Equatable {
  final FeedStatus status;
  final List<PostModel> posts;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final String? successMessage;

  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.successMessage,
  });

  /// Check if we're in a loading state
  bool get isLoading =>
      status == FeedStatus.loading ||
      status == FeedStatus.loadingMore ||
      status == FeedStatus.refreshing;

  /// Check if posts are empty and not loading
  bool get isEmpty => posts.isEmpty && !isLoading;

  /// Check if we can load more posts
  bool get canLoadMore => !hasReachedMax && !isLoading;

  FeedState copyWith({
    FeedStatus? status,
    List<PostModel>? posts,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        posts,
        errorMessage,
        hasReachedMax,
        currentPage,
        successMessage,
      ];
}

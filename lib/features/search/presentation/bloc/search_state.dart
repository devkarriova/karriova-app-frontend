import 'package:equatable/equatable.dart';
import '../../domain/models/search_result_model.dart';

enum SearchStatus {
  initial,
  loading,
  success,
  error,
}

class SearchState extends Equatable {
  final SearchStatus status;
  final String query;
  final List<UserSearchResult> users;
  final List<PostSearchResult> posts;
  final int usersCount;
  final int postsCount;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.users = const [],
    this.posts = const [],
    this.usersCount = 0,
    this.postsCount = 0,
    this.errorMessage,
  });

  bool get hasResults => users.isNotEmpty || posts.isNotEmpty;
  bool get isLoading => status == SearchStatus.loading;
  bool get hasError => status == SearchStatus.error;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<UserSearchResult>? users,
    List<PostSearchResult>? posts,
    int? usersCount,
    int? postsCount,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      users: users ?? this.users,
      posts: posts ?? this.posts,
      usersCount: usersCount ?? this.usersCount,
      postsCount: postsCount ?? this.postsCount,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        query,
        users,
        posts,
        usersCount,
        postsCount,
        errorMessage,
      ];
}

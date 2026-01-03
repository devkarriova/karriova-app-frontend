import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../domain/models/search_result_model.dart';
import '../../domain/repositories/search_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository searchRepository;

  SearchBloc({required this.searchRepository}) : super(const SearchState()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: debounce(const Duration(milliseconds: 400)),
    );
    on<SearchUsersRequested>(_onSearchUsers);
    on<SearchPostsRequested>(_onSearchPosts);
    on<SearchAllRequested>(_onSearchAll);
    on<SearchCleared>(_onSearchCleared);
  }

  void _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(query: event.query));

    // Auto-search when query has at least 2 characters
    if (event.query.trim().length >= 2) {
      add(SearchUsersRequested(query: event.query.trim()));
    } else if (event.query.trim().isEmpty) {
      add(const SearchCleared());
    }
  }

  Future<void> _onSearchUsers(
    SearchUsersRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) return;

    emit(state.copyWith(status: SearchStatus.loading));

    final result = await searchRepository.searchUsers(event.query);

    result.fold(
      (error) {
        print('Search error: $error');
        emit(state.copyWith(
          status: SearchStatus.error,
          errorMessage: error,
        ));
      },
      (users) {
        print('Search success: found ${users.length} users');
        emit(state.copyWith(
          status: SearchStatus.success,
          users: users,
          usersCount: users.length,
        ));
      },
    );
  }

  Future<void> _onSearchPosts(
    SearchPostsRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) return;

    emit(state.copyWith(status: SearchStatus.loading));

    final result = await searchRepository.searchPosts(event.query);

    result.fold(
      (error) => emit(state.copyWith(
        status: SearchStatus.error,
        errorMessage: error,
      )),
      (posts) => emit(state.copyWith(
        status: SearchStatus.success,
        posts: posts,
        postsCount: posts.length,
      )),
    );
  }

  Future<void> _onSearchAll(
    SearchAllRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) return;

    emit(state.copyWith(status: SearchStatus.loading));

    final result = await searchRepository.searchAll(event.query);

    result.fold(
      (error) => emit(state.copyWith(
        status: SearchStatus.error,
        errorMessage: error,
      )),
      (results) => emit(state.copyWith(
        status: SearchStatus.success,
        users: results['users'] as List<UserSearchResult>,
        posts: results['posts'] as List<PostSearchResult>,
        usersCount: results['users_count'] as int,
        postsCount: results['posts_count'] as int,
      )),
    );
  }

  void _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    emit(const SearchState());
  }
}

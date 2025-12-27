import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event when search query changes
class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to search users
class SearchUsersRequested extends SearchEvent {
  final String query;

  const SearchUsersRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to search posts
class SearchPostsRequested extends SearchEvent {
  final String query;

  const SearchPostsRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to search all
class SearchAllRequested extends SearchEvent {
  final String query;

  const SearchAllRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to clear search
class SearchCleared extends SearchEvent {
  const SearchCleared();
}

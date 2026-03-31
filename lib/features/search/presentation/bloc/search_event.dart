import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event when search query changes
class SearchQueryChanged extends SearchEvent {
  final String query;
  final String? schoolName;
  final String? classGrade;
  final String? stream;
  final String? location;
  final List<String>? interests;

  const SearchQueryChanged({
    required this.query,
    this.schoolName,
    this.classGrade,
    this.stream,
    this.location,
    this.interests,
  });

  @override
  List<Object?> get props => [query, schoolName, classGrade, stream, location, interests];
}

/// Event to search users
class SearchUsersRequested extends SearchEvent {
  final String query;

  const SearchUsersRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to search users with filters
class SearchUsersRequestedWithFilters extends SearchEvent {
  final String query;
  final String? schoolName;
  final String? classGrade;
  final String? stream;
  final String? location;
  final List<String>? interests;

  const SearchUsersRequestedWithFilters({
    required this.query,
    this.schoolName,
    this.classGrade,
    this.stream,
    this.location,
    this.interests,
  });

  @override
  List<Object?> get props => [query, schoolName, classGrade, stream, location, interests];
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

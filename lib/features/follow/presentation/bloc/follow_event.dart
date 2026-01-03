import 'package:equatable/equatable.dart';

abstract class FollowEvent extends Equatable {
  const FollowEvent();

  @override
  List<Object?> get props => [];
}

class FollowUserEvent extends FollowEvent {
  final String userId;

  const FollowUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UnfollowUserEvent extends FollowEvent {
  final String userId;

  const UnfollowUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadFollowStatusEvent extends FollowEvent {
  final String userId;

  const LoadFollowStatusEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadFollowersEvent extends FollowEvent {
  final String userId;
  final bool refresh;

  const LoadFollowersEvent(this.userId, {this.refresh = false});

  @override
  List<Object?> get props => [userId, refresh];
}

class LoadFollowingEvent extends FollowEvent {
  final String userId;
  final bool refresh;

  const LoadFollowingEvent(this.userId, {this.refresh = false});

  @override
  List<Object?> get props => [userId, refresh];
}

class LoadFollowStatsEvent extends FollowEvent {
  final String userId;

  const LoadFollowStatsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadSuggestedUsersEvent extends FollowEvent {
  final bool refresh;

  const LoadSuggestedUsersEvent({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadFollowingIdsEvent extends FollowEvent {
  const LoadFollowingIdsEvent();
}

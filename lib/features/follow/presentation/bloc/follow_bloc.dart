import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/follow_repository.dart';
import 'follow_event.dart';
import 'follow_state.dart';

class FollowBloc extends Bloc<FollowEvent, FollowState> {
  final FollowRepository _followRepository;

  FollowBloc({required FollowRepository followRepository})
      : _followRepository = followRepository,
        super(const FollowState()) {
    on<FollowUserEvent>(_onFollowUser);
    on<UnfollowUserEvent>(_onUnfollowUser);
    on<LoadFollowStatusEvent>(_onLoadFollowStatus);
    on<LoadFollowersEvent>(_onLoadFollowers);
    on<LoadFollowingEvent>(_onLoadFollowing);
    on<LoadFollowStatsEvent>(_onLoadFollowStats);
    on<LoadSuggestedUsersEvent>(_onLoadSuggestedUsers);
    on<LoadFollowingIdsEvent>(_onLoadFollowingIds);
  }

  Future<void> _onFollowUser(FollowUserEvent event, Emitter<FollowState> emit) async {
    try {
      await _followRepository.followUser(event.userId);
      
      // Update local state
      final updatedMap = Map<String, bool>.from(state.followStatusMap);
      updatedMap[event.userId] = true;
      
      final updatedFollowingIds = List<String>.from(state.followingIds);
      if (!updatedFollowingIds.contains(event.userId)) {
        updatedFollowingIds.add(event.userId);
      }

      // Remove from suggested users if present
      final updatedSuggested = state.suggestedUsers
          .where((user) => user.id != event.userId)
          .toList();

      emit(state.copyWith(
        followStatusMap: updatedMap,
        followingIds: updatedFollowingIds,
        suggestedUsers: updatedSuggested,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FollowStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUnfollowUser(UnfollowUserEvent event, Emitter<FollowState> emit) async {
    try {
      await _followRepository.unfollowUser(event.userId);
      
      // Update local state
      final updatedMap = Map<String, bool>.from(state.followStatusMap);
      updatedMap[event.userId] = false;
      
      final updatedFollowingIds = List<String>.from(state.followingIds);
      updatedFollowingIds.remove(event.userId);

      emit(state.copyWith(
        followStatusMap: updatedMap,
        followingIds: updatedFollowingIds,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FollowStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadFollowStatus(LoadFollowStatusEvent event, Emitter<FollowState> emit) async {
    try {
      final status = await _followRepository.getFollowStatus(event.userId);
      
      final updatedMap = Map<String, bool>.from(state.followStatusMap);
      updatedMap[event.userId] = status.isFollowing;

      emit(state.copyWith(followStatusMap: updatedMap));
    } catch (e) {
      emit(state.copyWith(
        status: FollowStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadFollowers(LoadFollowersEvent event, Emitter<FollowState> emit) async {
    if (state.status == FollowStatus.loading && !event.refresh) return;

    emit(state.copyWith(status: FollowStatus.loading));

    try {
      final offset = event.refresh ? 0 : state.followers.length;
      final followers = await _followRepository.getFollowers(
        event.userId,
        limit: 20,
        offset: offset,
      );

      emit(state.copyWith(
        status: FollowStatus.success,
        followers: event.refresh ? followers : [...state.followers, ...followers],
        hasReachedMaxFollowers: followers.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FollowStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadFollowing(LoadFollowingEvent event, Emitter<FollowState> emit) async {
    if (state.status == FollowStatus.loading && !event.refresh) return;

    emit(state.copyWith(status: FollowStatus.loading));

    try {
      final offset = event.refresh ? 0 : state.following.length;
      final following = await _followRepository.getFollowing(
        event.userId,
        limit: 20,
        offset: offset,
      );

      emit(state.copyWith(
        status: FollowStatus.success,
        following: event.refresh ? following : [...state.following, ...following],
        hasReachedMaxFollowing: following.length < 20,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FollowStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadFollowStats(LoadFollowStatsEvent event, Emitter<FollowState> emit) async {
    try {
      final stats = await _followRepository.getFollowStats(event.userId);
      emit(state.copyWith(stats: stats));
    } catch (e) {
      emit(state.copyWith(
        status: FollowStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadSuggestedUsers(LoadSuggestedUsersEvent event, Emitter<FollowState> emit) async {
    if (state.status == FollowStatus.loading && !event.refresh) return;

    emit(state.copyWith(status: FollowStatus.loading));

    try {
      final suggestedUsers = await _followRepository.getSuggestedUsers(limit: 10);
      emit(state.copyWith(
        status: FollowStatus.success,
        suggestedUsers: suggestedUsers,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FollowStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadFollowingIds(LoadFollowingIdsEvent event, Emitter<FollowState> emit) async {
    try {
      final followingIds = await _followRepository.getFollowingIds();
      emit(state.copyWith(followingIds: followingIds));
    } catch (e) {
      emit(state.copyWith(
        status: FollowStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}

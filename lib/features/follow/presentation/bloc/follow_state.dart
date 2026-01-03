import 'package:equatable/equatable.dart';
import '../../domain/models/follow_model.dart';

enum FollowStatus { initial, loading, success, failure }

class FollowState extends Equatable {
  final FollowStatus status;
  final List<FollowUserModel> followers;
  final List<FollowUserModel> following;
  final List<FollowUserModel> suggestedUsers;
  final List<String> followingIds;
  final FollowStatsModel? stats;
  final Map<String, bool> followStatusMap; // userId -> isFollowing
  final String? errorMessage;
  final bool hasReachedMaxFollowers;
  final bool hasReachedMaxFollowing;

  const FollowState({
    this.status = FollowStatus.initial,
    this.followers = const [],
    this.following = const [],
    this.suggestedUsers = const [],
    this.followingIds = const [],
    this.stats,
    this.followStatusMap = const {},
    this.errorMessage,
    this.hasReachedMaxFollowers = false,
    this.hasReachedMaxFollowing = false,
  });

  FollowState copyWith({
    FollowStatus? status,
    List<FollowUserModel>? followers,
    List<FollowUserModel>? following,
    List<FollowUserModel>? suggestedUsers,
    List<String>? followingIds,
    FollowStatsModel? stats,
    Map<String, bool>? followStatusMap,
    String? errorMessage,
    bool? hasReachedMaxFollowers,
    bool? hasReachedMaxFollowing,
  }) {
    return FollowState(
      status: status ?? this.status,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      suggestedUsers: suggestedUsers ?? this.suggestedUsers,
      followingIds: followingIds ?? this.followingIds,
      stats: stats ?? this.stats,
      followStatusMap: followStatusMap ?? this.followStatusMap,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMaxFollowers: hasReachedMaxFollowers ?? this.hasReachedMaxFollowers,
      hasReachedMaxFollowing: hasReachedMaxFollowing ?? this.hasReachedMaxFollowing,
    );
  }

  bool isFollowing(String userId) {
    return followStatusMap[userId] ?? followingIds.contains(userId);
  }

  @override
  List<Object?> get props => [
        status,
        followers,
        following,
        suggestedUsers,
        followingIds,
        stats,
        followStatusMap,
        errorMessage,
        hasReachedMaxFollowers,
        hasReachedMaxFollowing,
      ];
}

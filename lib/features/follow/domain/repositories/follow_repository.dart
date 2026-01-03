import '../models/follow_model.dart';

abstract class FollowRepository {
  /// Follow a user
  Future<void> followUser(String userId);

  /// Unfollow a user
  Future<void> unfollowUser(String userId);

  /// Check if current user is following a specific user
  Future<FollowStatusModel> getFollowStatus(String userId);

  /// Get followers of a user
  Future<List<FollowUserModel>> getFollowers(String userId, {int limit = 20, int offset = 0});

  /// Get users that a user is following
  Future<List<FollowUserModel>> getFollowing(String userId, {int limit = 20, int offset = 0});

  /// Get follow stats for a user
  Future<FollowStatsModel> getFollowStats(String userId);

  /// Get suggested users to follow
  Future<List<FollowUserModel>> getSuggestedUsers({int limit = 10});

  /// Get list of IDs of users the current user is following
  Future<List<String>> getFollowingIds();
}

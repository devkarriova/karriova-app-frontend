import '../../../../core/network/api_client.dart';
import '../../domain/models/follow_model.dart';

abstract class FollowRemoteDataSource {
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<FollowStatusModel> getFollowStatus(String userId);
  Future<List<FollowUserModel>> getFollowers(String userId, {int limit = 20, int offset = 0});
  Future<List<FollowUserModel>> getFollowing(String userId, {int limit = 20, int offset = 0});
  Future<FollowStatsModel> getFollowStats(String userId);
  Future<List<FollowUserModel>> getSuggestedUsers({int limit = 10});
  Future<List<String>> getFollowingIds();
}

class FollowRemoteDataSourceImpl implements FollowRemoteDataSource {
  final ApiClient apiClient;

  FollowRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> followUser(String userId) async {
    final response = await apiClient.post(
      '/follow/$userId',
      requiresAuth: true,
      body: {},
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to follow user');
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    final response = await apiClient.delete(
      '/follow/$userId',
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to unfollow user');
    }
  }

  @override
  Future<FollowStatusModel> getFollowStatus(String userId) async {
    final response = await apiClient.get(
      '/follow/$userId/status',
      requiresAuth: true,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get follow status');
    }

    return FollowStatusModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<FollowUserModel>> getFollowers(String userId, {int limit = 20, int offset = 0}) async {
    final response = await apiClient.get(
      '/follow/$userId/followers',
      requiresAuth: true,
      queryParams: {'limit': limit.toString(), 'offset': offset.toString()},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get followers');
    }

    final List<dynamic> users = response.data as List<dynamic>;
    return users.map((json) => FollowUserModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<FollowUserModel>> getFollowing(String userId, {int limit = 20, int offset = 0}) async {
    final response = await apiClient.get(
      '/follow/$userId/following',
      requiresAuth: true,
      queryParams: {'limit': limit.toString(), 'offset': offset.toString()},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get following');
    }

    final List<dynamic> users = response.data as List<dynamic>;
    return users.map((json) => FollowUserModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<FollowStatsModel> getFollowStats(String userId) async {
    final response = await apiClient.get(
      '/follow/$userId/stats',
      requiresAuth: true,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get follow stats');
    }

    return FollowStatsModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<FollowUserModel>> getSuggestedUsers({int limit = 10}) async {
    final response = await apiClient.get(
      '/follow/suggestions',
      requiresAuth: true,
      queryParams: {'limit': limit.toString()},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get suggested users');
    }

    final List<dynamic> users = response.data as List<dynamic>;
    return users.map((json) => FollowUserModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<String>> getFollowingIds() async {
    final response = await apiClient.get(
      '/follow/following/ids',
      requiresAuth: true,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get following IDs');
    }

    final List<dynamic> ids = response.data as List<dynamic>;
    return ids.map((id) => id.toString()).toList();
  }
}

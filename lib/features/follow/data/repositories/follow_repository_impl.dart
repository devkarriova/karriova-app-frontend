import '../../domain/models/follow_model.dart';
import '../../domain/repositories/follow_repository.dart';
import '../datasources/follow_remote_datasource.dart';

class FollowRepositoryImpl implements FollowRepository {
  final FollowRemoteDataSource remoteDataSource;

  FollowRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> followUser(String userId) async {
    await remoteDataSource.followUser(userId);
  }

  @override
  Future<void> unfollowUser(String userId) async {
    await remoteDataSource.unfollowUser(userId);
  }

  @override
  Future<FollowStatusModel> getFollowStatus(String userId) async {
    return remoteDataSource.getFollowStatus(userId);
  }

  @override
  Future<List<FollowUserModel>> getFollowers(String userId, {int limit = 20, int offset = 0}) async {
    return remoteDataSource.getFollowers(userId, limit: limit, offset: offset);
  }

  @override
  Future<List<FollowUserModel>> getFollowing(String userId, {int limit = 20, int offset = 0}) async {
    return remoteDataSource.getFollowing(userId, limit: limit, offset: offset);
  }

  @override
  Future<FollowStatsModel> getFollowStats(String userId) async {
    return remoteDataSource.getFollowStats(userId);
  }

  @override
  Future<List<FollowUserModel>> getSuggestedUsers({int limit = 10}) async {
    return remoteDataSource.getSuggestedUsers(limit: limit);
  }

  @override
  Future<List<String>> getFollowingIds() async {
    return remoteDataSource.getFollowingIds();
  }
}

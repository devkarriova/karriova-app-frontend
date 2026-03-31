import 'package:dartz/dartz.dart';
import '../../domain/models/search_result_model.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<UserSearchResult>>> searchUsers(
    String query, {
    String? schoolName,
    String? classGrade,
    String? stream,
    String? location,
    List<String>? interests,
  }) async {
    try {
      final response = await remoteDataSource.searchUsers(
        query,
        schoolName: schoolName,
        classGrade: classGrade,
        stream: stream,
        location: location,
        interests: interests,
      );
      return Right(response.users);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<PostSearchResult>>> searchPosts(String query) async {
    try {
      final response = await remoteDataSource.searchPosts(query);
      return Right(response.posts);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> searchAll(String query) async {
    try {
      final response = await remoteDataSource.searchAll(query);
      return Right({
        'users': response.users,
        'posts': response.posts,
        'users_count': response.usersCount,
        'posts_count': response.postsCount,
      });
    } catch (e) {
      return Left(e.toString());
    }
  }
}

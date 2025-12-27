import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/models/search_result_model.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<UserSearchResult>>> searchUsers(String query) async {
    try {
      final response = await remoteDataSource.searchUsers(query);
      return Right(response.users);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to search users');
    } catch (e) {
      return Left('An unexpected error occurred');
    }
  }

  @override
  Future<Either<String, List<PostSearchResult>>> searchPosts(String query) async {
    try {
      final response = await remoteDataSource.searchPosts(query);
      return Right(response.posts);
    } on DioException catch (e) {
      return Left(e.response?.data['message'] ?? 'Failed to search posts');
    } catch (e) {
      return Left('An unexpected error occurred');
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
    } on DioException catch (e) {
      // Better error logging
      print('DioException during search: ${e.type}');
      print('Status code: ${e.response?.statusCode}');
      print('Error message: ${e.message}');
      print('Response data: ${e.response?.data}');

      final errorMsg = e.response?.data?['message'] ??
                       e.response?.data?.toString() ??
                       'Failed to search: ${e.message}';
      return Left(errorMsg);
    } catch (e) {
      print('Unexpected error during search: $e');
      return Left('An unexpected error occurred: ${e.toString()}');
    }
  }
}

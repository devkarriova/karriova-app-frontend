import 'package:dartz/dartz.dart';
import '../models/search_result_model.dart';

abstract class SearchRepository {
  Future<Either<String, List<UserSearchResult>>> searchUsers(
    String query, {
    String? schoolName,
    String? classGrade,
    String? stream,
    String? location,
    List<String>? interests,
  });
  Future<Either<String, List<PostSearchResult>>> searchPosts(String query);
  Future<Either<String, Map<String, dynamic>>> searchAll(String query);
}

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../domain/models/search_result_model.dart';

part 'search_remote_datasource.g.dart';

@RestApi()
abstract class SearchRemoteDataSource {
  factory SearchRemoteDataSource(Dio dio, {String baseUrl}) = _SearchRemoteDataSource;

  @GET('/search/users')
  Future<SearchUsersResponse> searchUsers(@Query('q') String query);

  @GET('/search/posts')
  Future<SearchPostsResponse> searchPosts(@Query('q') String query);

  @GET('/search/all')
  Future<SearchAllResponse> searchAll(@Query('q') String query);
}

class SearchUsersResponse {
  final List<UserSearchResult> users;
  final int count;

  SearchUsersResponse({required this.users, required this.count});

  factory SearchUsersResponse.fromJson(Map<String, dynamic> json) {
    return SearchUsersResponse(
      users: (json['users'] as List?)
              ?.map((e) => UserSearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
    );
  }
}

class SearchPostsResponse {
  final List<PostSearchResult> posts;
  final int count;

  SearchPostsResponse({required this.posts, required this.count});

  factory SearchPostsResponse.fromJson(Map<String, dynamic> json) {
    return SearchPostsResponse(
      posts: (json['posts'] as List?)
              ?.map((e) => PostSearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] as int? ?? 0,
    );
  }
}

class SearchAllResponse {
  final List<UserSearchResult> users;
  final List<PostSearchResult> posts;
  final int usersCount;
  final int postsCount;

  SearchAllResponse({
    required this.users,
    required this.posts,
    required this.usersCount,
    required this.postsCount,
  });

  factory SearchAllResponse.fromJson(Map<String, dynamic> json) {
    return SearchAllResponse(
      users: (json['users'] as List?)
              ?.map((e) => UserSearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      posts: (json['posts'] as List?)
              ?.map((e) => PostSearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      usersCount: json['users_count'] as int? ?? 0,
      postsCount: json['posts_count'] as int? ?? 0,
    );
  }
}

import '../../../../core/network/api_client.dart';
import '../../domain/models/search_result_model.dart';

abstract class SearchRemoteDataSource {
  Future<SearchUsersResponse> searchUsers(
    String query, {
    String? schoolName,
    String? classGrade,
    String? stream,
    String? location,
    List<String>? interests,
  });
  Future<SearchPostsResponse> searchPosts(String query);
  Future<SearchAllResponse> searchAll(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiClient apiClient;

  SearchRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<SearchUsersResponse> searchUsers(
    String query, {
    String? schoolName,
    String? classGrade,
    String? stream,
    String? location,
    List<String>? interests,
  }) async {
    final queryParams = <String, String>{'q': query};

    // Add optional filters
    if (schoolName != null) queryParams['school_name'] = schoolName;
    if (classGrade != null) queryParams['class_grade'] = classGrade;
    if (stream != null) queryParams['stream'] = stream;
    if (location != null) queryParams['location'] = location;
    if (interests != null && interests.isNotEmpty) {
      // For array parameters, join with commas or send as repeated params
      queryParams['interests'] = interests.join(',');
    }

    final response = await apiClient.get(
      '/search/users',
      requiresAuth: true,
      queryParams: queryParams,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to search users');
    }

    return SearchUsersResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SearchPostsResponse> searchPosts(String query) async {
    final response = await apiClient.get(
      '/search/posts',
      requiresAuth: true,
      queryParams: {'q': query},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to search posts');
    }

    return SearchPostsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SearchAllResponse> searchAll(String query) async {
    final response = await apiClient.get(
      '/search/all',
      requiresAuth: true,
      queryParams: {'q': query},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to search');
    }

    return SearchAllResponse.fromJson(response.data as Map<String, dynamic>);
  }
}

class SearchUsersResponse {
  final List<UserSearchResult> users;
  final int count;

  SearchUsersResponse({required this.users, required this.count});

  factory SearchUsersResponse.fromJson(Map<String, dynamic> json) {
    final usersList = json['users'] as List?;
    
    return SearchUsersResponse(
      users: usersList?.map((u) => UserSearchResult.fromJson(u as Map<String, dynamic>)).toList() ?? [],
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

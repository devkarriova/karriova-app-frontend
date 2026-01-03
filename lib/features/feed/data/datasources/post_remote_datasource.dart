import '../../../../core/network/api_client.dart';
import '../../domain/models/post_model.dart';
import '../../domain/models/comment_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getFeed({int limit = 20, int offset = 0});
  Future<List<PostModel>> getDiscover({int limit = 20, int offset = 0});
  Future<List<PostModel>> getUserPosts(String userId, {int limit = 20, int offset = 0});
  Future<PostModel> getPost(String postId);
  Future<PostModel> createPost(String content, List<String> mediaUrls);
  Future<PostModel> updatePost(String postId, String content, List<String> mediaUrls);
  Future<void> deletePost(String postId);
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<void> sharePost(String postId, String shareText);
  Future<List<CommentModel>> getComments(String postId, {int limit = 20, int offset = 0});
  Future<CommentModel> createComment(String postId, String content);
  Future<void> deleteComment(String commentId);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final ApiClient apiClient;

  PostRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PostModel>> getFeed({int limit = 20, int offset = 0}) async {
    final response = await apiClient.get(
      '/posts/feed',
      requiresAuth: true,
      queryParams: {'limit': limit.toString(), 'offset': offset.toString()},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get feed');
    }

    final List<dynamic> posts = response.data as List<dynamic>;
    return posts.map((json) => PostModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<PostModel>> getDiscover({int limit = 20, int offset = 0}) async {
    final response = await apiClient.get(
      '/posts/discover',
      requiresAuth: true,
      queryParams: {'limit': limit.toString(), 'offset': offset.toString()},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get discover posts');
    }

    final List<dynamic> posts = response.data as List<dynamic>;
    return posts.map((json) => PostModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<PostModel>> getUserPosts(String userId, {int limit = 20, int offset = 0}) async {
    final response = await apiClient.get(
      '/posts/user/$userId',
      requiresAuth: true,
      queryParams: {'limit': limit.toString(), 'offset': offset.toString()},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get user posts');
    }

    final List<dynamic> posts = response.data as List<dynamic>;
    return posts.map((json) => PostModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<PostModel> getPost(String postId) async {
    final response = await apiClient.get(
      '/posts/$postId',
      requiresAuth: true,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get post');
    }

    return PostModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PostModel> createPost(String content, List<String> mediaUrls) async {
    final response = await apiClient.post(
      '/posts',
      requiresAuth: true,
      body: {
        'content': content,
        'media_urls': mediaUrls,
      },
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to create post');
    }

    return PostModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PostModel> updatePost(String postId, String content, List<String> mediaUrls) async {
    final response = await apiClient.put(
      '/posts/$postId',
      requiresAuth: true,
      body: {
        'content': content,
        'media_urls': mediaUrls,
      },
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to update post');
    }

    return PostModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deletePost(String postId) async {
    final response = await apiClient.delete(
      '/posts/$postId',
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to delete post');
    }
  }

  @override
  Future<void> likePost(String postId) async {
    final response = await apiClient.post(
      '/posts/$postId/like',
      requiresAuth: true,
      body: {},
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to like post');
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    final response = await apiClient.delete(
      '/posts/$postId/like',
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to unlike post');
    }
  }

  @override
  Future<void> sharePost(String postId, String shareText) async {
    final response = await apiClient.post(
      '/posts/$postId/share',
      requiresAuth: true,
      body: {'share_text': shareText},
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to share post');
    }
  }

  @override
  Future<List<CommentModel>> getComments(String postId, {int limit = 20, int offset = 0}) async {
    final response = await apiClient.get(
      '/posts/$postId/comments',
      requiresAuth: true,
      queryParams: {'limit': limit.toString(), 'offset': offset.toString()},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get comments');
    }

    final List<dynamic> comments = response.data as List<dynamic>;
    return comments.map((json) => CommentModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<CommentModel> createComment(String postId, String content) async {
    final response = await apiClient.post(
      '/posts/$postId/comments',
      requiresAuth: true,
      body: {'content': content},
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to create comment');
    }

    return CommentModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteComment(String commentID) async {
    final response = await apiClient.delete(
      '/posts/comments/$commentID',
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to delete comment');
    }
  }
}

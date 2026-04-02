import 'package:dartz/dartz.dart';
import '../../domain/models/post_model.dart';
import '../../domain/models/comment_model.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<PostModel>>> getFeed({int limit = 20, int offset = 0}) async {
    try {
      final posts = await remoteDataSource.getFeed(limit: limit, offset: offset);
      return Right(posts);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, List<PostModel>>> getDiscover({int limit = 20, int offset = 0}) async {
    try {
      final posts = await remoteDataSource.getDiscover(limit: limit, offset: offset);
      return Right(posts);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, List<PostModel>>> getUserPosts(String userId, {int limit = 20, int offset = 0}) async {
    try {
      final posts = await remoteDataSource.getUserPosts(userId, limit: limit, offset: offset);
      return Right(posts);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, PostModel>> getPost(String postId) async {
    try {
      final post = await remoteDataSource.getPost(postId);
      return Right(post);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, PostModel>> createPost(String content, List<String> mediaUrls) async {
    try {
      final post = await remoteDataSource.createPost(content, mediaUrls);
      return Right(post);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, PostModel>> updatePost(String postId, String content, List<String> mediaUrls) async {
    try {
      final post = await remoteDataSource.updatePost(postId, content, mediaUrls);
      return Right(post);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> deletePost(String postId) async {
    try {
      await remoteDataSource.deletePost(postId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> likePost(String postId) async {
    try {
      await remoteDataSource.likePost(postId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> unlikePost(String postId) async {
    try {
      await remoteDataSource.unlikePost(postId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> sharePost(String postId, String shareText) async {
    try {
      await remoteDataSource.sharePost(postId, shareText);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, List<CommentModel>>> getComments(String postId, {int limit = 20, int offset = 0}) async {
    try {
      final comments = await remoteDataSource.getComments(postId, limit: limit, offset: offset);
      return Right(comments);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, CommentModel>> createComment(String postId, String content) async {
    try {
      final comment = await remoteDataSource.createComment(postId, content);
      return Right(comment);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  String _handleError(Object error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}

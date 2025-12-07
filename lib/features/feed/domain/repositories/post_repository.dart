import 'package:dartz/dartz.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

/// Repository interface for post operations
abstract class PostRepository {
  Future<Either<String, List<PostModel>>> getFeed({int limit = 20, int offset = 0});
  Future<Either<String, List<PostModel>>> getUserPosts(String userId, {int limit = 20, int offset = 0});
  Future<Either<String, PostModel>> getPost(String postId);
  Future<Either<String, PostModel>> createPost(String content, List<String> mediaUrls);
  Future<Either<String, PostModel>> updatePost(String postId, String content, List<String> mediaUrls);
  Future<Either<String, void>> deletePost(String postId);
  Future<Either<String, void>> likePost(String postId);
  Future<Either<String, void>> unlikePost(String postId);
  Future<Either<String, void>> sharePost(String postId, String shareText);
  Future<Either<String, List<CommentModel>>> getComments(String postId, {int limit = 20, int offset = 0});
  Future<Either<String, CommentModel>> createComment(String postId, String content);
  Future<Either<String, void>> deleteComment(String commentId);
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/models/post_model.dart';
import '../../data/datasources/media_remote_datasource.dart';
import 'feed_event.dart';
import 'feed_state.dart';
import '../../../../core/utils/logger.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostRepository postRepository;
  final MediaRemoteDataSource mediaDataSource;
  static const int _postsPerPage = 20;

  FeedBloc({
    required this.postRepository,
    required this.mediaDataSource,
  }) : super(const FeedState()) {
    on<FeedLoadRequested>(_onLoadRequested);
    on<FeedRefreshRequested>(_onRefreshRequested);
    on<FeedLoadMoreRequested>(_onLoadMoreRequested);
    on<FeedPostLikeToggled>(_onPostLikeToggled);
    on<FeedPostShared>(_onPostShared);
    on<FeedPostDeleted>(_onPostDeleted);
    on<FeedPostCreated>(_onPostCreated);
  }

  /// Load initial feed
  Future<void> _onLoadRequested(
    FeedLoadRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.loading, clearError: true));

    final result = await postRepository.getFeed(
      limit: _postsPerPage,
      offset: 0,
    );

    result.fold(
      (error) {
        AppLogger.error('Failed to load feed: $error');
        emit(state.copyWith(
          status: FeedStatus.error,
          errorMessage: error,
        ));
      },
      (posts) {
        emit(state.copyWith(
          status: FeedStatus.success,
          posts: posts,
          currentPage: 1,
          hasReachedMax: posts.length < _postsPerPage,
        ));
      },
    );
  }

  /// Refresh feed (pull to refresh)
  Future<void> _onRefreshRequested(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.copyWith(status: FeedStatus.refreshing, clearError: true));

    final result = await postRepository.getFeed(
      limit: _postsPerPage,
      offset: 0,
    );

    result.fold(
      (error) {
        AppLogger.error('Failed to refresh feed: $error');
        emit(state.copyWith(
          status: FeedStatus.error,
          errorMessage: error,
        ));
      },
      (posts) {
        emit(state.copyWith(
          status: FeedStatus.success,
          posts: posts,
          currentPage: 1,
          hasReachedMax: posts.length < _postsPerPage,
        ));
      },
    );
  }

  /// Load more posts (pagination)
  Future<void> _onLoadMoreRequested(
    FeedLoadMoreRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (state.hasReachedMax || state.status == FeedStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: FeedStatus.loadingMore));

    final result = await postRepository.getFeed(
      limit: _postsPerPage,
      offset: state.posts.length,
    );

    result.fold(
      (error) {
        AppLogger.error('Failed to load more posts: $error');
        emit(state.copyWith(
          status: FeedStatus.error,
          errorMessage: error,
        ));
      },
      (newPosts) {
        if (newPosts.isEmpty) {
          emit(state.copyWith(
            status: FeedStatus.success,
            hasReachedMax: true,
          ));
        } else {
          emit(state.copyWith(
            status: FeedStatus.success,
            posts: List.of(state.posts)..addAll(newPosts),
            currentPage: state.currentPage + 1,
            hasReachedMax: newPosts.length < _postsPerPage,
          ));
        }
      },
    );
  }

  /// Toggle like on a post
  Future<void> _onPostLikeToggled(
    FeedPostLikeToggled event,
    Emitter<FeedState> emit,
  ) async {
    // Optimistic update
    final updatedPosts = state.posts.map((post) {
      if (post.id == event.postId) {
        return PostModel(
          id: post.id,
          userId: post.userId,
          content: post.content,
          mediaUrls: post.mediaUrls,
          likeCount: event.isCurrentlyLiked
              ? post.likeCount - 1
              : post.likeCount + 1,
          commentCount: post.commentCount,
          shareCount: post.shareCount,
          isLiked: !event.isCurrentlyLiked,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
        );
      }
      return post;
    }).toList();

    emit(state.copyWith(posts: updatedPosts));

    // Make API call
    final result = event.isCurrentlyLiked
        ? await postRepository.unlikePost(event.postId)
        : await postRepository.likePost(event.postId);

    result.fold(
      (error) {
        AppLogger.error('Failed to toggle like: $error');
        // Revert optimistic update on error
        emit(state.copyWith(
          posts: state.posts,
          errorMessage: error,
        ));
      },
      (_) {
        AppLogger.info('Post like toggled successfully');
      },
    );
  }

  /// Share a post
  Future<void> _onPostShared(
    FeedPostShared event,
    Emitter<FeedState> emit,
  ) async {
    final result = await postRepository.sharePost(event.postId, event.shareText);

    result.fold(
      (error) {
        AppLogger.error('Failed to share post: $error');
        emit(state.copyWith(errorMessage: error));
      },
      (_) {
        // Update share count
        final updatedPosts = state.posts.map((post) {
          if (post.id == event.postId) {
            return PostModel(
              id: post.id,
              userId: post.userId,
              content: post.content,
              mediaUrls: post.mediaUrls,
              likeCount: post.likeCount,
              commentCount: post.commentCount,
              shareCount: post.shareCount + 1,
              isLiked: post.isLiked,
              createdAt: post.createdAt,
              updatedAt: post.updatedAt,
            );
          }
          return post;
        }).toList();

        emit(state.copyWith(
          posts: updatedPosts,
          successMessage: 'Post shared successfully',
        ));
      },
    );
  }

  /// Delete a post
  Future<void> _onPostDeleted(
    FeedPostDeleted event,
    Emitter<FeedState> emit,
  ) async {
    final result = await postRepository.deletePost(event.postId);

    result.fold(
      (error) {
        AppLogger.error('Failed to delete post: $error');
        emit(state.copyWith(errorMessage: error));
      },
      (_) {
        // Remove post from list
        final updatedPosts = state.posts
            .where((post) => post.id != event.postId)
            .toList();

        emit(state.copyWith(
          posts: updatedPosts,
          successMessage: 'Post deleted successfully',
        ));
      },
    );
  }

  /// Create a new post with image upload
  Future<void> _onPostCreated(
    FeedPostCreated event,
    Emitter<FeedState> emit,
  ) async {
    try {
      // Step 1: Create the post first (without attachments)
      final createResult = await postRepository.createPost(
        event.content,
        [], // Empty media URLs for now
      );

      await createResult.fold(
        (error) async {
          AppLogger.error('Failed to create post: $error');
          emit(state.copyWith(errorMessage: error));
        },
        (newPost) async {
          // Step 2: Upload images if any
          if (event.images.isNotEmpty) {
            try {
              // Upload all images
              final attachments = await mediaDataSource.uploadMultipleImages(
                newPost.id,
                event.images,
              );

              // Step 3: Fetch updated post with attachments
              final updatedPost = PostModel(
                id: newPost.id,
                userId: newPost.userId,
                content: newPost.content,
                mediaUrls: newPost.mediaUrls,
                attachments: attachments,
                likeCount: newPost.likeCount,
                commentCount: newPost.commentCount,
                shareCount: newPost.shareCount,
                isLiked: newPost.isLiked,
                createdAt: newPost.createdAt,
                updatedAt: newPost.updatedAt,
              );

              // Add new post with images to the beginning of the list
              final updatedPosts = [updatedPost, ...state.posts];

              emit(state.copyWith(
                posts: updatedPosts,
                successMessage: 'Post created successfully with ${attachments.length} image(s)',
              ));
            } catch (uploadError) {
              AppLogger.error('Failed to upload images: $uploadError');

              // Still add the post but show warning about images
              final updatedPosts = [newPost, ...state.posts];
              emit(state.copyWith(
                posts: updatedPosts,
                errorMessage: 'Post created but failed to upload images',
              ));
            }
          } else {
            // No images, just add the post
            final updatedPosts = [newPost, ...state.posts];
            emit(state.copyWith(
              posts: updatedPosts,
              successMessage: 'Post created successfully',
            ));
          }
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error creating post: $e');
      emit(state.copyWith(errorMessage: 'Failed to create post: $e'));
    }
  }
}

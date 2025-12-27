import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial feed posts
class FeedLoadRequested extends FeedEvent {
  const FeedLoadRequested();
}

/// Refresh feed posts (pull to refresh)
class FeedRefreshRequested extends FeedEvent {
  const FeedRefreshRequested();
}

/// Load more posts (pagination)
class FeedLoadMoreRequested extends FeedEvent {
  const FeedLoadMoreRequested();
}

/// Like a post
class FeedPostLikeToggled extends FeedEvent {
  final String postId;
  final bool isCurrentlyLiked;

  const FeedPostLikeToggled({
    required this.postId,
    required this.isCurrentlyLiked,
  });

  @override
  List<Object?> get props => [postId, isCurrentlyLiked];
}

/// Share a post
class FeedPostShared extends FeedEvent {
  final String postId;
  final String shareText;

  const FeedPostShared({
    required this.postId,
    this.shareText = '',
  });

  @override
  List<Object?> get props => [postId, shareText];
}

/// Delete a post
class FeedPostDeleted extends FeedEvent {
  final String postId;

  const FeedPostDeleted({required this.postId});

  @override
  List<Object?> get props => [postId];
}

/// Create a new post
class FeedPostCreated extends FeedEvent {
  final String content;
  final List<File> images;

  const FeedPostCreated({
    required this.content,
    this.images = const [],
  });

  @override
  List<Object?> get props => [content, images];
}

/// Fetch comments for a post
class FeedCommentFetchRequested extends FeedEvent {
  final String postId;

  const FeedCommentFetchRequested({required this.postId});

  @override
  List<Object?> get props => [postId];
}

/// Add a comment to a post
class FeedCommentAddRequested extends FeedEvent {
  final String postId;
  final String content;

  const FeedCommentAddRequested({
    required this.postId,
    required this.content,
  });

  @override
  List<Object?> get props => [postId, content];
}

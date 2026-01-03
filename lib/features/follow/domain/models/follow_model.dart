import 'package:equatable/equatable.dart';

class FollowModel extends Equatable {
  final String id;
  final String followerId;
  final String followingId;
  final String status;
  final DateTime createdAt;

  const FollowModel({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.status,
    required this.createdAt,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) {
    return FollowModel(
      id: json['id'] as String,
      followerId: json['follower_id'] as String,
      followingId: json['following_id'] as String,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, followerId, followingId, status, createdAt];
}

class FollowUserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? headline;
  final bool isFollowing;

  const FollowUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.headline,
    this.isFollowing = false,
  });

  factory FollowUserModel.fromJson(Map<String, dynamic> json) {
    return FollowUserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photo_url'] as String?,
      headline: json['headline'] as String?,
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
      'headline': headline,
      'is_following': isFollowing,
    };
  }

  FollowUserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? headline,
    bool? isFollowing,
  }) {
    return FollowUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      headline: headline ?? this.headline,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [id, name, email, photoUrl, headline, isFollowing];
}

class FollowStatsModel extends Equatable {
  final int followersCount;
  final int followingCount;

  const FollowStatsModel({
    required this.followersCount,
    required this.followingCount,
  });

  factory FollowStatsModel.fromJson(Map<String, dynamic> json) {
    return FollowStatsModel(
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'followers_count': followersCount,
      'following_count': followingCount,
    };
  }

  @override
  List<Object?> get props => [followersCount, followingCount];
}

class FollowStatusModel extends Equatable {
  final bool isFollowing;

  const FollowStatusModel({required this.isFollowing});

  factory FollowStatusModel.fromJson(Map<String, dynamic> json) {
    return FollowStatusModel(
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [isFollowing];
}

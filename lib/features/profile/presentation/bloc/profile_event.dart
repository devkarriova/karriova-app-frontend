import 'package:equatable/equatable.dart';

/// Base class for all profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load a specific user's profile
class ProfileLoadRequested extends ProfileEvent {
  final String userId;

  const ProfileLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to load the current user's profile
class ProfileLoadMyProfileRequested extends ProfileEvent {
  const ProfileLoadMyProfileRequested();
}

/// Event to refresh the current profile
class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}

/// Event to update profile bio
class ProfileBioUpdated extends ProfileEvent {
  final String bio;

  const ProfileBioUpdated({required this.bio});

  @override
  List<Object?> get props => [bio];
}

/// Event to update profile headline
class ProfileHeadlineUpdated extends ProfileEvent {
  final String headline;

  const ProfileHeadlineUpdated({required this.headline});

  @override
  List<Object?> get props => [headline];
}

/// Event to update profile location
class ProfileLocationUpdated extends ProfileEvent {
  final String location;

  const ProfileLocationUpdated({required this.location});

  @override
  List<Object?> get props => [location];
}

/// Event to update profile website
class ProfileWebsiteUpdated extends ProfileEvent {
  final String website;

  const ProfileWebsiteUpdated({required this.website});

  @override
  List<Object?> get props => [website];
}

/// Event to update profile skills
class ProfileSkillsUpdated extends ProfileEvent {
  final List<String> skills;

  const ProfileSkillsUpdated({required this.skills});

  @override
  List<Object?> get props => [skills];
}

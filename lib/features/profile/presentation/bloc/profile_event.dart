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

/// Event to update personal details (name, email, bio, headline, website, visibility)
class ProfilePersonalDetailsUpdated extends ProfileEvent {
  final String? name;
  final String? email;
  final String? bio;
  final String? headline;
  final String? website;
  final bool? isPublic;

  const ProfilePersonalDetailsUpdated({
    this.name,
    this.email,
    this.bio,
    this.headline,
    this.website,
    this.isPublic,
  });

  @override
  List<Object?> get props => [name, email, bio, headline, website, isPublic];
}

/// Event to add a skill
class ProfileSkillAdded extends ProfileEvent {
  final String skill;

  const ProfileSkillAdded({required this.skill});

  @override
  List<Object?> get props => [skill];
}

/// Event to delete a skill
class ProfileSkillDeleted extends ProfileEvent {
  final String skill;

  const ProfileSkillDeleted({required this.skill});

  @override
  List<Object?> get props => [skill];
}

/// Event to add experience
class ProfileExperienceAdded extends ProfileEvent {
  final String title;
  final String company;
  final String companyId;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool current;
  final String description;

  const ProfileExperienceAdded({
    required this.title,
    required this.company,
    required this.companyId,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.current,
    required this.description,
  });

  @override
  List<Object?> get props => [title, company, companyId, location, startDate, endDate, current, description];
}

/// Event to update experience
class ProfileExperienceUpdated extends ProfileEvent {
  final int index;
  final String title;
  final String company;
  final String companyId;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool current;
  final String description;

  const ProfileExperienceUpdated({
    required this.index,
    required this.title,
    required this.company,
    required this.companyId,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.current,
    required this.description,
  });

  @override
  List<Object?> get props => [index, title, company, companyId, location, startDate, endDate, current, description];
}

/// Event to delete experience
class ProfileExperienceDeleted extends ProfileEvent {
  final int index;

  const ProfileExperienceDeleted({required this.index});

  @override
  List<Object?> get props => [index];
}

/// Event to add education
class ProfileEducationAdded extends ProfileEvent {
  final String degree;
  final String institution;
  final DateTime startDate;
  final DateTime endDate;
  final String grade;
  final List<String> achievements;

  const ProfileEducationAdded({
    required this.degree,
    required this.institution,
    required this.startDate,
    required this.endDate,
    required this.grade,
    required this.achievements,
  });

  @override
  List<Object?> get props => [degree, institution, startDate, endDate, grade, achievements];
}

/// Event to update education
class ProfileEducationUpdated extends ProfileEvent {
  final int index;
  final String degree;
  final String institution;
  final DateTime startDate;
  final DateTime endDate;
  final String grade;
  final List<String> achievements;

  const ProfileEducationUpdated({
    required this.index,
    required this.degree,
    required this.institution,
    required this.startDate,
    required this.endDate,
    required this.grade,
    required this.achievements,
  });

  @override
  List<Object?> get props => [index, degree, institution, startDate, endDate, grade, achievements];
}

/// Event to delete education
class ProfileEducationDeleted extends ProfileEvent {
  final int index;

  const ProfileEducationDeleted({required this.index});

  @override
  List<Object?> get props => [index];
}

/// Event to add certification
class ProfileCertificationAdded extends ProfileEvent {
  final String name;
  final String issuer;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String credentialUrl;

  const ProfileCertificationAdded({
    required this.name,
    required this.issuer,
    required this.issueDate,
    this.expiryDate,
    required this.credentialUrl,
  });

  @override
  List<Object?> get props => [name, issuer, issueDate, expiryDate, credentialUrl];
}

/// Event to update certification
class ProfileCertificationUpdated extends ProfileEvent {
  final int index;
  final String name;
  final String issuer;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String credentialUrl;

  const ProfileCertificationUpdated({
    required this.index,
    required this.name,
    required this.issuer,
    required this.issueDate,
    this.expiryDate,
    required this.credentialUrl,
  });

  @override
  List<Object?> get props => [index, name, issuer, issueDate, expiryDate, credentialUrl];
}

/// Event to delete certification
class ProfileCertificationDeleted extends ProfileEvent {
  final int index;

  const ProfileCertificationDeleted({required this.index});

  @override
  List<Object?> get props => [index];
}

/// Event to add project
class ProfileProjectAdded extends ProfileEvent {
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool current;
  final String url;
  final List<String> technologies;

  const ProfileProjectAdded({
    required this.name,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.current,
    required this.url,
    required this.technologies,
  });

  @override
  List<Object?> get props => [name, description, startDate, endDate, current, url, technologies];
}

/// Event to update project
class ProfileProjectUpdated extends ProfileEvent {
  final int index;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool current;
  final String url;
  final List<String> technologies;

  const ProfileProjectUpdated({
    required this.index,
    required this.name,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.current,
    required this.url,
    required this.technologies,
  });

  @override
  List<Object?> get props => [index, name, description, startDate, endDate, current, url, technologies];
}

/// Event to delete project
class ProfileProjectDeleted extends ProfileEvent {
  final int index;

  const ProfileProjectDeleted({required this.index});

  @override
  List<Object?> get props => [index];
}

/// Event to add award
class ProfileAwardAdded extends ProfileEvent {
  final String title;
  final String issuer;
  final DateTime date;
  final String description;

  const ProfileAwardAdded({
    required this.title,
    required this.issuer,
    required this.date,
    required this.description,
  });

  @override
  List<Object?> get props => [title, issuer, date, description];
}

/// Event to update award
class ProfileAwardUpdated extends ProfileEvent {
  final int index;
  final String title;
  final String issuer;
  final DateTime date;
  final String description;

  const ProfileAwardUpdated({
    required this.index,
    required this.title,
    required this.issuer,
    required this.date,
    required this.description,
  });

  @override
  List<Object?> get props => [index, title, issuer, date, description];
}

/// Event to delete award
class ProfileAwardDeleted extends ProfileEvent {
  final int index;

  const ProfileAwardDeleted({required this.index});

  @override
  List<Object?> get props => [index];
}

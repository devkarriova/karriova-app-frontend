import 'package:equatable/equatable.dart';
import 'education_model.dart';
import 'experience_model.dart';
import 'skill_model.dart';
import 'certification_model.dart';
import 'project_model.dart';
import 'language_model.dart';
import 'award_model.dart';

/// Comprehensive user profile that aggregates all profile data
class UserProfileModel extends Equatable {
  final String userId;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? bio;
  final String? headline;
  final String? location;
  final String? website;
  final List<EducationModel> education;
  final List<ExperienceModel> experience;
  final List<SkillModel> skills;
  final List<CertificationModel> certifications;
  final List<ProjectModel> projects;
  final List<LanguageModel> languages;
  final List<AwardModel> awards;

  const UserProfileModel({
    required this.userId,
    required this.email,
    this.name,
    this.photoUrl,
    this.bio,
    this.headline,
    this.location,
    this.website,
    this.education = const [],
    this.experience = const [],
    this.skills = const [],
    this.certifications = const [],
    this.projects = const [],
    this.languages = const [],
    this.awards = const [],
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      photoUrl: json['photo_url'] as String?,
      bio: json['bio'] as String?,
      headline: json['headline'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      education: json['education'] != null
          ? (json['education'] as List)
              .map((e) => EducationModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      experience: json['experience'] != null
          ? (json['experience'] as List)
              .map((e) => ExperienceModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      skills: json['skills'] != null
          ? (json['skills'] as List)
              .map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      certifications: json['certifications'] != null
          ? (json['certifications'] as List)
              .map((e) => CertificationModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      projects: json['projects'] != null
          ? (json['projects'] as List)
              .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      languages: json['languages'] != null
          ? (json['languages'] as List)
              .map((e) => LanguageModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      awards: json['awards'] != null
          ? (json['awards'] as List)
              .map((e) => AwardModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'bio': bio,
      'headline': headline,
      'location': location,
      'website': website,
      'education': education.map((e) => e.toJson()).toList(),
      'experience': experience.map((e) => e.toJson()).toList(),
      'skills': skills.map((e) => e.toJson()).toList(),
      'certifications': certifications.map((e) => e.toJson()).toList(),
      'projects': projects.map((e) => e.toJson()).toList(),
      'languages': languages.map((e) => e.toJson()).toList(),
      'awards': awards.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        name,
        photoUrl,
        bio,
        headline,
        location,
        website,
        education,
        experience,
        skills,
        certifications,
        projects,
        languages,
        awards,
      ];
}

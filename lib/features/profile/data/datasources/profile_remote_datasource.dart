import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/profile_model.dart';
import '../../domain/models/user_profile_model.dart';
import '../../domain/models/education_model.dart';
import '../../domain/models/experience_model.dart';
import '../../domain/models/skill_model.dart';
import '../../domain/models/certification_model.dart';
import '../../domain/models/project_model.dart';
import '../../domain/models/language_model.dart';
import '../../domain/models/award_model.dart';

/// Profile remote data source interface
abstract class ProfileRemoteDataSource {
  /// Get profile by user ID (legacy)
  Future<ProfileModel> getProfile(String userId);

  /// Get current user's profile (legacy)
  Future<ProfileModel> getMyProfile();

  /// Create a new profile (legacy)
  Future<ProfileModel> createProfile({
    required String bio,
    required String headline,
    required String location,
    required String website,
    required List<String> skills,
  });

  /// Update profile (legacy)
  Future<ProfileModel> updateProfile({
    String? bio,
    String? headline,
    String? location,
    String? website,
    List<String>? skills,
    List<Experience>? experience,
    List<Education>? education,
    List<Certification>? certifications,
    List<Project>? projects,
    List<Award>? awards,
  });

  // ========== NEW PROFILE METHODS ==========

  /// Get complete user profile with all related data
  Future<UserProfileModel> getUserProfile(String userId);

  /// Update basic profile information
  Future<void> updateBasicProfile({
    required String userId,
    String? name,
    String? bio,
    String? headline,
    String? location,
    String? website,
  });

  // Education CRUD
  Future<List<EducationModel>> getEducation(String userId);
  Future<EducationModel> addEducation(EducationModel education);
  Future<EducationModel> updateEducation(EducationModel education);
  Future<void> deleteEducation(String educationId);

  // Experience CRUD
  Future<List<ExperienceModel>> getExperience(String userId);
  Future<ExperienceModel> addExperience(ExperienceModel experience);
  Future<ExperienceModel> updateExperience(ExperienceModel experience);
  Future<void> deleteExperience(String experienceId);

  // Skills CRUD
  Future<List<SkillModel>> getSkills(String userId);
  Future<SkillModel> addSkill(SkillModel skill);
  Future<SkillModel> updateSkill(SkillModel skill);
  Future<void> deleteSkill(String skillId);

  // Certifications CRUD
  Future<List<CertificationModel>> getCertifications(String userId);
  Future<CertificationModel> addCertification(CertificationModel certification);
  Future<CertificationModel> updateCertification(CertificationModel certification);
  Future<void> deleteCertification(String certificationId);

  // Projects CRUD
  Future<List<ProjectModel>> getProjects(String userId);
  Future<ProjectModel> addProject(ProjectModel project);
  Future<ProjectModel> updateProject(ProjectModel project);
  Future<void> deleteProject(String projectId);

  // Languages CRUD
  Future<List<LanguageModel>> getLanguages(String userId);
  Future<LanguageModel> addLanguage(LanguageModel language);
  Future<LanguageModel> updateLanguage(LanguageModel language);
  Future<void> deleteLanguage(String languageId);

  // Awards CRUD
  Future<List<AwardModel>> getAwards(String userId);
  Future<AwardModel> addAward(AwardModel award);
  Future<AwardModel> updateAward(AwardModel award);
  Future<void> deleteAward(String awardId);
}

/// Profile remote data source implementation
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final endpoint = AppConfig.profileEndpoint.replaceAll('{userId}', userId);
      final response = await apiClient.get(endpoint, requiresAuth: true);

      if (response.isSuccess && response.data != null) {
        return ProfileModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to get profile');
      }
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  @override
  Future<ProfileModel> getMyProfile() async {
    try {
      final response = await apiClient.get(AppConfig.myProfileEndpoint, requiresAuth: true);

      if (response.isSuccess && response.data != null) {
        return ProfileModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to get my profile');
      }
    } catch (e) {
      throw Exception('Failed to get my profile: $e');
    }
  }

  @override
  Future<ProfileModel> createProfile({
    required String bio,
    required String headline,
    required String location,
    required String website,
    required List<String> skills,
  }) async {
    try {
      final response = await apiClient.post(
        AppConfig.createProfileEndpoint,
        body: {
          'bio': bio,
          'headline': headline,
          'location': location,
          'website': website,
          'skills': skills,
        },
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return ProfileModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to create profile');
      }
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    String? bio,
    String? headline,
    String? location,
    String? website,
    List<String>? skills,
    List<Experience>? experience,
    List<Education>? education,
    List<Certification>? certifications,
    List<Project>? projects,
    List<Award>? awards,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (bio != null) body['bio'] = bio;
      if (headline != null) body['headline'] = headline;
      if (location != null) body['location'] = location;
      if (website != null) body['website'] = website;
      if (skills != null) body['skills'] = skills;
      if (experience != null) body['experience'] = experience.map((e) => e.toJson()).toList();
      if (education != null) body['education'] = education.map((e) => e.toJson()).toList();
      if (certifications != null) body['certifications'] = certifications.map((e) => e.toJson()).toList();
      if (projects != null) body['projects'] = projects.map((e) => e.toJson()).toList();
      if (awards != null) body['awards'] = awards.map((e) => e.toJson()).toList();

      final response = await apiClient.put(
        AppConfig.updateProfileUserEndpoint,
        body: body,
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return ProfileModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // ========== NEW PROFILE METHODS ==========
  // NOTE: These methods are stubs and will be implemented when backend endpoints are ready

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      final response = await apiClient.get('/api/profile/$userId/full', requiresAuth: true);

      if (response.isSuccess && response.data != null) {
        return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to get user profile');
      }
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<void> updateBasicProfile({
    required String userId,
    String? name,
    String? bio,
    String? headline,
    String? location,
    String? website,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (bio != null) body['bio'] = bio;
      if (headline != null) body['headline'] = headline;
      if (location != null) body['location'] = location;
      if (website != null) body['website'] = website;

      final response = await apiClient.put(
        '/api/v1/profiles/me/basic',
        body: body,
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        throw Exception(response.errorMessage ?? 'Failed to update basic profile');
      }
    } catch (e) {
      throw Exception('Failed to update basic profile: $e');
    }
  }

  // Education CRUD
  @override
  Future<List<EducationModel>> getEducation(String userId) async {
    try {
      final response = await apiClient.get('/api/profile/$userId/education', requiresAuth: true);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((e) => EducationModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.errorMessage ?? 'Failed to get education');
      }
    } catch (e) {
      throw Exception('Failed to get education: $e');
    }
  }

  @override
  Future<EducationModel> addEducation(EducationModel education) async {
    try {
      final response = await apiClient.post(
        '/api/profile/education',
        body: education.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return EducationModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to add education');
      }
    } catch (e) {
      throw Exception('Failed to add education: $e');
    }
  }

  @override
  Future<EducationModel> updateEducation(EducationModel education) async {
    try {
      final response = await apiClient.put(
        '/api/profile/education/${education.id}',
        body: education.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return EducationModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to update education');
      }
    } catch (e) {
      throw Exception('Failed to update education: $e');
    }
  }

  @override
  Future<void> deleteEducation(String educationId) async {
    try {
      final response = await apiClient.delete(
        '/api/profile/education/$educationId',
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        throw Exception(response.errorMessage ?? 'Failed to delete education');
      }
    } catch (e) {
      throw Exception('Failed to delete education: $e');
    }
  }

  // Experience CRUD
  @override
  Future<List<ExperienceModel>> getExperience(String userId) async {
    try {
      final response = await apiClient.get('/api/profile/$userId/experience', requiresAuth: true);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((e) => ExperienceModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.errorMessage ?? 'Failed to get experience');
      }
    } catch (e) {
      throw Exception('Failed to get experience: $e');
    }
  }

  @override
  Future<ExperienceModel> addExperience(ExperienceModel experience) async {
    try {
      final response = await apiClient.post(
        '/api/profile/experience',
        body: experience.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return ExperienceModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to add experience');
      }
    } catch (e) {
      throw Exception('Failed to add experience: $e');
    }
  }

  @override
  Future<ExperienceModel> updateExperience(ExperienceModel experience) async {
    try {
      final response = await apiClient.put(
        '/api/profile/experience/${experience.id}',
        body: experience.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return ExperienceModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to update experience');
      }
    } catch (e) {
      throw Exception('Failed to update experience: $e');
    }
  }

  @override
  Future<void> deleteExperience(String experienceId) async {
    try {
      final response = await apiClient.delete(
        '/api/profile/experience/$experienceId',
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        throw Exception(response.errorMessage ?? 'Failed to delete experience');
      }
    } catch (e) {
      throw Exception('Failed to delete experience: $e');
    }
  }

  // Skills CRUD
  @override
  Future<List<SkillModel>> getSkills(String userId) async {
    try {
      final response = await apiClient.get('/api/profile/$userId/skills', requiresAuth: true);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((e) => SkillModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.errorMessage ?? 'Failed to get skills');
      }
    } catch (e) {
      throw Exception('Failed to get skills: $e');
    }
  }

  @override
  Future<SkillModel> addSkill(SkillModel skill) async {
    try {
      final response = await apiClient.post(
        '/api/profile/skills',
        body: skill.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return SkillModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to add skill');
      }
    } catch (e) {
      throw Exception('Failed to add skill: $e');
    }
  }

  @override
  Future<SkillModel> updateSkill(SkillModel skill) async {
    try {
      final response = await apiClient.put(
        '/api/profile/skills/${skill.id}',
        body: skill.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return SkillModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to update skill');
      }
    } catch (e) {
      throw Exception('Failed to update skill: $e');
    }
  }

  @override
  Future<void> deleteSkill(String skillId) async {
    try {
      final response = await apiClient.delete(
        '/api/profile/skills/$skillId',
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        throw Exception(response.errorMessage ?? 'Failed to delete skill');
      }
    } catch (e) {
      throw Exception('Failed to delete skill: $e');
    }
  }

  // Certifications CRUD
  @override
  Future<List<CertificationModel>> getCertifications(String userId) async {
    try {
      final response = await apiClient.get('/api/profile/$userId/certifications', requiresAuth: true);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((e) => CertificationModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.errorMessage ?? 'Failed to get certifications');
      }
    } catch (e) {
      throw Exception('Failed to get certifications: $e');
    }
  }

  @override
  Future<CertificationModel> addCertification(CertificationModel certification) async {
    try {
      final response = await apiClient.post(
        '/api/profile/certifications',
        body: certification.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return CertificationModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to add certification');
      }
    } catch (e) {
      throw Exception('Failed to add certification: $e');
    }
  }

  @override
  Future<CertificationModel> updateCertification(CertificationModel certification) async {
    try {
      final response = await apiClient.put(
        '/api/profile/certifications/${certification.id}',
        body: certification.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return CertificationModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to update certification');
      }
    } catch (e) {
      throw Exception('Failed to update certification: $e');
    }
  }

  @override
  Future<void> deleteCertification(String certificationId) async {
    try {
      final response = await apiClient.delete(
        '/api/profile/certifications/$certificationId',
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        throw Exception(response.errorMessage ?? 'Failed to delete certification');
      }
    } catch (e) {
      throw Exception('Failed to delete certification: $e');
    }
  }

  // Projects CRUD
  @override
  Future<List<ProjectModel>> getProjects(String userId) async {
    try {
      final response = await apiClient.get('/api/profile/$userId/projects', requiresAuth: true);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.errorMessage ?? 'Failed to get projects');
      }
    } catch (e) {
      throw Exception('Failed to get projects: $e');
    }
  }

  @override
  Future<ProjectModel> addProject(ProjectModel project) async {
    try {
      final response = await apiClient.post(
        '/api/profile/projects',
        body: project.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return ProjectModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to add project');
      }
    } catch (e) {
      throw Exception('Failed to add project: $e');
    }
  }

  @override
  Future<ProjectModel> updateProject(ProjectModel project) async {
    try {
      final response = await apiClient.put(
        '/api/profile/projects/${project.id}',
        body: project.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return ProjectModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to update project');
      }
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      final response = await apiClient.delete(
        '/api/profile/projects/$projectId',
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        throw Exception(response.errorMessage ?? 'Failed to delete project');
      }
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }

  // Languages CRUD
  @override
  Future<List<LanguageModel>> getLanguages(String userId) async {
    try {
      final response = await apiClient.get('/api/profile/$userId/languages', requiresAuth: true);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((e) => LanguageModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.errorMessage ?? 'Failed to get languages');
      }
    } catch (e) {
      throw Exception('Failed to get languages: $e');
    }
  }

  @override
  Future<LanguageModel> addLanguage(LanguageModel language) async {
    try {
      final response = await apiClient.post(
        '/api/profile/languages',
        body: language.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return LanguageModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to add language');
      }
    } catch (e) {
      throw Exception('Failed to add language: $e');
    }
  }

  @override
  Future<LanguageModel> updateLanguage(LanguageModel language) async {
    try {
      final response = await apiClient.put(
        '/api/profile/languages/${language.id}',
        body: language.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return LanguageModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to update language');
      }
    } catch (e) {
      throw Exception('Failed to update language: $e');
    }
  }

  @override
  Future<void> deleteLanguage(String languageId) async {
    try {
      final response = await apiClient.delete(
        '/api/profile/languages/$languageId',
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        throw Exception(response.errorMessage ?? 'Failed to delete language');
      }
    } catch (e) {
      throw Exception('Failed to delete language: $e');
    }
  }

  // Awards CRUD
  @override
  Future<List<AwardModel>> getAwards(String userId) async {
    try {
      final response = await apiClient.get('/api/profile/$userId/awards', requiresAuth: true);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((e) => AwardModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.errorMessage ?? 'Failed to get awards');
      }
    } catch (e) {
      throw Exception('Failed to get awards: $e');
    }
  }

  @override
  Future<AwardModel> addAward(AwardModel award) async {
    try {
      final response = await apiClient.post(
        '/api/profile/awards',
        body: award.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return AwardModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to add award');
      }
    } catch (e) {
      throw Exception('Failed to add award: $e');
    }
  }

  @override
  Future<AwardModel> updateAward(AwardModel award) async {
    try {
      final response = await apiClient.put(
        '/api/profile/awards/${award.id}',
        body: award.toJson(),
        requiresAuth: true,
      );

      if (response.isSuccess && response.data != null) {
        return AwardModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(response.errorMessage ?? 'Failed to update award');
      }
    } catch (e) {
      throw Exception('Failed to update award: $e');
    }
  }

  @override
  Future<void> deleteAward(String awardId) async {
    try {
      final response = await apiClient.delete(
        '/api/profile/awards/$awardId',
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        throw Exception(response.errorMessage ?? 'Failed to delete award');
      }
    } catch (e) {
      throw Exception('Failed to delete award: $e');
    }
  }
}

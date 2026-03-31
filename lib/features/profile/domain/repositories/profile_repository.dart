import 'package:dartz/dartz.dart';
import '../models/profile_model.dart';
import '../models/user_profile_model.dart';
import '../models/education_model.dart';
import '../models/experience_model.dart';
import '../models/skill_model.dart';
import '../models/certification_model.dart';
import '../models/project_model.dart';
import '../models/language_model.dart';
import '../models/award_model.dart';

/// Profile repository interface
/// Returns Either<String, T> where String is error message and T is success result
abstract class ProfileRepository {
  /// Get profile by user ID (legacy, for backward compatibility)
  Future<Either<String, ProfileModel>> getProfile(String userId);

  /// Get current user's profile (legacy, for backward compatibility)
  Future<Either<String, ProfileModel>> getMyProfile();

  /// Create a new profile (legacy, for backward compatibility)
  Future<Either<String, ProfileModel>> createProfile({
    required String bio,
    required String headline,
    required String location,
    required String website,
    required List<String> skills,
  });

  /// Update profile (legacy, for backward compatibility)
  Future<Either<String, ProfileModel>> updateProfile({
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
    List<Language>? languages,
  });

  // ========== NEW PROFILE METHODS ==========

  /// Get complete user profile with all related data
  Future<Either<String, UserProfileModel>> getUserProfile(String userId);

  /// Update basic profile information
  Future<Either<String, void>> updateBasicProfile({
    required String userId,
    String? name,
    String? bio,
    String? headline,
    String? location,
    String? website,
  });

  // Education CRUD
  Future<Either<String, List<EducationModel>>> getEducation(String userId);
  Future<Either<String, EducationModel>> addEducation(EducationModel education);
  Future<Either<String, EducationModel>> updateEducation(EducationModel education);
  Future<Either<String, void>> deleteEducation(String educationId);

  // Experience CRUD
  Future<Either<String, List<ExperienceModel>>> getExperience(String userId);
  Future<Either<String, ExperienceModel>> addExperience(ExperienceModel experience);
  Future<Either<String, ExperienceModel>> updateExperience(ExperienceModel experience);
  Future<Either<String, void>> deleteExperience(String experienceId);

  // Skills CRUD
  Future<Either<String, List<SkillModel>>> getSkills(String userId);
  Future<Either<String, SkillModel>> addSkill(SkillModel skill);
  Future<Either<String, SkillModel>> updateSkill(SkillModel skill);
  Future<Either<String, void>> deleteSkill(String skillId);

  // Certifications CRUD
  Future<Either<String, List<CertificationModel>>> getCertifications(String userId);
  Future<Either<String, CertificationModel>> addCertification(CertificationModel certification);
  Future<Either<String, CertificationModel>> updateCertification(CertificationModel certification);
  Future<Either<String, void>> deleteCertification(String certificationId);

  // Projects CRUD
  Future<Either<String, List<ProjectModel>>> getProjects(String userId);
  Future<Either<String, ProjectModel>> addProject(ProjectModel project);
  Future<Either<String, ProjectModel>> updateProject(ProjectModel project);
  Future<Either<String, void>> deleteProject(String projectId);

  // Languages CRUD
  Future<Either<String, List<LanguageModel>>> getLanguages(String userId);
  Future<Either<String, LanguageModel>> addLanguage(LanguageModel language);
  Future<Either<String, LanguageModel>> updateLanguage(LanguageModel language);
  Future<Either<String, void>> deleteLanguage(String languageId);

  // Awards CRUD
  Future<Either<String, List<AwardModel>>> getAwards(String userId);
  Future<Either<String, AwardModel>> addAward(AwardModel award);
  Future<Either<String, AwardModel>> updateAward(AwardModel award);
  Future<Either<String, void>> deleteAward(String awardId);

  /// Update onboarding profile (all student fields collected during setup)
  Future<Either<String, void>> updateOnboardingProfile({
    String? board,
    String? classGrade,
    String? schoolName,
    String? stream,
    String? gender,
    String? location,
    String? careerGoalStatus,
    String? careerGoalText,
    List<String>? generalInterests,
    List<String>? skills,
  });
}

import 'package:dartz/dartz.dart';
import '../../domain/models/profile_model.dart';
import '../../domain/models/user_profile_model.dart';
import '../../domain/models/education_model.dart';
import '../../domain/models/experience_model.dart';
import '../../domain/models/skill_model.dart';
import '../../domain/models/certification_model.dart';
import '../../domain/models/project_model.dart';
import '../../domain/models/language_model.dart';
import '../../domain/models/award_model.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

/// Profile repository implementation with error handling
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, ProfileModel>> getProfile(String userId) async {
    try {
      final profile = await remoteDataSource.getProfile(userId);
      return Right(profile);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, ProfileModel>> getMyProfile() async {
    try {
      final profile = await remoteDataSource.getMyProfile();
      return Right(profile);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, ProfileModel>> createProfile({
    required String bio,
    required String headline,
    required String location,
    required String website,
    required List<String> skills,
  }) async {
    try {
      final profile = await remoteDataSource.createProfile(
        bio: bio,
        headline: headline,
        location: location,
        website: website,
        skills: skills,
      );
      return Right(profile);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
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
  }) async {
    try {
      final profile = await remoteDataSource.updateProfile(
        bio: bio,
        headline: headline,
        location: location,
        website: website,
        skills: skills,
        experience: experience,
        education: education,
        certifications: certifications,
        projects: projects,
        awards: awards,
        languages: languages,
      );
      return Right(profile);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // ========== NEW PROFILE METHODS ==========

  @override
  Future<Either<String, UserProfileModel>> getUserProfile(String userId) async {
    try {
      final profile = await remoteDataSource.getUserProfile(userId);
      return Right(profile);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> updateBasicProfile({
    required String userId,
    String? name,
    String? bio,
    String? headline,
    String? location,
    String? website,
  }) async {
    try {
      await remoteDataSource.updateBasicProfile(
        userId: userId,
        name: name,
        bio: bio,
        headline: headline,
        location: location,
        website: website,
      );
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // Education CRUD
  @override
  Future<Either<String, List<EducationModel>>> getEducation(String userId) async {
    try {
      final education = await remoteDataSource.getEducation(userId);
      return Right(education);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, EducationModel>> addEducation(EducationModel education) async {
    try {
      final result = await remoteDataSource.addEducation(education);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, EducationModel>> updateEducation(EducationModel education) async {
    try {
      final result = await remoteDataSource.updateEducation(education);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> deleteEducation(String educationId) async {
    try {
      await remoteDataSource.deleteEducation(educationId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // Experience CRUD
  @override
  Future<Either<String, List<ExperienceModel>>> getExperience(String userId) async {
    try {
      final experience = await remoteDataSource.getExperience(userId);
      return Right(experience);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, ExperienceModel>> addExperience(ExperienceModel experience) async {
    try {
      final result = await remoteDataSource.addExperience(experience);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, ExperienceModel>> updateExperience(ExperienceModel experience) async {
    try {
      final result = await remoteDataSource.updateExperience(experience);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> deleteExperience(String experienceId) async {
    try {
      await remoteDataSource.deleteExperience(experienceId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // Skills CRUD
  @override
  Future<Either<String, List<SkillModel>>> getSkills(String userId) async {
    try {
      final skills = await remoteDataSource.getSkills(userId);
      return Right(skills);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, SkillModel>> addSkill(SkillModel skill) async {
    try {
      final result = await remoteDataSource.addSkill(skill);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, SkillModel>> updateSkill(SkillModel skill) async {
    try {
      final result = await remoteDataSource.updateSkill(skill);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> deleteSkill(String skillId) async {
    try {
      await remoteDataSource.deleteSkill(skillId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // Certifications CRUD
  @override
  Future<Either<String, List<CertificationModel>>> getCertifications(String userId) async {
    try {
      final certifications = await remoteDataSource.getCertifications(userId);
      return Right(certifications);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, CertificationModel>> addCertification(CertificationModel certification) async {
    try {
      final result = await remoteDataSource.addCertification(certification);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, CertificationModel>> updateCertification(CertificationModel certification) async {
    try {
      final result = await remoteDataSource.updateCertification(certification);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> deleteCertification(String certificationId) async {
    try {
      await remoteDataSource.deleteCertification(certificationId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // Projects CRUD
  @override
  Future<Either<String, List<ProjectModel>>> getProjects(String userId) async {
    try {
      final projects = await remoteDataSource.getProjects(userId);
      return Right(projects);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, ProjectModel>> addProject(ProjectModel project) async {
    try {
      final result = await remoteDataSource.addProject(project);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, ProjectModel>> updateProject(ProjectModel project) async {
    try {
      final result = await remoteDataSource.updateProject(project);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> deleteProject(String projectId) async {
    try {
      await remoteDataSource.deleteProject(projectId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // Languages CRUD
  @override
  Future<Either<String, List<LanguageModel>>> getLanguages(String userId) async {
    try {
      final languages = await remoteDataSource.getLanguages(userId);
      return Right(languages);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, LanguageModel>> addLanguage(LanguageModel language) async {
    try {
      final result = await remoteDataSource.addLanguage(language);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, LanguageModel>> updateLanguage(LanguageModel language) async {
    try {
      final result = await remoteDataSource.updateLanguage(language);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> deleteLanguage(String languageId) async {
    try {
      await remoteDataSource.deleteLanguage(languageId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // Awards CRUD
  @override
  Future<Either<String, List<AwardModel>>> getAwards(String userId) async {
    try {
      final awards = await remoteDataSource.getAwards(userId);
      return Right(awards);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, AwardModel>> addAward(AwardModel award) async {
    try {
      final result = await remoteDataSource.addAward(award);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, AwardModel>> updateAward(AwardModel award) async {
    try {
      final result = await remoteDataSource.updateAward(award);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> deleteAward(String awardId) async {
    try {
      await remoteDataSource.deleteAward(awardId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
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
  }) async {
    try {
      await remoteDataSource.updateOnboardingProfile(
        board: board,
        classGrade: classGrade,
        schoolName: schoolName,
        stream: stream,
        gender: gender,
        location: location,
        careerGoalStatus: careerGoalStatus,
        careerGoalText: careerGoalText,
        generalInterests: generalInterests,
        skills: skills,
      );
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Handle errors and return user-friendly messages
  String _handleError(dynamic error) {
    final errorMessage = error.toString();

    if (errorMessage.contains('Unauthorized')) {
      return 'Session expired. Please login again.';
    } else if (errorMessage.contains('not found')) {
      return 'Profile not found.';
    } else if (errorMessage.contains('Network error')) {
      return 'Network error. Please check your connection.';
    } else if (errorMessage.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (errorMessage.contains('Invalid')) {
      return 'Invalid data. Please check your input.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}

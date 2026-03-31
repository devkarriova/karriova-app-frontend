import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/models/profile_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Profile BLoC - Handles profile business logic with enterprise-level patterns
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileLoadMyProfileRequested>(_onLoadMyProfileRequested);
    on<ProfileRefreshRequested>(_onRefreshRequested);
    on<ProfileBioUpdated>(_onBioUpdated);
    on<ProfileHeadlineUpdated>(_onHeadlineUpdated);
    on<ProfileLocationUpdated>(_onLocationUpdated);
    on<ProfileWebsiteUpdated>(_onWebsiteUpdated);
    on<ProfileSkillsUpdated>(_onSkillsUpdated);
    on<ProfilePersonalDetailsUpdated>(_onPersonalDetailsUpdated);
    on<ProfileSkillAdded>(_onSkillAdded);
    on<ProfileSkillDeleted>(_onSkillDeleted);
    on<ProfileExperienceAdded>(_onExperienceAdded);
    on<ProfileExperienceUpdated>(_onExperienceUpdated);
    on<ProfileExperienceDeleted>(_onExperienceDeleted);
    on<ProfileEducationAdded>(_onEducationAdded);
    on<ProfileEducationUpdated>(_onEducationUpdated);
    on<ProfileEducationDeleted>(_onEducationDeleted);
    on<ProfileCertificationAdded>(_onCertificationAdded);
    on<ProfileCertificationUpdated>(_onCertificationUpdated);
    on<ProfileCertificationDeleted>(_onCertificationDeleted);
    on<ProfileProjectAdded>(_onProjectAdded);
    on<ProfileProjectUpdated>(_onProjectUpdated);
    on<ProfileProjectDeleted>(_onProjectDeleted);
    on<ProfileAwardAdded>(_onAwardAdded);
    on<ProfileAwardUpdated>(_onAwardUpdated);
    on<ProfileAwardDeleted>(_onAwardDeleted);
    on<ProfileLanguageAdded>(_onLanguageAdded);
    on<ProfileLanguageUpdated>(_onLanguageUpdated);
    on<ProfileLanguageDeleted>(_onLanguageDeleted);
    on<ProfileOnboardingUpdated>(_onOnboardingUpdated);
  }

  /// Load profile by user ID
  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await profileRepository.getProfile(event.userId);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
      )),
    );
  }

  /// Load current user's profile
  Future<void> _onLoadMyProfileRequested(
    ProfileLoadMyProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await profileRepository.getMyProfile();

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
      )),
    );
  }

  /// Refresh current profile
  Future<void> _onRefreshRequested(
    ProfileRefreshRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // Keep existing profile while refreshing
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await profileRepository.getMyProfile();

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
      )),
    );
  }

  /// Update bio
  Future<void> _onBioUpdated(
    ProfileBioUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(bio: event.bio);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Bio updated successfully',
      )),
    );
  }

  /// Update headline
  Future<void> _onHeadlineUpdated(
    ProfileHeadlineUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(headline: event.headline);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Headline updated successfully',
      )),
    );
  }

  /// Update location
  Future<void> _onLocationUpdated(
    ProfileLocationUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(location: event.location);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Location updated successfully',
      )),
    );
  }

  /// Update website
  Future<void> _onWebsiteUpdated(
    ProfileWebsiteUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(website: event.website);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Website updated successfully',
      )),
    );
  }

  /// Update skills
  Future<void> _onSkillsUpdated(
    ProfileSkillsUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(skills: event.skills);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Skills updated successfully',
      )),
    );
  }

  /// Update personal details (name, email, bio, headline, website, visibility)
  Future<void> _onPersonalDetailsUpdated(
    ProfilePersonalDetailsUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    // Save original profile for potential rollback
    final originalProfile = state.profile!;

    emit(state.copyWith(status: ProfileStatus.updating));

    // Update the profile locally first (optimistic update)
    final updatedProfile = state.profile!.copyWith(
      bio: event.bio ?? state.profile!.bio,
      headline: event.headline ?? state.profile!.headline,
      website: event.website ?? state.profile!.website,
    );

    emit(state.copyWith(
      profile: updatedProfile,
      status: ProfileStatus.success,
      successMessage: 'Personal details updated successfully',
    ));

    // Then update on backend in the background using the correct API
    final result = await profileRepository.updateBasicProfile(
      userId: state.profile!.userId,
      bio: event.bio,
      headline: event.headline,
      website: event.website,
    );

    // If backend update fails, revert and show error
    result.fold(
      (error) {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: error,
          profile: originalProfile, // Revert to previous state
        ));
      },
      (_) {
        // Success - already updated locally, nothing more to do
      },
    );
  }

  /// Add a skill
  Future<void> _onSkillAdded(
    ProfileSkillAdded event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedSkills = List<String>.from(state.profile!.skills)..add(event.skill);

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(skills: updatedSkills);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Skill "${event.skill}" added successfully',
      )),
    );
  }

  /// Delete a skill
  Future<void> _onSkillDeleted(
    ProfileSkillDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedSkills = List<String>.from(state.profile!.skills)..remove(event.skill);

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(skills: updatedSkills);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Skill "${event.skill}" deleted',
      )),
    );
  }

  /// Add experience
  Future<void> _onExperienceAdded(
    ProfileExperienceAdded event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final newExperience = Experience(
      title: event.title,
      company: event.company,
      companyId: event.companyId,
      location: event.location,
      startDate: event.startDate,
      endDate: event.endDate,
      current: event.current,
      description: event.description,
    );

    final updatedExperience = List<Experience>.from(state.profile!.experience)..add(newExperience);

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(experience: updatedExperience);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Experience "${event.title}" added successfully',
      )),
    );
  }

  /// Update experience
  Future<void> _onExperienceUpdated(
    ProfileExperienceUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedExperience = Experience(
      title: event.title,
      company: event.company,
      companyId: event.companyId,
      location: event.location,
      startDate: event.startDate,
      endDate: event.endDate,
      current: event.current,
      description: event.description,
    );

    final updatedList = List<Experience>.from(state.profile!.experience);
    updatedList[event.index] = updatedExperience;

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(experience: updatedList);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Experience "${event.title}" updated successfully',
      )),
    );
  }

  /// Delete experience
  Future<void> _onExperienceDeleted(
    ProfileExperienceDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedExperience = List<Experience>.from(state.profile!.experience)..removeAt(event.index);

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(experience: updatedExperience);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Experience deleted',
      )),
    );
  }

  /// Add education
  Future<void> _onEducationAdded(
    ProfileEducationAdded event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final newEducation = Education(
      degree: event.degree,
      institution: event.institution,
      startDate: event.startDate,
      endDate: event.endDate,
      grade: event.grade,
      achievements: event.achievements,
    );

    final updatedEducation = List<Education>.from(state.profile!.education)..add(newEducation);

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(education: updatedEducation);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Education "${event.degree}" added successfully',
      )),
    );
  }

  /// Update education
  Future<void> _onEducationUpdated(
    ProfileEducationUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedEducation = Education(
      degree: event.degree,
      institution: event.institution,
      startDate: event.startDate,
      endDate: event.endDate,
      grade: event.grade,
      achievements: event.achievements,
    );

    final updatedList = List<Education>.from(state.profile!.education);
    updatedList[event.index] = updatedEducation;

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(education: updatedList);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Education "${event.degree}" updated successfully',
      )),
    );
  }

  /// Delete education
  Future<void> _onEducationDeleted(
    ProfileEducationDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedEducation = List<Education>.from(state.profile!.education)..removeAt(event.index);

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(education: updatedEducation);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Education deleted',
      )),
    );
  }

  /// Add certification
  Future<void> _onCertificationAdded(
    ProfileCertificationAdded event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final newCertification = Certification(
      name: event.name,
      issuer: event.issuer,
      issueDate: event.issueDate,
      expiryDate: event.expiryDate,
      credentialUrl: event.credentialUrl,
    );

    final updatedCertifications = List<Certification>.from(state.profile!.certifications)..add(newCertification);

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(certifications: updatedCertifications);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Certification "${event.name}" added successfully',
      )),
    );
  }

  /// Update certification
  Future<void> _onCertificationUpdated(
    ProfileCertificationUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedCertification = Certification(
      name: event.name,
      issuer: event.issuer,
      issueDate: event.issueDate,
      expiryDate: event.expiryDate,
      credentialUrl: event.credentialUrl,
    );

    final updatedList = List<Certification>.from(state.profile!.certifications);
    updatedList[event.index] = updatedCertification;

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(certifications: updatedList);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Certification "${event.name}" updated successfully',
      )),
    );
  }

  /// Delete certification
  Future<void> _onCertificationDeleted(
    ProfileCertificationDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedCertifications = List<Certification>.from(state.profile!.certifications)..removeAt(event.index);

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(certifications: updatedCertifications);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Certification deleted',
      )),
    );
  }

  /// Add project
  Future<void> _onProjectAdded(
    ProfileProjectAdded event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final newProject = Project(
      name: event.name,
      description: event.description,
      startDate: event.startDate,
      endDate: event.endDate,
      current: event.current,
      url: event.url,
      technologies: event.technologies,
    );

    final updatedProjects = List<Project>.from(state.profile!.projects)..add(newProject);

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(projects: updatedProjects);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Project "${event.name}" added successfully',
      )),
    );
  }

  /// Update project
  Future<void> _onProjectUpdated(
    ProfileProjectUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedProject = Project(
      name: event.name,
      description: event.description,
      startDate: event.startDate,
      endDate: event.endDate,
      current: event.current,
      url: event.url,
      technologies: event.technologies,
    );

    final updatedList = List<Project>.from(state.profile!.projects);
    updatedList[event.index] = updatedProject;

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(projects: updatedList);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Project "${event.name}" updated successfully',
      )),
    );
  }

  /// Delete project
  Future<void> _onProjectDeleted(
    ProfileProjectDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedProjects = List<Project>.from(state.profile!.projects)..removeAt(event.index);

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(projects: updatedProjects);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Project deleted',
      )),
    );
  }

  /// Add award
  Future<void> _onAwardAdded(
    ProfileAwardAdded event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final newAward = Award(
      title: event.title,
      issuer: event.issuer,
      date: event.date,
      description: event.description,
    );

    final updatedAwards = List<Award>.from(state.profile!.awards)..add(newAward);

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(awards: updatedAwards);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Award "${event.title}" added successfully',
      )),
    );
  }

  /// Update award
  Future<void> _onAwardUpdated(
    ProfileAwardUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedAward = Award(
      title: event.title,
      issuer: event.issuer,
      date: event.date,
      description: event.description,
    );

    final updatedList = List<Award>.from(state.profile!.awards);
    updatedList[event.index] = updatedAward;

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(awards: updatedList);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Award "${event.title}" updated successfully',
      )),
    );
  }

  /// Delete award
  Future<void> _onAwardDeleted(
    ProfileAwardDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedAwards = List<Award>.from(state.profile!.awards)..removeAt(event.index);

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(awards: updatedAwards);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Award deleted',
      )),
    );
  }

  /// Add language
  Future<void> _onLanguageAdded(
    ProfileLanguageAdded event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final newLanguage = Language(
      name: event.name,
      proficiencyLevel: event.proficiencyLevel,
    );

    final updatedLanguages = [...state.profile!.languages, newLanguage];

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(languages: updatedLanguages);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Language "${event.name}" added successfully',
      )),
    );
  }

  /// Update language
  Future<void> _onLanguageUpdated(
    ProfileLanguageUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedLanguage = Language(
      name: event.name,
      proficiencyLevel: event.proficiencyLevel,
    );

    final updatedList = List<Language>.from(state.profile!.languages);
    updatedList[event.index] = updatedLanguage;

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(languages: updatedList);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Language "${event.name}" updated successfully',
      )),
    );
  }

  /// Delete language
  Future<void> _onLanguageDeleted(
    ProfileLanguageDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    final updatedLanguages = List<Language>.from(state.profile!.languages)..removeAt(event.index);

    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateProfile(languages: updatedLanguages);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.success,
        profile: profile,
        successMessage: 'Language deleted',
      )),
    );
  }

  /// Update onboarding profile (all student fields collected during setup)
  Future<void> _onOnboardingUpdated(
    ProfileOnboardingUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating));

    final result = await profileRepository.updateOnboardingProfile(
      board: event.board,
      classGrade: event.classGrade,
      schoolName: event.schoolName,
      stream: event.stream,
      gender: event.gender,
      location: event.location,
      careerGoalStatus: event.careerGoalStatus,
      careerGoalText: event.careerGoalText,
      generalInterests: event.generalInterests,
      skills: event.skills,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (_) => emit(state.copyWith(
        status: ProfileStatus.success,
        successMessage: 'Profile setup completed successfully',
      )),
    );
  }
}

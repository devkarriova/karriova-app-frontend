import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
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
}

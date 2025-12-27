import 'package:equatable/equatable.dart';
import '../../domain/models/profile_model.dart';

/// Status enum for profile states
enum ProfileStatus {
  initial,
  loading,
  success,
  error,
  updating,
  updateSuccess,
}

/// Profile state class
class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileModel? profile;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.successMessage,
  });

  /// Convenience getters
  bool get isLoading => status == ProfileStatus.loading;
  bool get isUpdating => status == ProfileStatus.updating;
  bool get hasProfile => profile != null;
  bool get hasError => status == ProfileStatus.error;

  /// Copy with method for state updates
  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? profile,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  /// Clear messages
  ProfileState clearMessages() {
    return ProfileState(
      status: status,
      profile: profile,
      errorMessage: null,
      successMessage: null,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage, successMessage];
}

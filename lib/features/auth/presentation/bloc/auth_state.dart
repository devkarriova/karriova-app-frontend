import 'package:equatable/equatable.dart';
import '../../domain/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final String? successMessage;
  final bool? assessmentCompleted; // null = not yet checked, true/false = status

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.assessmentCompleted,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    String? successMessage,
    bool? assessmentCompleted,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      successMessage: successMessage,
      assessmentCompleted: assessmentCompleted ?? this.assessmentCompleted,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, successMessage, assessmentCompleted];
}

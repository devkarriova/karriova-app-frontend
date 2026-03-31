import 'package:equatable/equatable.dart';
import '../../domain/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  googleOAuthRequired, // User needs to be redirected to Google OAuth
  otpSent, // OTP has been sent successfully
  otpVerified, // OTP verified successfully
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final String? successMessage;
  final bool? assessmentCompleted; // null = not yet checked, true/false = status
  final String? googleOAuthUrl; // OAuth URL when status is googleOAuthRequired
  final String? googleOAuthState; // OAuth state for CSRF protection
  final String? otpPhone; // Phone number for OTP verification
  final DateTime? otpExpiresAt; // When the OTP expires

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.assessmentCompleted,
    this.googleOAuthUrl,
    this.googleOAuthState,
    this.otpPhone,
    this.otpExpiresAt,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    String? successMessage,
    bool? assessmentCompleted,
    bool updateAssessmentCompleted = false,
    String? googleOAuthUrl,
    String? googleOAuthState,
    String? otpPhone,
    DateTime? otpExpiresAt,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      successMessage: successMessage,
      assessmentCompleted: updateAssessmentCompleted
          ? assessmentCompleted
          : (assessmentCompleted ?? this.assessmentCompleted),
      googleOAuthUrl: googleOAuthUrl,
      googleOAuthState: googleOAuthState,
      otpPhone: otpPhone ?? this.otpPhone,
      otpExpiresAt: otpExpiresAt ?? this.otpExpiresAt,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, successMessage, assessmentCompleted, googleOAuthUrl, googleOAuthState, otpPhone, otpExpiresAt];
}

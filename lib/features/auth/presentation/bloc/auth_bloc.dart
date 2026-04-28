import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../assessment/data/repositories/assessment_repository_impl.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
    on<AuthGoogleLoginCallback>(_onGoogleLoginCallback);
    on<AuthCheckStatusRequested>(_onCheckStatusRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthTokenExpired>(_onTokenExpired);
    on<AuthCheckAssessmentStatus>(_onCheckAssessmentStatus);
    on<AuthSetAssessmentCompleted>(_onSetAssessmentCompleted);
    on<AuthSendOTPRequested>(_onSendOTPRequested);
    on<AuthVerifyOTPRequested>(_onVerifyOTPRequested);
  }

  Future<bool?> _loadAssessmentCompletionStatus() async {
    try {
      final assessmentRepo = getIt<AssessmentRepository>();
      final result = await assessmentRepo.getAssessmentStatus();
      return result.fold((_) => null, (completed) => completed);
    } catch (_) {
      return null;
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepository.login(
      email: event.email,
      password: event.password,
    );

    String? errorMessage;
    dynamic user;
    result.fold(
      (error) => errorMessage = error,
      (u) => user = u,
    );

    if (errorMessage != null) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: errorMessage,
      ));
      return;
    }

    final assessmentCompleted = await _loadAssessmentCompletionStatus();
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      successMessage: 'Login successful!',
      assessmentCompleted: assessmentCompleted,
      updateAssessmentCompleted: true,
    ));
  }

  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepository.signup(
      email: event.email,
      password: event.password,
      name: event.name,
      dateOfBirth: event.dateOfBirth,
      phone: event.phone,
      parentPhone: event.parentPhone,
      otpCode: event.otpCode,
      userType: event.userType,
    );

    String? errorMessage;
    dynamic user;
    result.fold(
      (error) => errorMessage = error,
      (u) => user = u,
    );

    if (errorMessage != null) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: errorMessage,
      ));
      return;
    }

    final assessmentCompleted = await _loadAssessmentCompletionStatus();
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      successMessage: 'Signup successful!',
      assessmentCompleted: assessmentCompleted ?? false,
      updateAssessmentCompleted: true,
    ));
  }

  Future<void> _onSendOTPRequested(
    AuthSendOTPRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepository.sendOTP(
      phone: event.phone,
      purpose: event.purpose,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: error,
      )),
      (expiresAt) => emit(state.copyWith(
        status: AuthStatus.otpSent,
        otpPhone: event.phone,
        otpExpiresAt: expiresAt,
        successMessage: 'OTP sent successfully!',
      )),
    );
  }

  Future<void> _onVerifyOTPRequested(
    AuthVerifyOTPRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepository.verifyOTP(
      phone: event.phone,
      otpCode: event.otpCode,
      purpose: event.purpose,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: error,
      )),
      (verified) {
        if (verified) {
          emit(state.copyWith(
            status: AuthStatus.otpVerified,
            successMessage: 'Phone verified successfully!',
          ));
        } else {
          emit(state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Invalid OTP code',
          ));
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepository.logout();

    result.fold(
      (error) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: error,
      )),
      (_) => emit(const AuthState(status: AuthStatus.unauthenticated)),
    );
  }

  Future<void> _onGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepository.initiateGoogleLogin();

    result.fold(
      (error) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: error,
      )),
      (oauthResult) => emit(state.copyWith(
        status: AuthStatus.googleOAuthRequired,
        googleOAuthUrl: oauthResult.url,
        googleOAuthState: oauthResult.state,
      )),
    );
  }

  Future<void> _onGoogleLoginCallback(
    AuthGoogleLoginCallback event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepository.completeGoogleLogin(
      code: event.code,
      state: event.state,
    );

    String? errorMessage;
    dynamic user;
    result.fold(
      (error) => errorMessage = error,
      (u) => user = u,
    );

    if (errorMessage != null) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: errorMessage,
      ));
      return;
    }

    final assessmentCompleted = await _loadAssessmentCompletionStatus();
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      successMessage: 'Login successful!',
      assessmentCompleted: assessmentCompleted,
      updateAssessmentCompleted: true,
    ));
  }

  Future<void> _onCheckStatusRequested(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final isLoggedIn = await authRepository.isLoggedIn();

    if (isLoggedIn) {
      final result = await authRepository.getCurrentUser();
      String? errorMessage;
      dynamic user;
      result.fold(
        (error) => errorMessage = error,
        (u) => user = u,
      );

      if (errorMessage != null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }

      final assessmentCompleted = await _loadAssessmentCompletionStatus();
      emit(AuthState(
        status: AuthStatus.authenticated,
        user: user,
        assessmentCompleted: assessmentCompleted,
      ));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepository.resetPassword(email: event.email);

    result.fold(
      (error) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: error,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        successMessage: 'Password reset email sent!',
      )),
    );
  }

  Future<void> _onTokenExpired(
    AuthTokenExpired event,
    Emitter<AuthState> emit,
  ) async {
    // Clear tokens and logout user silently
    await authRepository.logout();
    emit(const AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: 'Session expired. Please login again.',
    ));
  }

  Future<void> _onCheckAssessmentStatus(
    AuthCheckAssessmentStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final assessmentRepo = getIt<AssessmentRepository>();
      final result = await assessmentRepo.getAssessmentStatus();

      result.fold(
        (error) {},
        (completed) {
          emit(state.copyWith(
            assessmentCompleted: completed,
            updateAssessmentCompleted: true,
          ));
        },
      );
    } catch (e) {
      // Keep existing value on transient failures to avoid false negatives.
    }
  }

  Future<void> _onSetAssessmentCompleted(
    AuthSetAssessmentCompleted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      assessmentCompleted: true,
      updateAssessmentCompleted: true,
    ));
  }
}

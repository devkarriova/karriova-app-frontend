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

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepository.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: error,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        successMessage: 'Login successful!',
        assessmentCompleted: null, // Reset - will be checked next
      )),
    );
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
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: error,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        successMessage: 'Signup successful!',
        assessmentCompleted: false, // New users haven't taken assessment
      )),
    );
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

    result.fold(
      (error) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: error,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        successMessage: 'Login successful!',
        assessmentCompleted: null, // Reset - will be checked next
      )),
    );
  }

  Future<void> _onCheckStatusRequested(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final isLoggedIn = await authRepository.isLoggedIn();

    if (isLoggedIn) {
      final result = await authRepository.getCurrentUser();
      result.fold(
        (error) => emit(const AuthState(status: AuthStatus.unauthenticated)),
        (user) => emit(AuthState(
          status: AuthStatus.authenticated,
          user: user,
        )),
      );
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
        (error) {
          // If error, assume not completed (will prompt assessment)
          emit(state.copyWith(
            assessmentCompleted: false,
            updateAssessmentCompleted: true,
          ));
        },
        (completed) {
          emit(state.copyWith(
            assessmentCompleted: completed,
            updateAssessmentCompleted: true,
          ));
        },
      );
    } catch (e) {
      // On error, assume not completed
      emit(state.copyWith(
        assessmentCompleted: false,
        updateAssessmentCompleted: true,
      ));
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

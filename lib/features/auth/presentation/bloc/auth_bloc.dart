import 'package:flutter_bloc/flutter_bloc.dart';
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
    on<AuthCheckStatusRequested>(_onCheckStatusRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthTokenExpired>(_onTokenExpired);
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
      )),
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

    final result = await authRepository.loginWithGoogle();

    result.fold(
      (error) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: error,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        successMessage: 'Login successful!',
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
}

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String? dateOfBirth; // Format: YYYY-MM-DD
  final String? phone;
  final String? parentPhone;
  final String? otpCode;

  const AuthSignupRequested({
    required this.email,
    required this.password,
    required this.name,
    this.dateOfBirth,
    this.phone,
    this.parentPhone,
    this.otpCode,
  });

  @override
  List<Object?> get props => [email, password, name, dateOfBirth, phone, parentPhone, otpCode];
}

/// Event to send OTP to a phone number
class AuthSendOTPRequested extends AuthEvent {
  final String phone;
  final String purpose; // 'signup', 'login', 'password_reset'

  const AuthSendOTPRequested({
    required this.phone,
    required this.purpose,
  });

  @override
  List<Object?> get props => [phone, purpose];
}

/// Event to verify OTP code
class AuthVerifyOTPRequested extends AuthEvent {
  final String phone;
  final String otpCode;
  final String purpose;

  const AuthVerifyOTPRequested({
    required this.phone,
    required this.otpCode,
    required this.purpose,
  });

  @override
  List<Object?> get props => [phone, otpCode, purpose];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();
}

/// Event to complete Google OAuth login after redirect
class AuthGoogleLoginCallback extends AuthEvent {
  final String code;
  final String state;

  const AuthGoogleLoginCallback({
    required this.code,
    required this.state,
  });

  @override
  List<Object?> get props => [code, state];
}

class AuthCheckStatusRequested extends AuthEvent {
  const AuthCheckStatusRequested();
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthTokenExpired extends AuthEvent {
  const AuthTokenExpired();
}

class AuthCheckAssessmentStatus extends AuthEvent {
  const AuthCheckAssessmentStatus();
}

class AuthSetAssessmentCompleted extends AuthEvent {
  const AuthSetAssessmentCompleted();
}

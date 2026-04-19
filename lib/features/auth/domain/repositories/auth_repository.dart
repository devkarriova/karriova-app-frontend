import 'package:dartz/dartz.dart';
import '../models/user_model.dart';

/// Result of initiating Google OAuth login
class GoogleOAuthResult {
  final String url;
  final String? state;

  GoogleOAuthResult({required this.url, this.state});
}

abstract class AuthRepository {
  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  });

  Future<Either<String, UserModel>> signup({
    required String email,
    required String password,
    required String name,
    String? dateOfBirth,
    String? phone,
    String? parentPhone,
    String? otpCode,
    String userType = 'user',
  });

  /// Send OTP to a phone number
  Future<Either<String, DateTime>> sendOTP({
    required String phone,
    required String purpose,
  });

  /// Verify OTP code
  Future<Either<String, bool>> verifyOTP({
    required String phone,
    required String otpCode,
    required String purpose,
  });

  Future<Either<String, void>> logout();

  Future<Either<String, UserModel>> getCurrentUser();

  Future<Either<String, void>> resetPassword({required String email});

  /// Initiates Google OAuth login flow
  /// Returns either an error message or a GoogleOAuthResult with the OAuth URL
  Future<Either<String, GoogleOAuthResult>> initiateGoogleLogin();

  /// Completes Google OAuth login by exchanging the authorization code
  Future<Either<String, UserModel>> completeGoogleLogin({
    required String code,
    required String state,
  });

  Future<bool> isLoggedIn();
}

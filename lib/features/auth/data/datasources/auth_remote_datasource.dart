import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login({
    required String email,
    required String password,
  });

  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String name,
  });

  Future<void> logout(String refreshToken);

  Future<AuthResponse> refreshToken(String refreshToken);

  Future<UserModel> loginWithGoogle();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword(String token, String newPassword);
}

/// Response model for authentication endpoints
class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;

  AuthResponse({
    required this.user,
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresIn: json['expires_in'] as int,
    );
  }
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      AppConfig.loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Login failed');
    }

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await apiClient.post(
      AppConfig.signupEndpoint,
      body: {
        'email': email,
        'password': password,
        'name': name,
      },
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Signup failed');
    }

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await apiClient.post(
      AppConfig.logoutEndpoint,
      body: {
        'refresh_token': refreshToken,
      },
    );
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await apiClient.post(
      AppConfig.refreshTokenEndpoint,
      body: {
        'refresh_token': refreshToken,
      },
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Token refresh failed');
    }

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    // Step 1: Get OAuth URL from backend
    final urlResponse = await apiClient.get(
      '/auth/google',
      requiresAuth: false,
    );

    if (!urlResponse.isSuccess || urlResponse.data == null) {
      throw Exception(urlResponse.errorMessage ?? 'Failed to get Google OAuth URL');
    }

    // For web/mobile, this URL should be opened in a browser/WebView
    // The callback will be handled by deep linking or redirect
    // For now, throw with the URL for the UI to handle
    throw UnimplementedError(
      'Google Sign-In requires platform-specific implementation. OAuth URL: ${urlResponse.data['url']}',
    );
  }

  /// Request password reset email
  @override
  Future<void> forgotPassword(String email) async {
    final response = await apiClient.post(
      '/auth/forgot-password',
      body: {'email': email},
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to request password reset');
    }
  }

  /// Reset password with token
  @override
  Future<void> resetPassword(String token, String newPassword) async {
    final response = await apiClient.post(
      '/auth/reset-password',
      body: {
        'token': token,
        'new_password': newPassword,
      },
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to reset password');
    }
  }
}

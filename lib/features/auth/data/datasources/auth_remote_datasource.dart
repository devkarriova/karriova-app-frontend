import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/models/user_model.dart';

/// Exception thrown when Google OAuth requires a redirect to the OAuth URL
class GoogleOAuthRedirectRequired implements Exception {
  final String url;
  final String? state;

  GoogleOAuthRedirectRequired({required this.url, this.state});

  @override
  String toString() => 'GoogleOAuthRedirectRequired: $url';
}

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

    final oauthUrl = urlResponse.data['url'] as String?;
    final state = urlResponse.data['state'] as String?;

    if (oauthUrl == null || oauthUrl.isEmpty) {
      throw Exception('Google OAuth is not configured. Please contact support.');
    }

    // Check if client_id is missing (empty in URL)
    if (oauthUrl.contains('client_id=&') || oauthUrl.contains('client_id=http')) {
      throw Exception(
        'Google Sign-In is not configured on the server. '
        'Please set up Google OAuth credentials in the backend configuration.',
      );
    }

    // Return a special exception that contains the OAuth URL for the UI to handle
    throw GoogleOAuthRedirectRequired(url: oauthUrl, state: state);
  }

  /// Exchange Google OAuth authorization code for user authentication
  Future<AuthResponse> exchangeGoogleCode(String code, String state) async {
    final response = await apiClient.get(
      '${AppConfig.googleCallbackEndpoint}?code=$code&state=$state',
      requiresAuth: false,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Google authentication failed');
    }

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
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

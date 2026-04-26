import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String appName = 'Karriova';
  static const String _prodApiBaseUrl = 'https://karriova-backend-services-production.up.railway.app/api/v1';
  static const String _localApiBaseUrl = 'http://localhost:8080/api/v1';
  static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static bool get _isLocal {
    if (kIsWeb) {
      final host = Uri.base.host;
      return host == 'localhost' || host == '127.0.0.1';
    }
    return true; // native builds always hit local
  }

  // Base URL - auto-detects local vs prod
  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return '$_apiBaseUrlOverride/api/v1';
    if (kIsWeb) {
      return _isLocal ? _localApiBaseUrl : _prodApiBaseUrl;
    } else if (Platform.isAndroid) {
      // Emulator: 10.0.2.2 = host localhost. Physical device: use ngrok or local IP.
      return 'http://10.0.2.2:8080/api/v1';
    } else {
      return _localApiBaseUrl;
    }
  }

  // Auth Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String googleOAuthEndpoint = '/auth/google';
  static const String googleCallbackEndpoint = '/auth/google/callback';

  // User Endpoints
  static const String userProfileEndpoint = '/users/me';
  static const String updateProfileEndpoint = '/users/me';
  static const String deleteAccountEndpoint = '/users/me';

  // Post Endpoints
  static const String feedEndpoint = '/posts/feed';
  static const String createPostEndpoint = '/posts';
  static const String likePostEndpoint = '/posts/{postId}/like';
  static const String commentPostEndpoint = '/posts/{postId}/comments';

  // Profile Endpoints
  static const String profileEndpoint = '/profiles/{userId}';
  static const String myProfileEndpoint = '/profiles/me';
  static const String createProfileEndpoint = '/profiles';
  static const String updateProfileUserEndpoint = '/profiles/me/basic';
  static const String updateOnboardingProfileEndpoint = '/profiles/me/onboarding';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 120);
  static const Duration receiveTimeout = Duration(seconds: 120);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
}

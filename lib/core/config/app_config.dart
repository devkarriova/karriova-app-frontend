import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String appName = 'Karriova';

  // Base URL - Automatically detects platform
  static String get apiBaseUrl {
    if (kIsWeb) {
      // Web: use localhost
      return 'http://localhost:8080/api/v1';
    } else if (Platform.isAndroid) {
      // Android Emulator: use special IP that maps to host machine
      // For physical device, replace with your machine's local IP (e.g., '192.168.1.100')
      return 'http://10.0.2.2:8080/api/v1';
    } else {
      // iOS Simulator, Desktop (Windows/Linux/macOS): use localhost
      return 'http://localhost:8080/api/v1';
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
  static const String updateProfileUserEndpoint = '/profiles/me';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
}

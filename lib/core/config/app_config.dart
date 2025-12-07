class AppConfig {
  static const String appName = 'Karriova';

  // Base URL - Update for production deployment
  static const String apiBaseUrl = 'http://localhost:8080/api/v1';

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

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
}

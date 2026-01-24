import 'package:dartz/dartz.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/network/api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ApiClient apiClient;

  Function()? _onTokenExpiredCallback;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.apiClient,
  }) {
    _setupTokenRefresh();
  }

  /// Set callback to be called when token expires and cannot be refreshed
  void setTokenExpiredCallback(Function() callback) {
    _onTokenExpiredCallback = callback;
    _setupLogoutCallback();
  }

  /// Setup automatic token refresh
  void _setupTokenRefresh() {
    apiClient.setTokenRefreshCallback(_handleTokenRefresh);
  }

  /// Setup automatic logout on token expiration
  void _setupLogoutCallback() {
    apiClient.setLogoutCallback(_handleLogoutRequired);
  }

  /// Handle logout when token refresh fails
  Future<void> _handleLogoutRequired() async {
    try {
      // Clear local data
      await localDataSource.clearUser();
      await localDataSource.clearTokens();

      // Notify the app about token expiration
      if (_onTokenExpiredCallback != null) {
        _onTokenExpiredCallback!();
      }
    } catch (e) {
      AppLogger.error('Logout on token expiration failed: $e');
    }
  }

  /// Handle token refresh when access token expires
  Future<bool> _handleTokenRefresh() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final authResponse = await remoteDataSource.refreshToken(refreshToken);

      // Save new tokens
      await localDataSource.saveAccessToken(authResponse.accessToken);
      if (authResponse.refreshToken != null) {
        await localDataSource.saveRefreshToken(authResponse.refreshToken!);
      }

      // Update ApiClient with new access token
      apiClient.setAccessToken(authResponse.accessToken);

      return true;
    } catch (e) {
      AppLogger.error('Token refresh failed: $e');
      return false;
    }
  }

  @override
  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await remoteDataSource.login(email: email, password: password);

      // Save user and tokens
      await localDataSource.saveUser(authResponse.user);
      await localDataSource.saveAccessToken(authResponse.accessToken);
      if (authResponse.refreshToken != null) {
        await localDataSource.saveRefreshToken(authResponse.refreshToken!);
      }

      // Set access token in API client
      apiClient.setAccessToken(authResponse.accessToken);

      return Right(authResponse.user);
    } catch (e) {
      AppLogger.error('Login failed: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, UserModel>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final authResponse = await remoteDataSource.signup(
        email: email,
        password: password,
        name: name,
      );

      // Save user and tokens
      await localDataSource.saveUser(authResponse.user);
      await localDataSource.saveAccessToken(authResponse.accessToken);
      if (authResponse.refreshToken != null) {
        await localDataSource.saveRefreshToken(authResponse.refreshToken!);
      }

      // Set access token in API client
      apiClient.setAccessToken(authResponse.accessToken);

      return Right(authResponse.user);
    } catch (e) {
      AppLogger.error('Signup failed: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> logout() async {
    try {
      // Get refresh token for logout
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken != null) {
        await remoteDataSource.logout(refreshToken);
      }

      // Clear local data
      await localDataSource.clearUser();
      await localDataSource.clearTokens();

      // Clear access token from API client
      apiClient.setAccessToken(null);

      return const Right(null);
    } catch (e) {
      AppLogger.error('Logout failed: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, UserModel>> getCurrentUser() async {
    try {
      final user = await localDataSource.getUser();
      if (user != null) {
        // Load and set access token when getting current user
        final accessToken = await localDataSource.getAccessToken();
        if (accessToken != null) {
          apiClient.setAccessToken(accessToken);
        }
        return Right(user);
      }
      return const Left('No user found');
    } catch (e) {
      AppLogger.error('Get current user failed: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> resetPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } catch (e) {
      AppLogger.error('Reset password failed: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, UserModel>> loginWithGoogle() async {
    try {
      final user = await remoteDataSource.loginWithGoogle();
      await localDataSource.saveUser(user);
      return Right(user);
    } catch (e) {
      AppLogger.error('Google login failed: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await localDataSource.getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      AppLogger.error('Check login status failed: $e');
      return false;
    }
  }

  String _handleError(dynamic error) {
    if (error is String) {
      return error;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

import 'package:dartz/dartz.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/utils/logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(email: email, password: password);
      await localDataSource.saveUser(user);
      if (user.token != null) {
        await localDataSource.saveToken(user.token!);
      }
      return Right(user);
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
      final user = await remoteDataSource.signup(
        email: email,
        password: password,
        name: name,
      );
      await localDataSource.saveUser(user);
      if (user.token != null) {
        await localDataSource.saveToken(user.token!);
      }
      return Right(user);
    } catch (e) {
      AppLogger.error('Signup failed: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<String, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearUser();
      await localDataSource.clearToken();
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
      await remoteDataSource.resetPassword(email: email);
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
      if (user.token != null) {
        await localDataSource.saveToken(user.token!);
      }
      return Right(user);
    } catch (e) {
      AppLogger.error('Google login failed: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await localDataSource.getToken();
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

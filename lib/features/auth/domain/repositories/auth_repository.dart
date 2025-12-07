import 'package:dartz/dartz.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  });

  Future<Either<String, UserModel>> signup({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<String, void>> logout();

  Future<Either<String, UserModel>> getCurrentUser();

  Future<Either<String, void>> resetPassword({required String email});

  Future<Either<String, UserModel>> loginWithGoogle();

  Future<bool> isLoggedIn();
}

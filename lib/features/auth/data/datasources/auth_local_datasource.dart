import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  static const String _userKey = 'cached_user';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  @override
  Future<void> saveUser(UserModel user) async {
    final userJson = json.encode(user.toJson());
    await sharedPreferences.setString(_userKey, userJson);
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = sharedPreferences.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(_userKey);
  }

  @override
  Future<void> saveAccessToken(String token) async {
    await secureStorage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
  }
}

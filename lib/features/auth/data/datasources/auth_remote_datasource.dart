import '../../domain/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
  });

  Future<void> logout();

  Future<void> resetPassword({required String email});

  Future<UserModel> loginWithGoogle();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // TODO: Inject API service via dependency injection
  // final ApiService apiService;

  AuthRemoteDataSourceImpl();

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // TODO: Implement actual API call
    // Example:
    // final response = await apiService.login(email, password);
    // return UserModel.fromJson(response.data);

    // Mock implementation for now
    await Future.delayed(const Duration(seconds: 2));
    return UserModel(
      id: '123',
      email: email,
      name: 'Mock User',
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    // TODO: Implement actual API call
    // Example:
    // final response = await apiService.signup(email, password, name);
    // return UserModel.fromJson(response.data);

    // Mock implementation for now
    await Future.delayed(const Duration(seconds: 2));
    return UserModel(
      id: '123',
      email: email,
      name: name,
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<void> logout() async {
    // TODO: Implement actual API call
    // Example:
    // await apiService.logout();

    // Mock implementation for now
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> resetPassword({required String email}) async {
    // TODO: Implement actual API call
    // Example:
    // await apiService.resetPassword(email);

    // Mock implementation for now
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    // TODO: Implement Google Sign-In
    // Example:
    // final googleUser = await GoogleSignIn().signIn();
    // final response = await apiService.loginWithGoogle(googleUser.idToken);
    // return UserModel.fromJson(response.data);

    // Mock implementation for now
    await Future.delayed(const Duration(seconds: 2));
    return UserModel(
      id: '456',
      email: 'google.user@example.com',
      name: 'Google User',
      token: 'mock_google_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

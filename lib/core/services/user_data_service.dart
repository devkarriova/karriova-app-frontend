import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import '../utils/web_file_utils_stub.dart'
    if (dart.library.html) '../utils/web_file_utils_web.dart';

/// Service for handling user data operations (GDPR compliance)
class UserDataService {
  final ApiClient _apiClient;

  UserDataService(this._apiClient);

  /// Download user data export from the server
  Future<Map<String, dynamic>> downloadUserData() async {
    final response = await _apiClient.get(
      '/users/me/export',
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to download user data');
    }

    return response.data as Map<String, dynamic>;
  }

  /// Export user data as a JSON file and trigger download
  Future<void> exportUserDataToFile() async {
    final data = await downloadUserData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    
    if (kIsWeb) {
      downloadJsonOnWeb(jsonString, 'karriova_data_export.json');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    final response = await _apiClient.delete(
      '/users/me',
      requiresAuth: true,
    );

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to delete account');
    }
  }

  /// Get user data summary (for preview before download)
  Future<UserDataSummary> getUserDataSummary() async {
    try {
      final data = await downloadUserData();
      return UserDataSummary.fromJson(data);
    } catch (e) {
      // Return empty summary if fetch fails
      return UserDataSummary(
        postsCount: 0,
        commentsCount: 0,
        likesCount: 0,
        messagesCount: 0,
        followersCount: 0,
        followingCount: 0,
        assessmentsCount: 0,
        ticketsCount: 0,
      );
    }
  }
}

/// Summary of user data counts
class UserDataSummary {
  final int postsCount;
  final int commentsCount;
  final int likesCount;
  final int messagesCount;
  final int followersCount;
  final int followingCount;
  final int assessmentsCount;
  final int ticketsCount;

  UserDataSummary({
    required this.postsCount,
    required this.commentsCount,
    required this.likesCount,
    required this.messagesCount,
    required this.followersCount,
    required this.followingCount,
    required this.assessmentsCount,
    required this.ticketsCount,
  });

  factory UserDataSummary.fromJson(Map<String, dynamic> json) {
    return UserDataSummary(
      postsCount: (json['posts'] as List?)?.length ?? 0,
      commentsCount: (json['comments'] as List?)?.length ?? 0,
      likesCount: (json['likes'] as List?)?.length ?? 0,
      messagesCount: (json['messages'] as List?)?.length ?? 0,
      followersCount: (json['followers'] as List?)?.length ?? 0,
      followingCount: (json['following'] as List?)?.length ?? 0,
      assessmentsCount: (json['assessments'] as List?)?.length ?? 0,
      ticketsCount: (json['support_tickets'] as List?)?.length ?? 0,
    );
  }

  int get totalItems =>
      postsCount +
      commentsCount +
      likesCount +
      messagesCount +
      followersCount +
      followingCount +
      assessmentsCount +
      ticketsCount;
}

import 'package:karriova_app/core/network/api_client.dart';

class FeedbackService {
  final ApiClient _apiClient;

  FeedbackService(this._apiClient);

  Future<void> submitFeedback({
    required String subject,
    required String description,
    required String category,
  }) async {
    try {
      await _apiClient.post(
        '/feedback/tickets',
        body: {
          'subject': subject,
          'description': description,
          'category': category,
        },
        requiresAuth: true,
      );
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }
}

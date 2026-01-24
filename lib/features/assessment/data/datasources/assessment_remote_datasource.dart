import '../../../../core/network/api_client.dart';
import '../../domain/models/assessment_models.dart';

/// Assessment remote data source interface
abstract class AssessmentRemoteDataSource {
  /// Get the active assessment with all sections, dimensions, questions, and options
  Future<AssessmentModel> getActiveAssessment();

  /// Submit assessment responses
  Future<AssessmentResultModel> submitAssessment(List<ResponseInput> responses);

  /// Get current user's assessment results
  Future<AssessmentResultModel> getMyResults();

  /// Check if user has completed the assessment
  Future<bool> hasCompletedAssessment();
}

/// Implementation of assessment remote data source
class AssessmentRemoteDataSourceImpl implements AssessmentRemoteDataSource {
  final ApiClient _apiClient;

  AssessmentRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<AssessmentModel> getActiveAssessment() async {
    final response = await _apiClient.get('/assessments/active', requiresAuth: true);
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to load assessment');
    }
    return AssessmentModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AssessmentResultModel> submitAssessment(
      List<ResponseInput> responses) async {
    final response = await _apiClient.post(
      '/assessments/submit',
      requiresAuth: true,
      body: {
        'responses': responses.map((r) => r.toJson()).toList(),
      },
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to submit assessment');
    }
    return AssessmentResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AssessmentResultModel> getMyResults() async {
    final response = await _apiClient.get('/assessments/results', requiresAuth: true);
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to load results');
    }
    return AssessmentResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<bool> hasCompletedAssessment() async {
    final response = await _apiClient.get('/assessments/status', requiresAuth: true);
    if (!response.isSuccess) {
      return false;
    }
    final data = response.data as Map<String, dynamic>?;
    return data?['completed'] as bool? ?? false;
  }
}

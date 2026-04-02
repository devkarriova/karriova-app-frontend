import 'package:dio/dio.dart';
import 'package:karriova_app/features/assessment/models/career_blueprint_model.dart';

/// API Service for Career Blueprint endpoints
class BlueprintApiService {
  final Dio _dio;
  final String _baseUrl;

  BlueprintApiService({
    required Dio dio,
    required String baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  /// Get carousel view with 3 blueprint summaries
  Future<BlueprintCarouselResponse> getCarouselBlueprints(String attemptId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/v1/assessments/blueprints/carousel/$attemptId',
      );

      return BlueprintCarouselResponse.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw BlueprintException('Failed to load carousel blueprints: $e');
    }
  }

  /// Get full blueprint with all 14 sections
  Future<CareerBlueprint> getBlueprintDetail(String blueprintId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/v1/assessments/blueprints/$blueprintId',
      );

      final data = response.data['blueprint'] ?? response.data['data'] ?? response.data;
      return CareerBlueprint.fromJson(data);
    } catch (e) {
      throw BlueprintException('Failed to load blueprint details: $e');
    }
  }

  /// Lock user's career selection
  Future<void> selectBlueprint(String blueprintId, String attemptId) async {
    try {
      await _dio.post(
        '$_baseUrl/api/v1/assessments/blueprints/$blueprintId/select',
        data: {
          'attempt_id': attemptId,
        },
      );
    } catch (e) {
      throw BlueprintException('Failed to select blueprint: $e');
    }
  }

  /// Regenerate blueprints for an assessment attempt
  Future<BlueprintCarouselResponse> regenerateBlueprints(
    String attemptId,
    int roadmapHorizonMonths,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/v1/assessments/roadmaps/generate',
        data: {
          'attempt_id': attemptId,
          'roadmap_horizon_months': roadmapHorizonMonths,
        },
      );

      // Assuming regenerate endpoint returns carousel response
      return BlueprintCarouselResponse.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw BlueprintException('Failed to regenerate blueprints: $e');
    }
  }
}

/// Custom exception for blueprint API errors
class BlueprintException implements Exception {
  final String message;

  BlueprintException(this.message);

  @override
  String toString() => 'BlueprintException: $message';
}

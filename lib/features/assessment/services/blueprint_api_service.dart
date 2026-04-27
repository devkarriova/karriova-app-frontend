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

  String _buildUrl(String path) {
    final base = _baseUrl.isNotEmpty ? _baseUrl : _dio.options.baseUrl;
    final normalizedBase = base.endsWith('/api/v1') ? base : '$base/api/v1';
    return '$normalizedBase$path';
  }

  /// Get carousel view with 3 blueprint summaries
  Future<BlueprintCarouselResponse> getCarouselBlueprints(String attemptId) async {
    try {
      final response = await _dio.get(
        _buildUrl('/assessments/blueprints/carousel/$attemptId'),
      );

      return BlueprintCarouselResponse.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      // Split-submit flow fallback:
      // 1) Compute/persist career matches
      // 2) Retry blueprint carousel once
      final statusCode = e.response?.statusCode;
      final message = (e.response?.data?['error']?['message'] ?? '').toString();
      final shouldRetry = statusCode == 404 &&
          message.toLowerCase().contains('no career blueprints found');

      if (shouldRetry) {
        try {
          await _dio.get(_buildUrl('/assessments/career-matches'));
          final retryResponse = await _dio.get(
            _buildUrl('/assessments/blueprints/carousel/$attemptId'),
          );
          return BlueprintCarouselResponse.fromJson(
            retryResponse.data['data'] ?? retryResponse.data,
          );
        } catch (_) {
          // Fall through to throw a single standardized error below.
        }
      }

      throw BlueprintException('Failed to load carousel blueprints: $e');
    } catch (e) {
      throw BlueprintException('Failed to load carousel blueprints: $e');
    }
  }

  /// Get full blueprint with all 14 sections
  Future<CareerBlueprint> getBlueprintDetail(String blueprintId) async {
    try {
      final response = await _dio.get(
        _buildUrl('/assessments/blueprints/$blueprintId'),
      );

      final raw = response.data;
      final data = raw['data']?['blueprint'] ?? raw['blueprint'] ?? raw['data'] ?? raw;
      return CareerBlueprint.fromJson(data);
    } catch (e) {
      throw BlueprintException('Failed to load blueprint details: $e');
    }
  }

  /// Lock user's career selection
  Future<void> selectBlueprint(String blueprintId, String attemptId) async {
    try {
      await _dio.post(
        _buildUrl('/assessments/blueprints/$blueprintId/select'),
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
        _buildUrl('/assessments/roadmaps/generate'),
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

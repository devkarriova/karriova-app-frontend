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

  Options _longRequestOptions() {
    return Options(
      sendTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    );
  }

  /// Resolve latest completed assessment attempt and fetch its blueprint carousel.
  Future<LatestBlueprintBundle> getLatestCarouselBlueprints() async {
    try {
      final latestResp = await _dio.get(
        _buildUrl('/assessments/blueprints/carousel/latest'),
        options: _longRequestOptions(),
      );
      final latestCarousel = BlueprintCarouselResponse.fromJson(
        latestResp.data['data'] ?? latestResp.data,
      );

      final latestAttemptId = latestCarousel.assessmentAttemptId.isNotEmpty
          ? latestCarousel.assessmentAttemptId
          : 'latest';

      return LatestBlueprintBundle(
        attemptId: latestAttemptId,
        carousel: latestCarousel,
      );
    } on DioException {
      // Backward compatibility fallback if latest endpoint is unavailable.
      final response = await _dio.get(_buildUrl('/assessments/results'));
      final raw = response.data;
      final data = raw['data'] ?? raw;

      String attemptId = '';
      if (data is Map<String, dynamic>) {
        attemptId = (data['attempt_id'] ?? '').toString();
        if (attemptId.isEmpty) {
          final result = data['result'];
          if (result is Map<String, dynamic>) {
            attemptId = (result['attempt_id'] ?? '').toString();
          }
        }
      }

      if (attemptId.isEmpty) {
        final fallback = await getCarouselBlueprints('latest');
        final effectiveAttempt = fallback.assessmentAttemptId.isNotEmpty
            ? fallback.assessmentAttemptId
            : 'latest';
        return LatestBlueprintBundle(
          attemptId: effectiveAttempt,
          carousel: fallback,
        );
      }

      final carousel = await getCarouselBlueprints(attemptId);
      return LatestBlueprintBundle(attemptId: attemptId, carousel: carousel);
    } catch (e) {
      throw BlueprintException('Failed to load latest career blueprints: $e');
    }
  }

  /// Get carousel view with 3 blueprint summaries
  Future<BlueprintCarouselResponse> getCarouselBlueprints(String attemptId) async {
    try {
      final response = await _dio.get(
        _buildUrl('/assessments/blueprints/carousel/$attemptId'),
        options: _longRequestOptions(),
      );

      return BlueprintCarouselResponse.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      // Split-submit flow fallback:
      // 1) Compute/persist career matches
      // 2) Retry blueprint carousel once
      final statusCode = e.response?.statusCode;
      final message = (e.response?.data?['error']?['message'] ?? '').toString();
      final normalized = message.toLowerCase();
      final shouldRetryNoBlueprints = statusCode == 404 &&
          normalized.contains('no career blueprints found');
      final shouldRetryGenerationFailure = statusCode == 500 &&
          normalized.contains('failed to generate career blueprints');

      final shouldRetry = shouldRetryNoBlueprints || shouldRetryGenerationFailure;

      if (shouldRetry) {
        try {
          await _dio.get(
            _buildUrl('/assessments/career-matches'),
            options: _longRequestOptions(),
          );
          final retryResponse = await _dio.get(
            _buildUrl('/assessments/blueprints/carousel/$attemptId'),
            options: _longRequestOptions(),
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

  /// Generate a single blueprint for the selected career option.
  Future<String> generateSelectedBlueprint({
    required String attemptId,
    required String careerId,
    int roadmapHorizonMonths = 12,
  }) async {
    try {
      final response = await _dio.post(
        _buildUrl('/assessments/blueprints/generate'),
        data: {
          'attempt_id': attemptId,
          'career_id': careerId,
          'roadmap_horizon_months': roadmapHorizonMonths,
        },
        options: _longRequestOptions(),
      );

      final raw = response.data;
      final data = raw['data'] ?? raw;
      final blueprintId = (data['blueprint_id'] ?? '').toString();
      if (blueprintId.isEmpty) {
        throw BlueprintException('Blueprint was generated but no blueprint_id was returned');
      }
      return blueprintId;
    } catch (e) {
      throw BlueprintException('Failed to generate selected blueprint: $e');
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

class LatestBlueprintBundle {
  final String attemptId;
  final BlueprintCarouselResponse carousel;

  LatestBlueprintBundle({
    required this.attemptId,
    required this.carousel,
  });
}

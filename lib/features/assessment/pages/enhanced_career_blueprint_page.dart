import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:karriova_app/core/config/app_config.dart';
import 'package:karriova_app/core/constants/app_colors.dart';
import 'package:karriova_app/core/di/injection.dart';
import 'package:karriova_app/features/assessment/models/career_blueprint_model.dart';
import 'package:karriova_app/features/assessment/pages/career_blueprint_carousel_page.dart';
import 'package:karriova_app/features/assessment/services/blueprint_api_service.dart';

/// API-driven blueprint entry page for the Career Roadmap tab.
/// It resolves the latest attempt and then renders the real carousel UI.
class EnhancedCareerBlueprintPage extends StatefulWidget {
  final bool embedded;

  const EnhancedCareerBlueprintPage({super.key, this.embedded = false});

  @override
  State<EnhancedCareerBlueprintPage> createState() =>
      _EnhancedCareerBlueprintPageState();
}

class _EnhancedCareerBlueprintPageState
    extends State<EnhancedCareerBlueprintPage> {
  late final Dio _dio;
  late final BlueprintApiService _apiService;

  bool _isLoading = true;
  String? _errorMessage;
  String _attemptId = '';
  BlueprintCarouselResponse? _initialData;

  @override
  void initState() {
    super.initState();
    _dio = getIt<Dio>();
    _apiService = BlueprintApiService(dio: _dio, baseUrl: AppConfig.apiBaseUrl);
    _loadLatestBlueprints();
  }

  Future<void> _loadLatestBlueprints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final latest = await _apiService.getLatestCarouselBlueprints();
      if (!mounted) return;
      setState(() {
        _attemptId = latest.attemptId;
        _initialData = latest.carousel;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load your latest career blueprints. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 12),
            Text(
              'Loading your latest career options...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadLatestBlueprints,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_attemptId.isEmpty || _initialData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No completed assessment attempt found for blueprint generation.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return CareerBlueprintCarouselPage(
      attemptId: _attemptId,
      initialData: _initialData,
      onBlueprintSelected: _loadLatestBlueprints,
      dio: _dio,
      apiBaseUrl: AppConfig.apiBaseUrl,
      embedded: widget.embedded,
    );
  }
}

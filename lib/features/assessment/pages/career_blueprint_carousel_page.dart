import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:karriova_app/core/constants/app_colors.dart';
import 'package:karriova_app/core/constants/app_dimensions.dart';
import 'package:karriova_app/core/theme/app_typography.dart';
import 'package:karriova_app/core/routes/app_router.dart';
import 'package:karriova_app/core/config/app_config.dart';
import 'package:karriova_app/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karriova_app/features/assessment/models/career_blueprint_model.dart';
import 'package:karriova_app/features/assessment/services/blueprint_api_service.dart';
import 'package:karriova_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:karriova_app/features/auth/presentation/bloc/auth_state.dart';
import 'career_blueprint_detail_page.dart';

/// Blueprint Carousel Page - Shows 3 career options with summary cards
class CareerBlueprintCarouselPage extends StatefulWidget {
  final String attemptId;
  final BlueprintCarouselResponse? initialData;
  final VoidCallback? onBlueprintSelected;
  final Dio? dio;
  final String? apiBaseUrl;

  const CareerBlueprintCarouselPage({
    required this.attemptId,
    this.initialData,
    this.onBlueprintSelected,
    this.dio,
    this.apiBaseUrl,
    Key? key,
  }) : super(key: key);

  @override
  _CareerBlueprintCarouselPageState createState() =>
      _CareerBlueprintCarouselPageState();
}

class _CareerBlueprintCarouselPageState
    extends State<CareerBlueprintCarouselPage> {
  late PageController _pageController;
  int _currentIndex = 0;
  BlueprintCarouselResponse? _carouselData;
  bool _isLoading = true;
  String? _errorMessage;
  late BlueprintApiService _apiService;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.9);
    
    // Initialize API service
    final dio = widget.dio ?? getIt<Dio>();
    final baseUrl = widget.apiBaseUrl ?? AppConfig.apiBaseUrl;
    _apiService = BlueprintApiService(dio: dio, baseUrl: baseUrl);
    
    // Load data
    _loadCarouselData();
  }

  Future<void> _loadCarouselData() async {
    try {
      setState(() => _isLoading = true);
      
      if (widget.initialData != null) {
        setState(() {
          _carouselData = widget.initialData;
          _isLoading = false;
        });
      } else {
        final data = await _apiService.getCarouselBlueprints(widget.attemptId);
        setState(() {
          _carouselData = data;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      var message = 'Unable to load your career roadmap right now.';
      final status = e.response?.statusCode;

      if (status == 401) {
        message = 'Your session has expired. Please sign in again.';
      } else if (status == 404) {
        message = 'No career blueprints found yet. Complete KIT and generate your roadmap first.';
      } else if (status == 500) {
        message = 'Server error while loading roadmap. Please try again shortly.';
      }

      setState(() {
        _isLoading = false;
        _errorMessage = message;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load your career roadmap right now.';
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectBlueprint(CarouselBlueprint blueprint) {
    final effectiveAttemptId = _carouselData?.assessmentAttemptId ?? widget.attemptId;

    // Navigate to detail page via GoRouter
    GoRouter.of(context).push(
      AppRouter.careerBlueprintDetail
          .replaceFirst(':blueprintId', blueprint.id),
      extra: {
        'careerName': blueprint.careerName,
        'attemptId': effectiveAttemptId,
        'dio': widget.dio,
        'apiBaseUrl': widget.apiBaseUrl,
      },
    ).then((_) {
      // Refresh after selection
      widget.onBlueprintSelected?.call();
      _loadCarouselData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final assessmentDone =
        context.watch<AuthBloc>().state.assessmentCompleted == true;

    if (!assessmentDone) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Career Blueprint'),
          centerTitle: true,
          backgroundColor: AppColors.white,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.psychology_outlined,
                          size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Complete Your KIT Assessment First',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your personalised career blueprint is generated based on your KIT scores. Take the assessment to unlock your top 3 career matches.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.go(AppRouter.assessment),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Take Assessment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Career Options'),
          centerTitle: true,
          backgroundColor: AppColors.white,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadCarouselData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_carouselData == null || _carouselData!.blueprints.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Career Options'),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
        ),
        body: const Center(
          child: Text('No blueprints available'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Career Options'),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Explore Your Paths',
                    style: AppTypography.heading2.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Swipe to explore your top 3 career matches.\nSelect one to dive deep into your personalized roadmap.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),

            // Carousel
            SizedBox(
              height: 520,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: _carouselData!.blueprints.length,
                itemBuilder: (context, index) {
                  final blueprint = _carouselData!.blueprints[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _BlueprintCard(
                      blueprint: blueprint,
                      onTap: () => _selectBlueprint(blueprint),
                    ),
                  );
                },
              ),
            ),

            // Indicator dots
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _carouselData!.blueprints.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentIndex
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                ),
              ),
            ),

            // Quick stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Total Matches',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_carouselData!.blueprints.length}',
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Top Match',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_carouselData!.blueprints.first.fitScore.toStringAsFixed(1)}',
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual blueprint card for carousel
class _BlueprintCard extends StatelessWidget {
  final CarouselBlueprint blueprint;
  final VoidCallback onTap;

  const _BlueprintCard({
    required this.blueprint,
    required this.onTap,
  });

  Color _getDifficultyColor() {
    switch (blueprint.difficultyLevel.toLowerCase()) {
      case 'low':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fit score badge
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Match: ${blueprint.fitScore.toStringAsFixed(1)}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Career name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                blueprint.careerName,
                style: AppTypography.heading3.copyWith(fontSize: 26),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4),

            // Category
            if (blueprint.careerCategory != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  blueprint.careerCategory!,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: 12),

            // Difficulty and Confidence badges
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Difficulty: ${blueprint.difficultyLevel}',
                        style: AppTypography.caption.copyWith(
                          color: _getDifficultyColor(),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Fit: ${blueprint.confidenceLevel}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // CTA Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View Full Blueprint'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../domain/models/assessment_models.dart';
import '../widgets/dimension_score_bar.dart';

/// Assessment results page - displays user's assessment scores
class AssessmentResultsPage extends StatelessWidget {
  final AssessmentResultModel result;

  const AssessmentResultsPage({
    super.key,
    required this.result,
  });

  /// Show the results page as a dialog
  static Future<void> show(BuildContext context,
      {required AssessmentResultModel result}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => AssessmentResultsPage(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group scores by section
    final scoresBySection = <String, List<DimensionScoreModel>>{};
    for (final score in result.scores) {
      scoresBySection.putIfAbsent(score.sectionName, () => []).add(score);
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 700,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: AppDimensions.paddingXL),

              // Results content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...scoresBySection.entries.map((entry) => _buildSection(
                            sectionName: entry.key,
                            scores: entry.value,
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLG),

              // Continue button
              GradientButton(
                text: 'Continue to App',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Success icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(36),
          ),
          child: const Icon(
            Icons.check_circle,
            color: AppColors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMD),
        const Text(
          'Assessment Complete! 🎉',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.paddingSM),
        const Text(
          'Here\'s your personality profile based on your responses.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String sectionName,
    required List<DimensionScoreModel> scores,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMD),
          child: Text(
            sectionName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        // Dimension scores
        ...scores.map((score) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
              child: DimensionScoreBar(score: score),
            )),
      ],
    );
  }
}

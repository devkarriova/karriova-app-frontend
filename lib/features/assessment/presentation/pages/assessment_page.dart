import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../domain/models/assessment_models.dart';
import '../bloc/assessment_bloc.dart';
import '../bloc/assessment_event.dart';
import '../bloc/assessment_state.dart';
import '../widgets/assessment_progress_bar.dart';
import '../widgets/question_card.dart';

/// Standalone full-screen assessment page
/// Shown to users on first login before they can access the main app
class AssessmentPage extends StatelessWidget {
  final VoidCallback onComplete;

  const AssessmentPage({
    super.key,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AssessmentBloc>()..add(const AssessmentLoadRequested()),
      child: _AssessmentPageContent(onComplete: onComplete),
    );
  }
}

class _AssessmentPageContent extends StatelessWidget {
  final VoidCallback onComplete;

  const _AssessmentPageContent({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssessmentBloc, AssessmentState>(
      listener: (context, state) {
        if (state.status == AssessmentStatus.completed && state.result != null) {
          // Show results page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AssessmentResultsFullPage(
                result: state.result!,
                onContinue: onComplete,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: _buildContent(context, state),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AssessmentState state) {
    switch (state.status) {
      case AssessmentStatus.initial:
      case AssessmentStatus.loading:
        return _buildLoadingState();
      case AssessmentStatus.error:
        return _buildErrorState(context, state);
      case AssessmentStatus.inProgress:
        return _buildInProgressState(context, state);
      case AssessmentStatus.submitting:
        return _buildSubmittingState();
      case AssessmentStatus.completed:
        return _buildLoadingState(); // Will navigate via listener
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppDimensions.paddingLG),
          Text(
            'Preparing your assessment...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AssessmentState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppDimensions.paddingLG),
            Text(
              state.errorMessage ?? 'Something went wrong',
              style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            GradientButton(
              text: 'Try Again',
              onPressed: () {
                context.read<AssessmentBloc>().add(const AssessmentLoadRequested());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInProgressState(BuildContext context, AssessmentState state) {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) {
      return _buildLoadingState();
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          child: Column(
            children: [
              // Header
              _buildHeader(state),
              const SizedBox(height: AppDimensions.paddingXL),

              // Progress bar
              AssessmentProgressBar(
                progress: state.progress,
                currentQuestion: state.currentQuestionIndex + 1,
                totalQuestions: state.totalQuestions,
              ),
              const SizedBox(height: AppDimensions.paddingXL),

              // Question card in a container
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: QuestionCard(
                      question: currentQuestion,
                      selectedOptionId: state.selectedOptionId,
                      onOptionSelected: (optionId) {
                        context.read<AssessmentBloc>().add(
                              AssessmentOptionSelected(
                                questionId: currentQuestion.id,
                                optionId: optionId,
                              ),
                            );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLG),

              // Navigation buttons
              _buildNavigationButtons(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AssessmentState state) {
    final section = state.currentSection;
    final dimension = state.currentDimension;

    return Column(
      children: [
        // Logo/Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(
            Icons.psychology,
            color: AppColors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMD),
        // Title
        const Text(
          'Personality Assessment',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXS),
        // Section & dimension info
        if (section != null)
          Text(
            section.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        if (dimension != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${dimension.poleALabel} ↔ ${dimension.poleBLabel}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context, AssessmentState state) {
    final bloc = context.read<AssessmentBloc>();
    final isLastQuestion = state.isLastQuestion;
    final isAnswered = state.isCurrentQuestionAnswered;

    return Row(
      children: [
        // Back button
        if (!state.isFirstQuestion)
          Expanded(
            child: OutlinedButton(
              onPressed: () => bloc.add(const AssessmentPreviousQuestion()),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        if (!state.isFirstQuestion) const SizedBox(width: AppDimensions.paddingMD),

        // Continue/Submit button
        Expanded(
          child: GradientButton(
            text: isLastQuestion ? 'Submit' : 'Continue',
            onPressed: isAnswered
                ? () {
                    if (isLastQuestion) {
                      bloc.add(const AssessmentSubmitRequested());
                    } else {
                      bloc.add(const AssessmentNextQuestion());
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmittingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppDimensions.paddingLG),
          Text(
            'Analyzing your responses...',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Full-screen results page after assessment completion
class AssessmentResultsFullPage extends StatelessWidget {
  final AssessmentResultModel result;
  final VoidCallback onContinue;

  const AssessmentResultsFullPage({
    super.key,
    required this.result,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    // Group scores by section
    final scoresBySection = <String, List<DimensionScoreModel>>{};
    for (final score in result.scores) {
      scoresBySection.putIfAbsent(score.sectionName, () => []).add(score);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: AppDimensions.paddingXL),

                  // Results
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingLG),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
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
                  ),
                  const SizedBox(height: AppDimensions.paddingLG),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      text: 'Continue to Karriova',
                      onPressed: onContinue,
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

  Widget _buildHeader() {
    return Column(
      children: [
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
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
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
        ...scores.map((score) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
              child: _DimensionScoreBar(score: score),
            )),
      ],
    );
  }
}

/// Dimension score bar widget
class _DimensionScoreBar extends StatelessWidget {
  final DimensionScoreModel score;

  const _DimensionScoreBar({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            score.dimensionName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                score.poleALabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: score.score < 50 ? FontWeight.w600 : FontWeight.w400,
                  color: score.score < 50 ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
              Text(
                score.poleBLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: score.score >= 50 ? FontWeight.w600 : FontWeight.w400,
                  color: score.score >= 50 ? AppColors.secondary : AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          SizedBox(
            height: 24,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final markerPosition = constraints.maxWidth * (score.score / 100);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 8,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gradientStart, AppColors.gradientEnd],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Positioned(
                      left: markerPosition - 12,
                      top: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getMarkerColor(score.score),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getMarkerColor(score.score).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                score.descriptiveLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getMarkerColor(score.score),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMarkerColor(double score) {
    if (score < 45) return AppColors.primary;
    if (score > 55) return AppColors.secondary;
    return AppColors.textSecondary;
  }
}

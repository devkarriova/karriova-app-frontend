import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../bloc/assessment_bloc.dart';
import '../bloc/assessment_event.dart';
import '../bloc/assessment_state.dart';
import '../widgets/assessment_progress_bar.dart';
import '../widgets/question_card.dart';
import 'assessment_results_page.dart';

/// Full-screen assessment modal
class AssessmentModal extends StatelessWidget {
  final VoidCallback onComplete;

  const AssessmentModal({
    super.key,
    required this.onComplete,
  });

  /// Show the assessment modal
  static Future<void> show(BuildContext context,
      {required VoidCallback onComplete}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => AssessmentModal(onComplete: onComplete),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssessmentBloc, AssessmentState>(
      listener: (context, state) {
        if (state.status == AssessmentStatus.completed && state.result != null) {
          // Show results screen
          Navigator.of(context).pop();
          AssessmentResultsPage.show(context, result: state.result!).then((_) {
            onComplete();
          });
        }
      },
      builder: (context, state) {
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
        return _buildSubmittingState(state);
      case AssessmentStatus.completed:
        return _buildLoadingState(); // Will navigate via listener
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: AppDimensions.paddingLG),
            Text(
              'Loading assessment...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AssessmentState state) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppDimensions.paddingLG),
          Text(
            state.errorMessage ?? 'Something went wrong',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
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
    );
  }

  Widget _buildInProgressState(BuildContext context, AssessmentState state) {
    final currentQuestion = state.currentQuestion;
    if (currentQuestion == null) {
      return _buildLoadingState();
    }

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with section info
          _buildHeader(state),
          const SizedBox(height: AppDimensions.paddingLG),
          
          // Progress bar
          AssessmentProgressBar(
            progress: state.progress,
            currentQuestion: state.currentQuestionIndex + 1,
            totalQuestions: state.totalQuestions,
          ),
          const SizedBox(height: AppDimensions.paddingXL),
          
          // Question content
          Expanded(
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
          const SizedBox(height: AppDimensions.paddingLG),
          
          // Navigation buttons
          _buildNavigationButtons(context, state),
        ],
      ),
    );
  }

  Widget _buildHeader(AssessmentState state) {
    final section = state.currentSection;
    final dimension = state.currentDimension;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Assessment icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.psychology,
            color: AppColors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMD),
        // Section name
        if (section != null)
          Text(
            section.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        // Dimension name
        if (dimension != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${dimension.poleALabel} ↔ ${dimension.poleBLabel}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
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
        // Back button (only show if not first question)
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
          flex: state.isFirstQuestion ? 1 : 1,
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

  Widget _buildSubmittingState(AssessmentState state) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: AppDimensions.paddingLG),
            Text(
              'Analyzing your responses...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

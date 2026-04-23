import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../domain/models/assessment_models.dart';
import '../bloc/assessment_bloc.dart';
import '../bloc/assessment_event.dart';
import '../bloc/assessment_state.dart';
import '../widgets/question_card.dart';
import '../widgets/assessment_timers.dart';
import '../widgets/question_overview_sidebar.dart';

/// Standalone full-screen assessment page
/// Shown to users on first login before they can access the main app
class AssessmentPage extends StatelessWidget {
  final VoidCallback? onComplete;

  const AssessmentPage({
    super.key,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AssessmentBloc>()
        ..add(const AssessmentLoadRequested())
        ..add(const AssessmentStartTimer()),
      child: _AssessmentPageContent(onComplete: onComplete ?? () {}),
    );
  }
}

class _AssessmentPageContent extends StatefulWidget {
  final VoidCallback onComplete;

  const _AssessmentPageContent({required this.onComplete});

  @override
  State<_AssessmentPageContent> createState() => _AssessmentPageContentState();
}

class _AssessmentPageContentState extends State<_AssessmentPageContent> {
  bool _sidebarCollapsed = false;

  VoidCallback get onComplete => widget.onComplete;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssessmentBloc, AssessmentState>(
      listener: (context, state) {
        if (state.status == AssessmentStatus.completed && state.result != null) {
          final attemptId = state.result!.attemptId;
          final path = attemptId.isNotEmpty
              ? '${AppRouter.assessmentResults}?attemptId=$attemptId'
              : AppRouter.assessmentResults;
          context.go(path);
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
    return Container(
      color: const Color(0xFFF5F5F7), // Light grey background
      child: const Center(
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
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AssessmentState state) {
    return Container(
      color: const Color(0xFFF5F5F7), // Light grey background
      child: Center(
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
      ),
    );
  }

  Widget _buildInProgressState(BuildContext context, AssessmentState state) {
    print('🎯 [AssessmentPage] Building inProgress state...');
    final currentQuestion = state.currentQuestion;
    print('   📝 Current question: ${currentQuestion?.text ?? "NULL"}');
    print('   📁 Current section: ${state.currentSection?.name ?? "NULL"}');

    if (currentQuestion == null || state.currentSection == null) {
      print('⚠️ [AssessmentPage] currentQuestion or currentSection is null, showing loader');
      return _buildLoadingState();
    }

    print('✅ [AssessmentPage] Rendering question UI');
    final screenWidth = MediaQuery.of(context).size.width;
    final showSidebarPermanent = screenWidth > 900;

    return Container(
      color: const Color(0xFFF5F5F7), // Light grey background
      child: Column(
        children: [
          // Timers at top (full width)
          AssessmentTimers(
            remainingTestTime: state.remainingTestTime,
            remainingSectionTime: state.remainingSectionTime,
            sectionName: state.currentSection?.name,
            totalTestDurationMinutes: state.totalTestDurationMinutes,
            sectionDurationMinutes: state.currentSection?.durationMinutes ?? 15,
          ),

          // Main content area
          Expanded(
            child: Stack(
              children: [
                Row(
                  children: [
                    // Sidebar (show on desktop/tablet only)
                    if (showSidebarPermanent)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: _sidebarCollapsed ? 0 : 280,
                        child: ClipRect(
                          child: OverflowBox(
                            alignment: Alignment.centerLeft,
                            maxWidth: 280,
                            child: QuestionOverviewSidebar(
                              currentSection: state.currentSection!,
                              currentParameterName:
                                  state.currentParameter?.name,
                              sectionQuestions:
                                  state.currentParameterQuestions,
                              currentQuestionId:
                                  state.currentQuestion?.id ?? '',
                              attemptedQuestionIds:
                                  state.attemptedQuestionIds,
                              onQuestionTap: (localIndex) {
                                final globalIndex =
                                    _getGlobalIndexForParameterQuestion(
                                  state,
                                  localIndex,
                                );
                                context.read<AssessmentBloc>().add(
                                      AssessmentNavigateToQuestion(globalIndex),
                                    );
                              },
                              onNextParameter:
                                  state.canProceedToNextParameter
                                      ? () => _navigateToNextParameter(
                                          context, state)
                                      : null,
                              onNextSection: state.canProceedToNextSection
                                  ? () {
                                      context.read<AssessmentBloc>().add(
                                            AssessmentNavigateToSection(
                                              state.currentSectionIndex + 1,
                                            ),
                                          );
                                    }
                                  : null,
                              canProceedToNextParameter:
                                  state.canProceedToNextParameter,
                              canProceedToNextSection:
                                  state.canProceedToNextSection,
                              answeredCount:
                                  state.currentParameterAnsweredCount,
                            ),
                          ),
                        ),
                      ),

                    // Question area (centered, constrained width)
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingLG),
                        child: Column(
                          children: [
                            // Minimal header
                            _buildMinimalHeader(),
                            const SizedBox(height: AppDimensions.paddingMD),

                            // Hamburger menu for mobile
                            if (!showSidebarPermanent)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: const Icon(Icons.menu),
                                  onPressed: () =>
                                      _showMobileSidebar(context, state),
                                ),
                              ),

                            // Question card with animation
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.05, 0),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                      )),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  key: ValueKey(currentQuestion.id),
                                  padding:
                                      const EdgeInsets.all(AppDimensions.paddingLG),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius:
                                        BorderRadius.circular(AppDimensions.radiusLG),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 16,
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
                            ),
                            const SizedBox(height: AppDimensions.paddingLG),

                            // Arrow navigation (keep existing)
                            _buildArrowNavigation(context, state),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

                // Floating toggle button at the sidebar edge
                if (showSidebarPermanent)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    top: 16,
                    left: _sidebarCollapsed ? 4 : 266,
                    child: GestureDetector(
                      onTap: () => setState(
                          () => _sidebarCollapsed = !_sidebarCollapsed),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.grey.shade300, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _sidebarCollapsed
                              ? Icons.chevron_right
                              : Icons.chevron_left,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalHeader() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.psychology,
        color: AppColors.white,
        size: 24,
      ),
    );
  }

  Widget _buildArrowNavigation(BuildContext context, AssessmentState state) {
    final bloc = context.read<AssessmentBloc>();
    final isLastQuestion = state.isLastQuestion;
    final isAnswered = state.isCurrentQuestionAnswered;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left arrow (Back)
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: state.isFirstQuestion ? 0.3 : 1.0,
          child: MouseRegion(
            cursor: state.isFirstQuestion
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: state.isFirstQuestion
                  ? null
                  : () => bloc.add(const AssessmentPreviousQuestion()),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ),
            ),
          ),
        ),

        // Right arrow (Next/Submit)
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isAnswered ? 1.0 : 0.3,
          child: MouseRegion(
            cursor: isAnswered
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: isAnswered
                  ? () {
                      if (isLastQuestion) {
                        bloc.add(const AssessmentSubmitRequested());
                      } else {
                        bloc.add(const AssessmentNextQuestion());
                      }
                    }
                  : null,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: isAnswered
                      ? const LinearGradient(
                          colors: [AppColors.gradientStart, AppColors.gradientEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isAnswered ? null : AppColors.surface,
                  shape: BoxShape.circle,
                  border: isAnswered ? null : Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: isAnswered
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isLastQuestion ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  color: isAnswered ? AppColors.white : AppColors.textSecondary,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmittingState() {
    return Container(
      color: const Color(0xFFF5F5F7), // Light grey background
      child: const Center(
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
      ),
    );
  }

  /// Convert a parameter-local question index to the global question index.
  int _getGlobalIndexForParameterQuestion(
    AssessmentState state,
    int localIndex,
  ) {
    final paramQuestions = state.currentParameterQuestions;
    if (localIndex >= paramQuestions.length) return 0;
    final targetQuestion = paramQuestions[localIndex];
    final idx = state.allQuestions.indexWhere((q) => q.id == targetQuestion.id);
    return idx < 0 ? 0 : idx;
  }

  /// Navigate to the first question of the next parameter within the current section.
  void _navigateToNextParameter(BuildContext context, AssessmentState state) {
    final section = state.currentSection;
    final parameters = section?.parameters;
    if (parameters == null || parameters.isEmpty) return;

    final nextParamIndex = state.currentParameterIndex + 1;
    if (nextParamIndex >= parameters.length) return;

    final nextParam = parameters[nextParamIndex];
    if (nextParam.questions.isEmpty) return;

    final firstQuestion = nextParam.questions.first;
    final globalIndex =
        state.allQuestions.indexWhere((q) => q.id == firstQuestion.id);
    if (globalIndex >= 0) {
      context
          .read<AssessmentBloc>()
          .add(AssessmentNavigateToQuestion(globalIndex));
    }
  }

  /// Show mobile sidebar as bottom sheet
  void _showMobileSidebar(BuildContext context, AssessmentState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: CompactQuestionOverview(
          currentSection: state.currentSection!,
          currentParameterName: state.currentParameter?.name,
          sectionQuestions: state.currentParameterQuestions,
          currentQuestionId: state.currentQuestion?.id ?? '',
          attemptedQuestionIds: state.attemptedQuestionIds,
          onQuestionTap: (localIndex) {
            final globalIndex = _getGlobalIndexForParameterQuestion(
              state,
              localIndex,
            );
            context.read<AssessmentBloc>().add(
                  AssessmentNavigateToQuestion(globalIndex),
                );
            Navigator.pop(context);
          },
          onNextParameter: state.canProceedToNextParameter
              ? () {
                  _navigateToNextParameter(context, state);
                  Navigator.pop(context);
                }
              : null,
          onNextSection: state.canProceedToNextSection
              ? () {
                  context.read<AssessmentBloc>().add(
                        AssessmentNavigateToSection(
                          state.currentSectionIndex + 1,
                        ),
                      );
                  Navigator.pop(context);
                }
              : null,
          canProceedToNextParameter: state.canProceedToNextParameter,
          canProceedToNextSection: state.canProceedToNextSection,
          answeredCount: state.currentParameterAnsweredCount,
        ),
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

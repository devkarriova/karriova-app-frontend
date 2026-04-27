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
      listenWhen: (previous, current) =>
          previous.status != AssessmentStatus.completed &&
          current.status == AssessmentStatus.completed &&
          current.result != null,
      listener: (context, state) {
        final attemptId = state.result!.attemptId;
        final path = attemptId.isNotEmpty
            ? '${AppRouter.assessmentResults}?attemptId=$attemptId'
            : AppRouter.assessmentResults;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go(path);
        });
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
    final currentQuestion = state.currentQuestion;

    if (currentQuestion == null || state.currentSection == null) {
      return _buildLoadingState();
    }
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
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingXL),
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
                                      const EdgeInsets.all(AppDimensions.paddingXL),
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
        // Debug: Fill Random button (password-gated)
        TextButton.icon(
          onPressed: () => _showFillRandomDialog(context, bloc),
          icon: const Icon(Icons.shuffle, size: 16, color: AppColors.textSecondary),
          label: const Text(
            'Fill Random',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
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

  /// Show password dialog before filling random answers
  void _showFillRandomDialog(BuildContext context, AssessmentBloc bloc) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Debug: Fill Random'),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Password'),
          onSubmitted: (_) => _submitFillRandom(ctx, controller.text, bloc),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _submitFillRandom(ctx, controller.text, bloc),
            child: const Text('Fill'),
          ),
        ],
      ),
    );
  }

  void _submitFillRandom(BuildContext ctx, String password, AssessmentBloc bloc) {
    Navigator.pop(ctx);
    if (password == 'youcantdothis') {
      bloc.add(const AssessmentFillRandom());
      bloc.add(const AssessmentSubmitRequested());
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

/// Full-screen completion page shown after assessment submission
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Completion icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(48),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Assessment Complete!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your responses have been analysed. Explore your personalised career blueprint with tailored roadmaps and insights.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    text: 'Explore My Career Blueprint',
                    onPressed: onContinue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


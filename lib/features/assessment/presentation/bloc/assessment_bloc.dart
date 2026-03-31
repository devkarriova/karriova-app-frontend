import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/assessment_repository_impl.dart';
import '../../domain/models/assessment_models.dart';
import 'assessment_event.dart';
import 'assessment_state.dart';

/// Assessment BLoC - Handles assessment business logic
class AssessmentBloc extends Bloc<AssessmentEvent, AssessmentState> {
  final AssessmentRepository assessmentRepository;

  AssessmentBloc({required this.assessmentRepository})
      : super(const AssessmentState()) {
    on<AssessmentLoadRequested>(_onLoadRequested);
    on<AssessmentOptionSelected>(_onOptionSelected);
    on<AssessmentNextQuestion>(_onNextQuestion);
    on<AssessmentPreviousQuestion>(_onPreviousQuestion);
    on<AssessmentSubmitRequested>(_onSubmitRequested);
    on<AssessmentStatusCheckRequested>(_onStatusCheckRequested);
    on<AssessmentResultsRequested>(_onResultsRequested);
    // NEW event handlers
    on<AssessmentNavigateToQuestion>(_onNavigateToQuestion);
    on<AssessmentNavigateToSection>(_onNavigateToSection);
    on<AssessmentStartTimer>(_onStartTimer);
    on<AssessmentTimerTick>(_onTimerTick);
  }

  /// Load the active assessment
  Future<void> _onLoadRequested(
    AssessmentLoadRequested event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.loading));

    final result = await assessmentRepository.getActiveAssessment();

    result.fold(
      (error) => emit(state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: error,
      )),
      (assessment) {
        // Calculate total test duration from all sections
        final totalDuration = assessment.sections.fold<int>(
          0,
          (sum, section) => sum + section.durationMinutes,
        );

        emit(state.copyWith(
          status: AssessmentStatus.inProgress,
          assessment: assessment,
          currentQuestionIndex: 0,
          currentSectionIndex: 0,
          responses: {},
          attemptedQuestionIds: {},
          totalTestDurationMinutes: totalDuration,
          sectionCompletionStatus: {},
        ));
      },
    );
  }

  /// Handle option selection
  void _onOptionSelected(
    AssessmentOptionSelected event,
    Emitter<AssessmentState> emit,
  ) {
    final newResponses = Map<String, String>.from(state.responses);
    newResponses[event.questionId] = event.optionId;

    // Track this question as attempted
    final newAttempted = Set<String>.from(state.attemptedQuestionIds);
    newAttempted.add(event.questionId);

    emit(state.copyWith(
      responses: newResponses,
      attemptedQuestionIds: newAttempted,
    ));
  }

  /// Navigate to next question
  void _onNextQuestion(
    AssessmentNextQuestion event,
    Emitter<AssessmentState> emit,
  ) {
    if (!state.isLastQuestion) {
      emit(state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      ));
    }
  }

  /// Navigate to previous question
  void _onPreviousQuestion(
    AssessmentPreviousQuestion event,
    Emitter<AssessmentState> emit,
  ) {
    if (!state.isFirstQuestion) {
      emit(state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      ));
    }
  }

  /// Submit all responses
  Future<void> _onSubmitRequested(
    AssessmentSubmitRequested event,
    Emitter<AssessmentState> emit,
  ) async {
    if (!state.allQuestionsAnswered) {
      emit(state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: 'Please answer all questions before submitting',
      ));
      return;
    }

    emit(state.copyWith(status: AssessmentStatus.submitting));

    // Convert responses map to list of ResponseInput
    final responses = state.responses.entries
        .map((e) => ResponseInput(questionId: e.key, optionId: e.value))
        .toList();

    final result = await assessmentRepository.submitAssessment(responses);

    result.fold(
      (error) => emit(state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: error,
      )),
      (assessmentResult) => emit(state.copyWith(
        status: AssessmentStatus.completed,
        result: assessmentResult,
        hasCompletedAssessment: true,
      )),
    );
  }

  /// Check if user has already completed assessment
  Future<void> _onStatusCheckRequested(
    AssessmentStatusCheckRequested event,
    Emitter<AssessmentState> emit,
  ) async {
    final result = await assessmentRepository.hasCompletedAssessment();

    result.fold(
      (error) => emit(state.copyWith(
        errorMessage: error,
      )),
      (completed) => emit(state.copyWith(
        hasCompletedAssessment: completed,
      )),
    );
  }

  /// Load user's assessment results
  Future<void> _onResultsRequested(
    AssessmentResultsRequested event,
    Emitter<AssessmentState> emit,
  ) async {
    emit(state.copyWith(status: AssessmentStatus.loading));

    final result = await assessmentRepository.getMyResults();

    result.fold(
      (error) => emit(state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: error,
      )),
      (assessmentResult) => emit(state.copyWith(
        status: AssessmentStatus.completed,
        result: assessmentResult,
        hasCompletedAssessment: assessmentResult.completed,
      )),
    );
  }

  // ========================================
  // NEW EVENT HANDLERS
  // ========================================

  /// Navigate to a specific question by index
  void _onNavigateToQuestion(
    AssessmentNavigateToQuestion event,
    Emitter<AssessmentState> emit,
  ) {
    // Validate: can only navigate within current section
    if (event.questionIndex < 0 ||
        event.questionIndex >= state.totalQuestions) {
      return; // Invalid index
    }

    final targetQuestion = state.allQuestions[event.questionIndex];

    // Check if question is in current section
    final currentSectionQuestions = state.currentSectionQuestions;
    final isInCurrentSection = currentSectionQuestions.any((q) => q.id == targetQuestion.id);

    if (!isInCurrentSection) {
      // Cannot navigate to questions in other sections
      return;
    }

    emit(state.copyWith(currentQuestionIndex: event.questionIndex));
  }

  /// Navigate to a specific section
  void _onNavigateToSection(
    AssessmentNavigateToSection event,
    Emitter<AssessmentState> emit,
  ) {
    if (event.sectionIndex < 0 || event.sectionIndex >= state.sections.length) {
      return; // Invalid section index
    }

    // Can only navigate forward if current section is complete
    if (event.sectionIndex > state.currentSectionIndex &&
        !state.isCurrentSectionComplete) {
      return; // Current section not complete
    }

    // Find first question in target section
    final targetSection = state.sections[event.sectionIndex];
    final targetSectionFirstQuestion = targetSection.allQuestions.first;
    final targetQuestionIndex = state.allQuestions.indexWhere((q) => q.id == targetSectionFirstQuestion.id);

    emit(state.copyWith(
      currentSectionIndex: event.sectionIndex,
      currentQuestionIndex: targetQuestionIndex,
      sectionStartTime: DateTime.now(), // Reset section timer
    ));
  }

  /// Start the assessment timer
  void _onStartTimer(
    AssessmentStartTimer event,
    Emitter<AssessmentState> emit,
  ) {
    final now = DateTime.now();
    emit(state.copyWith(
      assessmentStartTime: now,
      sectionStartTime: now,
    ));
  }

  /// Handle timer tick (no-op, state recalculates timers dynamically)
  void _onTimerTick(
    AssessmentTimerTick event,
    Emitter<AssessmentState> emit,
  ) {
    // Timer state is calculated dynamically in getters
    // This event can trigger a rebuild if needed
    if (state.isTestTimeExpired || state.isSectionTimeExpired) {
      // Could auto-submit or show warning here
      emit(state.copyWith(
        status: AssessmentStatus.error,
        errorMessage: 'Time expired',
      ));
    }
  }
}

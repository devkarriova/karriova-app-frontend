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
      (assessment) => emit(state.copyWith(
        status: AssessmentStatus.inProgress,
        assessment: assessment,
        currentQuestionIndex: 0,
        responses: {},
      )),
    );
  }

  /// Handle option selection
  void _onOptionSelected(
    AssessmentOptionSelected event,
    Emitter<AssessmentState> emit,
  ) {
    final newResponses = Map<String, String>.from(state.responses);
    newResponses[event.questionId] = event.optionId;

    emit(state.copyWith(responses: newResponses));
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
}

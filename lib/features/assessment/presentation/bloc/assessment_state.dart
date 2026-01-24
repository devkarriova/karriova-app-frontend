import 'package:equatable/equatable.dart';
import '../../domain/models/assessment_models.dart';

/// Assessment status enum
enum AssessmentStatus {
  initial,
  loading,
  inProgress,
  submitting,
  completed,
  error,
}

/// Assessment state
class AssessmentState extends Equatable {
  final AssessmentStatus status;
  final AssessmentModel? assessment;
  final AssessmentResultModel? result;
  final int currentQuestionIndex;
  final Map<String, String> responses; // questionId -> optionId
  final String? errorMessage;
  final bool hasCompletedAssessment;

  const AssessmentState({
    this.status = AssessmentStatus.initial,
    this.assessment,
    this.result,
    this.currentQuestionIndex = 0,
    this.responses = const {},
    this.errorMessage,
    this.hasCompletedAssessment = false,
  });

  /// Get total number of questions
  int get totalQuestions => assessment?.totalQuestions ?? 0;

  /// Get all questions in order
  List<QuestionModel> get allQuestions => assessment?.allQuestions ?? [];

  /// Get current question
  QuestionModel? get currentQuestion {
    if (allQuestions.isEmpty || currentQuestionIndex >= allQuestions.length) {
      return null;
    }
    return allQuestions[currentQuestionIndex];
  }

  /// Check if current question has been answered
  bool get isCurrentQuestionAnswered {
    if (currentQuestion == null) return false;
    return responses.containsKey(currentQuestion!.id);
  }

  /// Get selected option ID for current question
  String? get selectedOptionId {
    if (currentQuestion == null) return null;
    return responses[currentQuestion!.id];
  }

  /// Check if we're on the first question
  bool get isFirstQuestion => currentQuestionIndex == 0;

  /// Check if we're on the last question
  bool get isLastQuestion => currentQuestionIndex >= totalQuestions - 1;

  /// Calculate progress (0.0 to 1.0)
  double get progress {
    if (totalQuestions == 0) return 0.0;
    return (currentQuestionIndex + 1) / totalQuestions;
  }

  /// Check if all questions are answered
  bool get allQuestionsAnswered => responses.length >= totalQuestions;

  /// Get current section based on question index
  SectionModel? get currentSection {
    if (assessment == null || currentQuestion == null) return null;
    for (final section in assessment!.sections) {
      for (final dimension in section.dimensions) {
        if (dimension.questions.any((q) => q.id == currentQuestion!.id)) {
          return section;
        }
      }
    }
    return null;
  }

  /// Get current dimension based on question index
  DimensionModel? get currentDimension {
    if (assessment == null || currentQuestion == null) return null;
    for (final section in assessment!.sections) {
      for (final dimension in section.dimensions) {
        if (dimension.questions.any((q) => q.id == currentQuestion!.id)) {
          return dimension;
        }
      }
    }
    return null;
  }

  AssessmentState copyWith({
    AssessmentStatus? status,
    AssessmentModel? assessment,
    AssessmentResultModel? result,
    int? currentQuestionIndex,
    Map<String, String>? responses,
    String? errorMessage,
    bool? hasCompletedAssessment,
  }) {
    return AssessmentState(
      status: status ?? this.status,
      assessment: assessment ?? this.assessment,
      result: result ?? this.result,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      responses: responses ?? this.responses,
      errorMessage: errorMessage ?? this.errorMessage,
      hasCompletedAssessment:
          hasCompletedAssessment ?? this.hasCompletedAssessment,
    );
  }

  @override
  List<Object?> get props => [
        status,
        assessment,
        result,
        currentQuestionIndex,
        responses,
        errorMessage,
        hasCompletedAssessment,
      ];
}

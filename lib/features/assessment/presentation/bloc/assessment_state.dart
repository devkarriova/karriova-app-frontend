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

  // NEW - Section tracking
  final int currentSectionIndex;

  // NEW - Question attempt tracking
  final Set<String> attemptedQuestionIds;

  // NEW - Timer state
  final DateTime? assessmentStartTime;
  final DateTime? sectionStartTime;
  final int totalTestDurationMinutes;

  // NEW - Section completion status
  final Map<String, bool> sectionCompletionStatus; // sectionId -> isComplete

  // Incremented each timer tick so Equatable always sees a changed state
  final int timerTick;

  const AssessmentState({
    this.status = AssessmentStatus.initial,
    this.assessment,
    this.result,
    this.currentQuestionIndex = 0,
    this.responses = const {},
    this.errorMessage,
    this.hasCompletedAssessment = false,
    this.currentSectionIndex = 0,
    this.attemptedQuestionIds = const {},
    this.assessmentStartTime,
    this.sectionStartTime,
    this.totalTestDurationMinutes = 60, // Default 60 minutes
    this.sectionCompletionStatus = const {},
    this.timerTick = 0,
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
      // Check parameters (new KIT structure)
      if (section.parameters != null) {
        for (final parameter in section.parameters!) {
          if (parameter.questions.any((q) => q.id == currentQuestion!.id)) {
            return section;
          }
        }
      }
      // Check dimensions (legacy structure)
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

  // ========================================
  // NEW SECTION MANAGEMENT METHODS
  // ========================================

  /// Get list of all sections
  List<SectionModel> get sections => assessment?.sections ?? [];

  /// Get questions for the current section
  List<QuestionModel> get currentSectionQuestions {
    if (currentSection == null) return [];
    return currentSection!.allQuestions;
  }

  /// Check if a specific section is complete (all questions answered)
  bool isSectionComplete(String sectionId) {
    final section = sections.firstWhere((s) => s.id == sectionId, orElse: () => throw Exception('Section not found'));
    final sectionQuestions = section.allQuestions;
    return sectionQuestions.every((q) => attemptedQuestionIds.contains(q.id));
  }

  /// Check if current section is complete
  bool get isCurrentSectionComplete {
    if (currentSection == null) return false;
    return isSectionComplete(currentSection!.id);
  }

  /// Check if user can proceed to next section
  bool get canProceedToNextSection {
    if (currentSectionIndex >= sections.length - 1) return false; // Already on last section
    return isCurrentSectionComplete;
  }

  /// Check if a question has been attempted
  bool isQuestionAttempted(String questionId) {
    return attemptedQuestionIds.contains(questionId);
  }

  /// Get count of answered questions in current section
  int get currentSectionAnsweredCount {
    if (currentSection == null) return 0;
    final sectionQuestions = currentSectionQuestions;
    return sectionQuestions.where((q) => attemptedQuestionIds.contains(q.id)).length;
  }

  /// Get total questions in current section
  int get currentSectionTotalQuestions => currentSectionQuestions.length;

  // ========================================
  // TIMER MANAGEMENT METHODS
  // ========================================

  /// Get remaining time for overall test (in seconds)
  Duration? get remainingTestTime {
    if (assessmentStartTime == null) return null;
    final elapsed = DateTime.now().difference(assessmentStartTime!);
    final total = Duration(minutes: totalTestDurationMinutes);
    final remaining = total - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get remaining time for current section (in seconds)
  Duration? get remainingSectionTime {
    if (sectionStartTime == null || currentSection == null) return null;
    final elapsed = DateTime.now().difference(sectionStartTime!);
    final total = Duration(minutes: currentSection!.durationMinutes);
    final remaining = total - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if overall test time has expired
  bool get isTestTimeExpired {
    final remaining = remainingTestTime;
    return remaining != null && remaining.inSeconds <= 0;
  }

  /// Check if section time has expired
  bool get isSectionTimeExpired {
    final remaining = remainingSectionTime;
    return remaining != null && remaining.inSeconds <= 0;
  }

  AssessmentState copyWith({
    AssessmentStatus? status,
    AssessmentModel? assessment,
    AssessmentResultModel? result,
    int? currentQuestionIndex,
    Map<String, String>? responses,
    String? errorMessage,
    bool? hasCompletedAssessment,
    int? currentSectionIndex,
    Set<String>? attemptedQuestionIds,
    DateTime? assessmentStartTime,
    DateTime? sectionStartTime,
    int? totalTestDurationMinutes,
    Map<String, bool>? sectionCompletionStatus,
    int? timerTick,
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
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
      attemptedQuestionIds: attemptedQuestionIds ?? this.attemptedQuestionIds,
      assessmentStartTime: assessmentStartTime ?? this.assessmentStartTime,
      sectionStartTime: sectionStartTime ?? this.sectionStartTime,
      totalTestDurationMinutes:
          totalTestDurationMinutes ?? this.totalTestDurationMinutes,
      sectionCompletionStatus:
          sectionCompletionStatus ?? this.sectionCompletionStatus,
      timerTick: timerTick ?? this.timerTick,
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
        currentSectionIndex,
        attemptedQuestionIds,
        assessmentStartTime,
        sectionStartTime,
        totalTestDurationMinutes,
        sectionCompletionStatus,
        timerTick,
      ];
}

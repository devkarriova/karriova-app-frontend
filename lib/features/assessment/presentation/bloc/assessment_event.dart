import 'package:equatable/equatable.dart';

/// Assessment events
abstract class AssessmentEvent extends Equatable {
  const AssessmentEvent();

  @override
  List<Object?> get props => [];
}

/// Load the active assessment
class AssessmentLoadRequested extends AssessmentEvent {
  const AssessmentLoadRequested();
}

/// Select an option for a question
class AssessmentOptionSelected extends AssessmentEvent {
  final String questionId;
  final String optionId;

  const AssessmentOptionSelected({
    required this.questionId,
    required this.optionId,
  });

  @override
  List<Object?> get props => [questionId, optionId];
}

/// Navigate to next question
class AssessmentNextQuestion extends AssessmentEvent {
  const AssessmentNextQuestion();
}

/// Navigate to previous question
class AssessmentPreviousQuestion extends AssessmentEvent {
  const AssessmentPreviousQuestion();
}

/// Submit all responses
class AssessmentSubmitRequested extends AssessmentEvent {
  const AssessmentSubmitRequested();
}

/// Check if user has completed assessment
class AssessmentStatusCheckRequested extends AssessmentEvent {
  const AssessmentStatusCheckRequested();
}

/// Load user's assessment results
class AssessmentResultsRequested extends AssessmentEvent {
  const AssessmentResultsRequested();
}

// ========================================
// NEW EVENTS FOR ENHANCED NAVIGATION
// ========================================

/// Navigate to a specific question by index
class AssessmentNavigateToQuestion extends AssessmentEvent {
  final int questionIndex;

  const AssessmentNavigateToQuestion(this.questionIndex);

  @override
  List<Object?> get props => [questionIndex];
}

/// Navigate to a specific section
class AssessmentNavigateToSection extends AssessmentEvent {
  final int sectionIndex;

  const AssessmentNavigateToSection(this.sectionIndex);

  @override
  List<Object?> get props => [sectionIndex];
}

/// Start the assessment timer
class AssessmentStartTimer extends AssessmentEvent {
  const AssessmentStartTimer();
}

/// Update timer state (called periodically)
class AssessmentTimerTick extends AssessmentEvent {
  const AssessmentTimerTick();
}

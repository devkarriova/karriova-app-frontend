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

import 'package:equatable/equatable.dart';

/// Option model for assessment questions
class OptionModel extends Equatable {
  final String id;
  final String questionId;
  final String text;
  final int score;
  final int displayOrder;

  const OptionModel({
    required this.id,
    required this.questionId,
    required this.text,
    required this.score,
    required this.displayOrder,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['id'] as String,
      questionId: json['question_id'] as String? ?? '',
      text: json['text'] as String,
      score: json['score'] as int,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'text': text,
      'score': score,
      'display_order': displayOrder,
    };
  }

  @override
  List<Object?> get props => [id, questionId, text, score, displayOrder];
}

/// Question model for assessments
class QuestionModel extends Equatable {
  final String id;
  final String dimensionId;
  final String text;
  final String poleDirection; // "A" or "B"
  final int displayOrder;
  final bool isActive;
  final List<OptionModel> options;

  const QuestionModel({
    required this.id,
    required this.dimensionId,
    required this.text,
    required this.poleDirection,
    required this.displayOrder,
    required this.isActive,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      dimensionId: json['dimension_id'] as String? ?? '',
      text: json['text'] as String,
      poleDirection: json['pole_direction'] as String? ?? 'A',
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => OptionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dimension_id': dimensionId,
      'text': text,
      'pole_direction': poleDirection,
      'display_order': displayOrder,
      'is_active': isActive,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props =>
      [id, dimensionId, text, poleDirection, displayOrder, isActive, options];
}

/// Dimension model representing a measurable trait (e.g., "Workstyle")
class DimensionModel extends Equatable {
  final String id;
  final String sectionId;
  final String name;
  final String description;
  final String poleALabel; // e.g., "Structured"
  final String poleBLabel; // e.g., "Flexible"
  final int displayOrder;
  final List<QuestionModel> questions;

  const DimensionModel({
    required this.id,
    required this.sectionId,
    required this.name,
    required this.description,
    required this.poleALabel,
    required this.poleBLabel,
    required this.displayOrder,
    required this.questions,
  });

  factory DimensionModel.fromJson(Map<String, dynamic> json) {
    return DimensionModel(
      id: json['id'] as String,
      sectionId: json['section_id'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      poleALabel: json['pole_a_label'] as String,
      poleBLabel: json['pole_b_label'] as String,
      displayOrder: json['display_order'] as int? ?? 0,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'name': name,
      'description': description,
      'pole_a_label': poleALabel,
      'pole_b_label': poleBLabel,
      'display_order': displayOrder,
      'questions': questions.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        sectionId,
        name,
        description,
        poleALabel,
        poleBLabel,
        displayOrder,
        questions
      ];
}

/// Section model representing a category of assessment (e.g., "Core Personality")
class SectionModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final int displayOrder;
  final bool isActive;
  final List<DimensionModel> dimensions;

  const SectionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.displayOrder,
    required this.isActive,
    required this.dimensions,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      dimensions: (json['dimensions'] as List<dynamic>?)
              ?.map((e) => DimensionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'display_order': displayOrder,
      'is_active': isActive,
      'dimensions': dimensions.map((e) => e.toJson()).toList(),
    };
  }

  /// Get all questions from all dimensions in this section
  List<QuestionModel> get allQuestions {
    return dimensions.expand((d) => d.questions).toList();
  }

  @override
  List<Object?> get props =>
      [id, name, description, displayOrder, isActive, dimensions];
}

/// Full assessment model containing all sections
class AssessmentModel extends Equatable {
  final List<SectionModel> sections;

  const AssessmentModel({required this.sections});

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => SectionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sections': sections.map((e) => e.toJson()).toList(),
    };
  }

  /// Get all questions across all sections
  List<QuestionModel> get allQuestions {
    return sections.expand((s) => s.allQuestions).toList();
  }

  /// Get total number of questions
  int get totalQuestions => allQuestions.length;

  @override
  List<Object?> get props => [sections];
}

/// User response input for submission
class ResponseInput extends Equatable {
  final String questionId;
  final String optionId;

  const ResponseInput({
    required this.questionId,
    required this.optionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'option_id': optionId,
    };
  }

  @override
  List<Object?> get props => [questionId, optionId];
}

/// Dimension score result
class DimensionScoreModel extends Equatable {
  final String dimensionId;
  final String dimensionName;
  final String sectionName;
  final String poleALabel;
  final String poleBLabel;
  final double score; // 0-100 scale (0 = pole_a, 100 = pole_b)

  const DimensionScoreModel({
    required this.dimensionId,
    required this.dimensionName,
    required this.sectionName,
    required this.poleALabel,
    required this.poleBLabel,
    required this.score,
  });

  factory DimensionScoreModel.fromJson(Map<String, dynamic> json) {
    return DimensionScoreModel(
      dimensionId: json['dimension_id'] as String,
      dimensionName: json['dimension_name'] as String,
      sectionName: json['section_name'] as String,
      poleALabel: json['pole_a_label'] as String,
      poleBLabel: json['pole_b_label'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }

  /// Get a descriptive label based on the score
  String get descriptiveLabel {
    if (score < 25) return 'Strongly $poleALabel';
    if (score < 45) return 'Moderately $poleALabel';
    if (score < 55) return 'Balanced';
    if (score < 75) return 'Moderately $poleBLabel';
    return 'Strongly $poleBLabel';
  }

  @override
  List<Object?> get props =>
      [dimensionId, dimensionName, sectionName, poleALabel, poleBLabel, score];
}

/// Assessment result containing all dimension scores
class AssessmentResultModel extends Equatable {
  final bool completed;
  final List<DimensionScoreModel> scores;

  const AssessmentResultModel({
    required this.completed,
    required this.scores,
  });

  factory AssessmentResultModel.fromJson(Map<String, dynamic> json) {
    return AssessmentResultModel(
      completed: json['completed'] as bool? ?? false,
      scores: (json['scores'] as List<dynamic>?)
              ?.map(
                  (e) => DimensionScoreModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [completed, scores];
}

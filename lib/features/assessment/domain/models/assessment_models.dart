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

/// Parameter model for KIT assessments (generalizes dimensions)
class ParameterModel extends Equatable {
  final String id;
  final String sectionId;
  final String name;
  final String description;
  final String code; // e.g., "thinking_style", "realistic"
  final String parameterType; // "bipolar", "unipolar", "riasec"
  final String? poleALabel; // For bipolar only
  final String? poleBLabel; // For bipolar only
  final String category; // "Personality", "RIASEC", "Aptitude", "Orientation"
  final int displayOrder;
  final List<QuestionModel> questions;

  const ParameterModel({
    required this.id,
    required this.sectionId,
    required this.name,
    required this.description,
    required this.code,
    required this.parameterType,
    this.poleALabel,
    this.poleBLabel,
    required this.category,
    required this.displayOrder,
    required this.questions,
  });

  factory ParameterModel.fromJson(Map<String, dynamic> json) {
    return ParameterModel(
      id: json['id'] as String,
      sectionId: json['section_id'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      code: json['code'] as String,
      parameterType: json['parameter_type'] as String,
      poleALabel: json['pole_a_label'] as String?,
      poleBLabel: json['pole_b_label'] as String?,
      category: json['category'] as String,
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
      'code': code,
      'parameter_type': parameterType,
      'pole_a_label': poleALabel,
      'pole_b_label': poleBLabel,
      'category': category,
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
        code,
        parameterType,
        poleALabel,
        poleBLabel,
        category,
        displayOrder,
        questions
      ];
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
  final int durationMinutes; // Duration for this section in minutes
  final List<DimensionModel> dimensions; // For old structure (backward compatibility)
  final List<ParameterModel>? parameters; // For new KIT structure
  final List<QuestionModel>? questions; // Flat interleaved order from backend
  final String? sectionType; // "personality", "riasec", "aptitude_mcq", etc.
  final String? scoringMethod; // "bipolar", "selection", "mcq", "weighted"
  final int? totalQuestions;
  final double? categoryWeight;
  final String? instructions;

  const SectionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.displayOrder,
    required this.isActive,
    required this.durationMinutes,
    this.dimensions = const [],
    this.parameters,
    this.questions,
    this.sectionType,
    this.scoringMethod,
    this.totalQuestions,
    this.categoryWeight,
    this.instructions,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      durationMinutes: json['duration_minutes'] as int? ?? 15, // Default 15 minutes
      dimensions: (json['dimensions'] as List<dynamic>?)
              ?.map((e) => DimensionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      parameters: (json['parameters'] as List<dynamic>?)
          ?.map((e) => ParameterModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      questions: (json['questions'] as List<dynamic>?)
          ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      sectionType: json['section_type'] as String?,
      scoringMethod: json['scoring_method'] as String?,
      totalQuestions: json['total_questions'] as int?,
      categoryWeight: (json['category_weight'] as num?)?.toDouble(),
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'display_order': displayOrder,
      'is_active': isActive,
      'duration_minutes': durationMinutes,
      'dimensions': dimensions.map((e) => e.toJson()).toList(),
      'parameters': parameters?.map((e) => e.toJson()).toList(),
      'questions': questions?.map((e) => e.toJson()).toList(),
      'section_type': sectionType,
      'scoring_method': scoringMethod,
      'total_questions': totalQuestions,
      'category_weight': categoryWeight,
      'instructions': instructions,
    };
  }

  /// Get all questions from dimensions or parameters in this section.
  /// Prefers the flat interleaved list provided by the backend if available.
  List<QuestionModel> get allQuestions {
    if (questions != null && questions!.isNotEmpty) {
      return questions!;
    }
    if (parameters != null && parameters!.isNotEmpty) {
      return parameters!.expand((p) => p.questions).toList();
    }
    return dimensions.expand((d) => d.questions).toList();
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        displayOrder,
        isActive,
        durationMinutes,
        dimensions,
        parameters,
        questions,
        sectionType,
        scoringMethod,
        totalQuestions,
        categoryWeight,
        instructions
      ];
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

/// Validation issue returned from bulk upload validation.
class BulkValidationIssueModel extends Equatable {
  final int rowNumber;
  final String field;
  final String message;

  const BulkValidationIssueModel({
    required this.rowNumber,
    required this.field,
    required this.message,
  });

  factory BulkValidationIssueModel.fromJson(Map<String, dynamic> json) {
    return BulkValidationIssueModel(
      rowNumber: (json['RowNumber'] ?? json['row_number'] ?? 0) as int,
      field: (json['Field'] ?? json['field'] ?? '') as String,
      message: (json['Message'] ?? json['message'] ?? '') as String,
    );
  }

  @override
  List<Object?> get props => [rowNumber, field, message];
}

class BulkSummaryStatsModel extends Equatable {
  final int totalQuestions;
  final Map<String, int> questionsByType;
  final List<String> uniqueParameters;
  final int validationErrors;
  final int validationWarnings;

  const BulkSummaryStatsModel({
    required this.totalQuestions,
    required this.questionsByType,
    required this.uniqueParameters,
    required this.validationErrors,
    required this.validationWarnings,
  });

  factory BulkSummaryStatsModel.fromJson(Map<String, dynamic> json) {
    final rawByType = (json['questions_by_type'] as Map<String, dynamic>?) ?? {};
    return BulkSummaryStatsModel(
      totalQuestions: (json['total_questions'] ?? 0) as int,
      questionsByType: rawByType.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
      uniqueParameters: (json['unique_parameters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      validationErrors: (json['validation_errors'] ?? 0) as int,
      validationWarnings: (json['validation_warnings'] ?? 0) as int,
    );
  }

  @override
  List<Object?> get props => [
        totalQuestions,
        questionsByType,
        uniqueParameters,
        validationErrors,
        validationWarnings,
      ];
}

class BulkValidationResponseModel extends Equatable {
  final bool valid;
  final List<BulkValidationIssueModel> errors;
  final List<BulkValidationIssueModel> warnings;
  final BulkSummaryStatsModel? summary;

  const BulkValidationResponseModel({
    required this.valid,
    required this.errors,
    required this.warnings,
    this.summary,
  });

  factory BulkValidationResponseModel.fromJson(Map<String, dynamic> json) {
    return BulkValidationResponseModel(
      valid: json['valid'] as bool? ?? false,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => BulkValidationIssueModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => BulkValidationIssueModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      summary: json['summary'] != null
          ? BulkSummaryStatsModel.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [valid, errors, warnings, summary];
}

class BulkUploadResponseModel extends Equatable {
  final bool success;
  final List<String> questionIds;
  final BulkSummaryStatsModel? summary;
  final List<BulkValidationIssueModel> errors;
  final List<BulkValidationIssueModel> warnings;
  final String? errorMessage;

  const BulkUploadResponseModel({
    required this.success,
    required this.questionIds,
    this.summary,
    required this.errors,
    required this.warnings,
    this.errorMessage,
  });

  factory BulkUploadResponseModel.fromJson(Map<String, dynamic> json) {
    return BulkUploadResponseModel(
      success: json['success'] as bool? ?? false,
      questionIds: (json['question_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      summary: json['summary'] != null
          ? BulkSummaryStatsModel.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => BulkValidationIssueModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => BulkValidationIssueModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      errorMessage: json['error_message'] as String?,
    );
  }

  @override
  List<Object?> get props => [success, questionIds, summary, errors, warnings, errorMessage];
}

class QuestionTemplateModel extends Equatable {
  final List<int> bytes;
  final String fileName;

  const QuestionTemplateModel({required this.bytes, required this.fileName});

  @override
  List<Object?> get props => [bytes, fileName];
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

/// Parameter score from KIT scoring
class ParameterScoreModel extends Equatable {
  final String parameterId;
  final String parameterName;
  final String parameterCode;
  final String parameterType;
  final String category;
  final String sectionName;
  final String? poleALabel;
  final String? poleBLabel;
  final double rawScore;
  final double normalizedScore;
  final double? poleAPercentage;
  final double? poleBPercentage;
  final double? intensityScore;

  const ParameterScoreModel({
    required this.parameterId,
    required this.parameterName,
    required this.parameterCode,
    required this.parameterType,
    required this.category,
    required this.sectionName,
    this.poleALabel,
    this.poleBLabel,
    required this.rawScore,
    required this.normalizedScore,
    this.poleAPercentage,
    this.poleBPercentage,
    this.intensityScore,
  });

  factory ParameterScoreModel.fromJson(Map<String, dynamic> json) {
    return ParameterScoreModel(
      parameterId: json['parameter_id'] as String? ?? '',
      parameterName: json['parameter_name'] as String? ?? '',
      parameterCode: json['parameter_code'] as String? ?? '',
      parameterType: json['parameter_type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      sectionName: json['section_name'] as String? ?? '',
      poleALabel: json['pole_a_label'] as String?,
      poleBLabel: json['pole_b_label'] as String?,
      rawScore: (json['raw_score'] as num?)?.toDouble() ?? 0,
      normalizedScore: (json['normalized_score'] as num?)?.toDouble() ?? 0,
      poleAPercentage: (json['pole_a_percentage'] as num?)?.toDouble(),
      poleBPercentage: (json['pole_b_percentage'] as num?)?.toDouble(),
      intensityScore: (json['intensity_score'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [parameterId, normalizedScore];
}

/// Career match from MAD scoring
class CareerMatchModel extends Equatable {
  final String careerProfileId;
  final String careerName;
  final String description;
  final double fitScore;
  final double overallMAD;
  final double personalityMAD;
  final double riasecMAD;
  final double aptitudeMAD;
  final double orientationMAD;
  final int rank;

  const CareerMatchModel({
    required this.careerProfileId,
    required this.careerName,
    required this.description,
    required this.fitScore,
    required this.overallMAD,
    required this.personalityMAD,
    required this.riasecMAD,
    required this.aptitudeMAD,
    required this.orientationMAD,
    required this.rank,
  });

  factory CareerMatchModel.fromJson(Map<String, dynamic> json) {
    return CareerMatchModel(
      careerProfileId: json['career_profile_id'] as String? ?? '',
      careerName: json['career_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      fitScore: (json['fit_score'] as num?)?.toDouble() ?? 0,
      overallMAD: (json['overall_mad'] as num?)?.toDouble() ?? 0,
      personalityMAD: (json['personality_mad'] as num?)?.toDouble() ?? 0,
      riasecMAD: (json['riasec_mad'] as num?)?.toDouble() ?? 0,
      aptitudeMAD: (json['aptitude_mad'] as num?)?.toDouble() ?? 0,
      orientationMAD: (json['orientation_mad'] as num?)?.toDouble() ?? 0,
      rank: json['rank'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [careerProfileId, fitScore, rank];
}

/// Reliability summary from KIT section 8
class ReliabilityModel extends Equatable {
  final bool passed;
  final bool straightLiningCheck;
  final bool scoreDiscriminationCheck;
  final bool extremeClusteringCheck;
  final double scoreRange;
  final double scoreStdDev;
  final int extremeCount;

  const ReliabilityModel({
    required this.passed,
    required this.straightLiningCheck,
    required this.scoreDiscriminationCheck,
    required this.extremeClusteringCheck,
    required this.scoreRange,
    required this.scoreStdDev,
    required this.extremeCount,
  });

  factory ReliabilityModel.fromJson(Map<String, dynamic> json) {
    return ReliabilityModel(
      passed: json['passed'] as bool? ?? false,
      straightLiningCheck: json['straight_lining_check'] as bool? ?? false,
      scoreDiscriminationCheck: json['score_discrimination_check'] as bool? ?? false,
      extremeClusteringCheck: json['extreme_clustering_check'] as bool? ?? false,
      scoreRange: (json['score_range'] as num?)?.toDouble() ?? 0,
      scoreStdDev: (json['score_std_dev'] as num?)?.toDouble() ?? 0,
      extremeCount: json['extreme_count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [passed, scoreRange, scoreStdDev, extremeCount];
}

/// Intensity summary per category
class IntensityModel extends Equatable {
  final double personality;
  final double riasec;
  final double aptitude;
  final double orientation;
  final double overall;

  const IntensityModel({
    required this.personality,
    required this.riasec,
    required this.aptitude,
    required this.orientation,
    required this.overall,
  });

  factory IntensityModel.fromJson(Map<String, dynamic> json) {
    return IntensityModel(
      personality: (json['personality'] as num?)?.toDouble() ?? 0,
      riasec: (json['riasec'] as num?)?.toDouble() ?? 0,
      aptitude: (json['aptitude'] as num?)?.toDouble() ?? 0,
      orientation: (json['orientation'] as num?)?.toDouble() ?? 0,
      overall: (json['overall'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [personality, riasec, aptitude, orientation, overall];
}

/// Assessment result containing all dimension scores
class AssessmentResultModel extends Equatable {
  final bool completed;
  final String attemptId;
  final List<DimensionScoreModel> scores;
  final List<ParameterScoreModel> parameterScores;
  final List<CareerMatchModel> careerMatches;
  final ReliabilityModel? reliability;
  final IntensityModel? intensity;

  const AssessmentResultModel({
    required this.completed,
    this.attemptId = '',
    required this.scores,
    this.parameterScores = const [],
    this.careerMatches = const [],
    this.reliability,
    this.intensity,
  });

  factory AssessmentResultModel.fromJson(Map<String, dynamic> json) {
    return AssessmentResultModel(
      completed: json['completed'] as bool? ?? false,
      attemptId: json['attempt_id'] as String? ?? '',
      scores: (json['scores'] as List<dynamic>?)
              ?.map((e) => DimensionScoreModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      parameterScores: (json['parameter_scores'] as List<dynamic>?)
              ?.map((e) => ParameterScoreModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      careerMatches: (json['career_matches'] as List<dynamic>?)
              ?.map((e) => CareerMatchModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reliability: json['reliability'] != null
          ? ReliabilityModel.fromJson(json['reliability'] as Map<String, dynamic>)
          : null,
      intensity: json['intensity'] != null
          ? IntensityModel.fromJson(json['intensity'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [completed, attemptId, scores, parameterScores, careerMatches, reliability, intensity];
}

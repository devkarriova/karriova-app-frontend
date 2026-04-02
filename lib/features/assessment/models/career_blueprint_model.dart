import 'package:flutter/foundation.dart';

/// Card content for a section
class BlueprintCardContent {
  final String title;
  final String description;
  final List<String> items;
  final String? icon;
  final String? color;

  BlueprintCardContent({
    required this.title,
    required this.description,
    this.items = const [],
    this.icon,
    this.color,
  });

  factory BlueprintCardContent.fromJson(Map<String, dynamic> json) {
    return BlueprintCardContent(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      items: List<String>.from(json['items'] ?? []),
      icon: json['icon'],
      color: json['color'],
    );
  }
}

/// Warning/prerequisite in a section
class BlueprintWarning {
  final String title;
  final String description;
  final String severity; // "low", "medium", "high"

  BlueprintWarning({
    required this.title,
    required this.description,
    required this.severity,
  });

  factory BlueprintWarning.fromJson(Map<String, dynamic> json) {
    return BlueprintWarning(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'medium',
    );
  }
}

/// A section in the blueprint (14 total)
class BlueprintSection {
  final String id;
  final String title;
  final String? subtitle;
  final String description;
  final String sectionType; // insight, action, warning, data, timeline, list
  final List<BlueprintCardContent> content;
  final List<BlueprintWarning> warnings;
  final bool expanded;
  final int orderIndex;

  BlueprintSection({
    required this.id,
    required this.title,
    this.subtitle,
    required this.description,
    required this.sectionType,
    required this.content,
    this.warnings = const [],
    this.expanded = false,
    required this.orderIndex,
  });

  factory BlueprintSection.fromJson(Map<String, dynamic> json) {
    return BlueprintSection(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      description: json['description'] ?? '',
      sectionType: json['section_type'] ?? 'insight',
      content: (json['content'] as List?)
              ?.map((c) => BlueprintCardContent.fromJson(c))
              .toList() ??
          [],
      warnings: (json['warnings'] as List?)
              ?.map((w) => BlueprintWarning.fromJson(w))
              .toList() ??
          [],
      expanded: json['expanded'] ?? false,
      orderIndex: json['order_index'] ?? 0,
    );
  }
}

/// Salary projection data
class SalaryProjectionData {
  final String year;
  final int minSalary;
  final int medSalary;
  final int maxSalary;
  final double trendPercent;

  SalaryProjectionData({
    required this.year,
    required this.minSalary,
    required this.medSalary,
    required this.maxSalary,
    required this.trendPercent,
  });

  factory SalaryProjectionData.fromJson(Map<String, dynamic> json) {
    return SalaryProjectionData(
      year: json['year'] ?? '',
      minSalary: json['min_salary'] ?? 0,
      medSalary: json['med_salary'] ?? 0,
      maxSalary: json['max_salary'] ?? 0,
      trendPercent: (json['trend_percent'] ?? 0).toDouble(),
    );
  }
}

/// Job market demand data
class JobMarketPoint {
  final String year;
  final int openPositions;
  final double growthRate;

  JobMarketPoint({
    required this.year,
    required this.openPositions,
    required this.growthRate,
  });

  factory JobMarketPoint.fromJson(Map<String, dynamic> json) {
    return JobMarketPoint(
      year: json['year'] ?? '',
      openPositions: json['open_positions'] ?? 0,
      growthRate: (json['growth_rate'] ?? 0).toDouble(),
    );
  }
}

/// Skill alignment data for radar chart
class SkillRadarData {
  final String skill;
  final double userLevel;
  final double required;
  final double importance;

  SkillRadarData({
    required this.skill,
    required this.userLevel,
    required this.required,
    required this.importance,
  });

  factory SkillRadarData.fromJson(Map<String, dynamic> json) {
    return SkillRadarData(
      skill: json['skill'] ?? '',
      userLevel: (json['user_level'] ?? 0).toDouble(),
      required: (json['required'] ?? 0).toDouble(),
      importance: (json['importance'] ?? 0).toDouble(),
    );
  }
}

/// Chart data container
class ChartData {
  final List<SalaryProjectionData> salaryProjection;
  final List<JobMarketPoint> jobMarketDemand;
  final List<SkillRadarData> skillAlignment;

  ChartData({
    this.salaryProjection = const [],
    this.jobMarketDemand = const [],
    this.skillAlignment = const [],
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      salaryProjection: (json['salary_projection'] as List?)
              ?.map((d) => SalaryProjectionData.fromJson(d))
              .toList() ??
          [],
      jobMarketDemand: (json['job_market_demand'] as List?)
              ?.map((d) => JobMarketPoint.fromJson(d))
              .toList() ??
          [],
      skillAlignment: (json['skill_alignment'] as List?)
              ?.map((d) => SkillRadarData.fromJson(d))
              .toList() ??
          [],
    );
  }
}

/// Full career blueprint with 14 sections
class CareerBlueprint {
  final String id;
  final String userId;
  final String assessmentAttemptId;
  final String careerId;
  final String careerName;
  final String? careerCategory;
  final double fitScore;
  final String difficultyLevel;
  final String confidenceLevel;
  final List<BlueprintSection> sections;
  final ChartData? charts;
  final String status;
  final int? selectionOrder;
  final DateTime? selectedAt;
  final DateTime generatedAt;
  final DateTime? lastViewedAt;
  final DateTime updatedAt;
  final int generationVersion;

  CareerBlueprint({
    required this.id,
    required this.userId,
    required this.assessmentAttemptId,
    required this.careerId,
    required this.careerName,
    this.careerCategory,
    required this.fitScore,
    required this.difficultyLevel,
    required this.confidenceLevel,
    required this.sections,
    this.charts,
    required this.status,
    this.selectionOrder,
    this.selectedAt,
    required this.generatedAt,
    this.lastViewedAt,
    required this.updatedAt,
    required this.generationVersion,
  });

  bool get isSelected => status == 'selected';

  factory CareerBlueprint.fromJson(Map<String, dynamic> json) {
    return CareerBlueprint(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      assessmentAttemptId: json['assessment_attempt_id'] ?? '',
      careerId: json['career_id'] ?? '',
      careerName: json['career_name'] ?? '',
      careerCategory: json['career_category'],
      fitScore: (json['fit_score'] ?? 0).toDouble(),
      difficultyLevel: json['difficulty_level'] ?? 'medium',
      confidenceLevel: json['confidence_level'] ?? 'medium',
      sections: (json['sections'] as List?)
              ?.map((s) => BlueprintSection.fromJson(s))
              .toList() ??
          [],
      charts: json['charts'] != null
          ? ChartData.fromJson(json['charts'])
          : null,
      status: json['status'] ?? 'generated',
      selectionOrder: json['selection_order'],
      selectedAt: json['selected_at'] != null
          ? DateTime.parse(json['selected_at'])
          : null,
      generatedAt: DateTime.parse(json['generated_at'] ?? DateTime.now().toIso8601String()),
      lastViewedAt: json['last_viewed_at'] != null
          ? DateTime.parse(json['last_viewed_at'])
          : null,
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      generationVersion: json['generation_version'] ?? 1,
    );
  }

  CareerBlueprint copyWith({
    String? id,
    String? userId,
    String? assessmentAttemptId,
    String? careerId,
    String? careerName,
    String? careerCategory,
    double? fitScore,
    String? difficultyLevel,
    String? confidenceLevel,
    List<BlueprintSection>? sections,
    ChartData? charts,
    String? status,
    int? selectionOrder,
    DateTime? selectedAt,
    DateTime? generatedAt,
    DateTime? lastViewedAt,
    DateTime? updatedAt,
    int? generationVersion,
  }) {
    return CareerBlueprint(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      assessmentAttemptId: assessmentAttemptId ?? this.assessmentAttemptId,
      careerId: careerId ?? this.careerId,
      careerName: careerName ?? this.careerName,
      careerCategory: careerCategory ?? this.careerCategory,
      fitScore: fitScore ?? this.fitScore,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      sections: sections ?? this.sections,
      charts: charts ?? this.charts,
      status: status ?? this.status,
      selectionOrder: selectionOrder ?? this.selectionOrder,
      selectedAt: selectedAt ?? this.selectedAt,
      generatedAt: generatedAt ?? this.generatedAt,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      generationVersion: generationVersion ?? this.generationVersion,
    );
  }

/// Blueprint summary for carousel view
class CarouselBlueprint {
  final String id;
  final String careerName;
  final String? careerCategory;
  final double fitScore;
  final String difficultyLevel;
  final String confidenceLevel;
  final String status;
  final DateTime? selectedAt;
  final String? whyThisFits;
  final String? yourJourney;

  CarouselBlueprint({
    required this.id,
    required this.careerName,
    this.careerCategory,
    required this.fitScore,
    required this.difficultyLevel,
    required this.confidenceLevel,
    required this.status,
    this.selectedAt,
    this.whyThisFits,
    this.yourJourney,
  });

  bool get isSelected => status == 'selected';

  factory CarouselBlueprint.fromJson(Map<String, dynamic> json) {
    return CarouselBlueprint(
      id: json['id'] ?? '',
      careerName: json['career_name'] ?? '',
      careerCategory: json['career_category'],
      fitScore: (json['fit_score'] ?? 0).toDouble(),
      difficultyLevel: json['difficulty_level'] ?? 'medium',
      confidenceLevel: json['confidence_level'] ?? 'medium',
      status: json['status'] ?? 'generated',
      selectedAt: json['selected_at'] != null
          ? DateTime.parse(json['selected_at'])
          : null,
      whyThisFits: json['why_this_fits'],
      yourJourney: json['your_journey'],
    );
  }
}

/// Carousel response with 3 blueprints
class BlueprintCarouselResponse {
  final String assessmentAttemptId;
  final String userId;
  final List<CarouselBlueprint> blueprints;
  final DateTime completedAt;

  BlueprintCarouselResponse({
    required this.assessmentAttemptId,
    required this.userId,
    required this.blueprints,
    required this.completedAt,
  });

  factory BlueprintCarouselResponse.fromJson(Map<String, dynamic> json) {
    return BlueprintCarouselResponse(
      assessmentAttemptId: json['assessment_attempt_id'] ?? '',
      userId: json['user_id'] ?? '',
      blueprints: (json['blueprints'] as List?)
              ?.map((b) => CarouselBlueprint.fromJson(b))
              .toList() ??
          [],
      completedAt: DateTime.parse(json['completed_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

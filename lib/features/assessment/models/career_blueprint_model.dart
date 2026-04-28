import 'package:flutter/foundation.dart';

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
      items: List<String>.from(json['items'] ?? const []),
      icon: json['icon'],
      color: json['color'],
    );
  }
}

class BlueprintWarning {
  final String title;
  final String description;
  final String severity;

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

class BlueprintSection {
  final String id;
  final String title;
  final String? subtitle;
  final String description;
  final String sectionType;
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
      sectionType: json['section_type'] ?? json['icon'] ?? 'insight',
      content: (json['content'] as List?)
              ?.map((c) => BlueprintCardContent.fromJson(Map<String, dynamic>.from(c)))
              .toList() ??
          (json['content_cards'] as List?)
                  ?.map((c) => BlueprintCardContent.fromJson(Map<String, dynamic>.from(c)))
                  .toList() ??
              const [],
      warnings: (json['warnings'] as List?)
              ?.map((w) => BlueprintWarning.fromJson(Map<String, dynamic>.from(w)))
              .toList() ??
          const [],
      expanded: json['expanded'] ?? false,
      orderIndex: json['order_index'] ?? 0,
    );
  }
}

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
      year: json['year']?.toString() ?? '',
      minSalary: (json['min_salary'] ?? json['minSalary'] ?? 0) as int,
      medSalary: (json['med_salary'] ?? json['median_salary'] ?? json['medSalary'] ?? 0) as int,
      maxSalary: (json['max_salary'] ?? json['maxSalary'] ?? 0) as int,
      trendPercent: (json['trend_percent'] ?? json['trendPercent'] ?? 0).toDouble(),
    );
  }
}

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
      year: json['year']?.toString() ?? '',
      openPositions: (json['open_positions'] ?? json['openPositions'] ?? 0) as int,
      growthRate: (json['growth_rate'] ?? json['growthRate'] ?? 0).toDouble(),
    );
  }
}

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
      userLevel: (json['user_level'] ?? json['userLevel'] ?? 0).toDouble(),
      required: (json['required'] ?? 0).toDouble(),
      importance: (json['importance'] ?? 0).toDouble(),
    );
  }
}

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
              ?.map((d) => SalaryProjectionData.fromJson(Map<String, dynamic>.from(d)))
              .toList() ??
          const [],
      jobMarketDemand: (json['job_market_demand'] as List?)
              ?.map((d) => JobMarketPoint.fromJson(Map<String, dynamic>.from(d)))
              .toList() ??
          const [],
      skillAlignment: (json['skill_alignment'] as List?)
              ?.map((d) => SkillRadarData.fromJson(Map<String, dynamic>.from(d)))
              .toList() ??
          const [],
    );
  }
}

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
    final rawSections = json['sections'] ?? json['blueprint_data']?['sections'];
    final rawCharts = json['charts'] ?? json['chart_data'];

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
      sections: (rawSections as List?)
              ?.map((s) => BlueprintSection.fromJson(Map<String, dynamic>.from(s)))
              .toList() ??
          const [],
      charts: rawCharts != null ? ChartData.fromJson(Map<String, dynamic>.from(rawCharts)) : null,
      status: json['status'] ?? 'generated',
      selectionOrder: json['selection_order'],
      selectedAt: json['selected_at'] != null ? DateTime.tryParse(json['selected_at']) : null,
      generatedAt: DateTime.tryParse(json['generated_at'] ?? '') ?? DateTime.now(),
      lastViewedAt: json['last_viewed_at'] != null ? DateTime.tryParse(json['last_viewed_at']) : null,
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      generationVersion: json['generation_version'] ?? 1,
    );
  }

  CareerBlueprint copyWith({
    String? status,
  }) {
    return CareerBlueprint(
      id: id,
      userId: userId,
      assessmentAttemptId: assessmentAttemptId,
      careerId: careerId,
      careerName: careerName,
      careerCategory: careerCategory,
      fitScore: fitScore,
      difficultyLevel: difficultyLevel,
      confidenceLevel: confidenceLevel,
      sections: sections,
      charts: charts,
      status: status ?? this.status,
      selectionOrder: selectionOrder,
      selectedAt: selectedAt,
      generatedAt: generatedAt,
      lastViewedAt: lastViewedAt,
      updatedAt: updatedAt,
      generationVersion: generationVersion,
    );
  }
}

class CarouselBlueprint {
  final String id;
  final String? careerId;
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
    this.careerId,
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
      careerId: json['career_id']?.toString(),
      careerName: json['career_name'] ?? '',
      careerCategory: json['career_category'],
      fitScore: (json['fit_score'] ?? 0).toDouble(),
      difficultyLevel: json['difficulty_level'] ?? 'medium',
      confidenceLevel: json['confidence_level'] ?? 'medium',
      status: json['status'] ?? 'generated',
      selectedAt: json['selected_at'] != null ? DateTime.tryParse(json['selected_at']) : null,
      whyThisFits: json['why_this_fits'],
      yourJourney: json['your_journey'],
    );
  }
}

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
              ?.map((b) => CarouselBlueprint.fromJson(Map<String, dynamic>.from(b)))
              .toList() ??
          const [],
      completedAt: DateTime.tryParse(json['completed_at'] ?? '') ?? DateTime.now(),
    );
  }
}

void debugPrintBlueprint(CareerBlueprint blueprint) {
  debugPrint('Blueprint: ${blueprint.careerName} (${blueprint.fitScore})');
}

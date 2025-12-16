import 'package:equatable/equatable.dart';

class ProjectModel extends Equatable {
  final String id;
  final String userId;
  final String projectName;
  final String? description;
  final String? projectUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final List<String> technologies;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProjectModel({
    required this.id,
    required this.userId,
    required this.projectName,
    this.description,
    this.projectUrl,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.technologies = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      projectName: json['project_name'] as String,
      description: json['description'] as String?,
      projectUrl: json['project_url'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isCurrent: json['is_current'] as bool? ?? false,
      technologies: json['technologies'] != null
          ? (json['technologies'] as List).map((e) => e.toString()).toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'project_name': projectName,
      'description': description,
      'project_url': projectUrl,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_current': isCurrent,
      'technologies': technologies,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        projectName,
        description,
        projectUrl,
        startDate,
        endDate,
        isCurrent,
        technologies,
        createdAt,
        updatedAt,
      ];
}

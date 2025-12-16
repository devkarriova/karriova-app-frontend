import 'package:equatable/equatable.dart';

class ExperienceModel extends Equatable {
  final String id;
  final String userId;
  final String companyName;
  final String jobTitle;
  final String? employmentType;
  final String? location;
  final bool isCurrent;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExperienceModel({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.jobTitle,
    this.employmentType,
    this.location,
    this.isCurrent = false,
    required this.startDate,
    this.endDate,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      companyName: json['company_name'] as String,
      jobTitle: json['job_title'] as String,
      employmentType: json['employment_type'] as String?,
      location: json['location'] as String?,
      isCurrent: json['is_current'] as bool? ?? false,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      description: json['description'] as String?,
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
      'company_name': companyName,
      'job_title': jobTitle,
      'employment_type': employmentType,
      'location': location,
      'is_current': isCurrent,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        companyName,
        jobTitle,
        employmentType,
        location,
        isCurrent,
        startDate,
        endDate,
        description,
        createdAt,
        updatedAt,
      ];
}

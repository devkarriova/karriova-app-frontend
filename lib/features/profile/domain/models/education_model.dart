import 'package:equatable/equatable.dart';

class EducationModel extends Equatable {
  final String id;
  final String userId;
  final String schoolName;
  final String? degree;
  final String? fieldOfStudy;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String? grade;
  final String? activities;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EducationModel({
    required this.id,
    required this.userId,
    required this.schoolName,
    this.degree,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.grade,
    this.activities,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      schoolName: json['school_name'] as String,
      degree: json['degree'] as String?,
      fieldOfStudy: json['field_of_study'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isCurrent: json['is_current'] as bool? ?? false,
      grade: json['grade'] as String?,
      activities: json['activities'] as String?,
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
      'school_name': schoolName,
      'degree': degree,
      'field_of_study': fieldOfStudy,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_current': isCurrent,
      'grade': grade,
      'activities': activities,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        schoolName,
        degree,
        fieldOfStudy,
        startDate,
        endDate,
        isCurrent,
        grade,
        activities,
        description,
        createdAt,
        updatedAt,
      ];
}

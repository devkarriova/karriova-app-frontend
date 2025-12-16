import 'package:equatable/equatable.dart';

class SkillModel extends Equatable {
  final String id;
  final String userId;
  final String skillName;
  final String? proficiencyLevel;
  final int? yearsOfExperience;
  final int endorsedCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SkillModel({
    required this.id,
    required this.userId,
    required this.skillName,
    this.proficiencyLevel,
    this.yearsOfExperience,
    this.endorsedCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      skillName: json['skill_name'] as String,
      proficiencyLevel: json['proficiency_level'] as String?,
      yearsOfExperience: json['years_of_experience'] as int?,
      endorsedCount: json['endorsed_count'] as int? ?? 0,
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
      'skill_name': skillName,
      'proficiency_level': proficiencyLevel,
      'years_of_experience': yearsOfExperience,
      'endorsed_count': endorsedCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        skillName,
        proficiencyLevel,
        yearsOfExperience,
        endorsedCount,
        createdAt,
        updatedAt,
      ];
}

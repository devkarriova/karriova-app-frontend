import 'package:equatable/equatable.dart';

class AwardModel extends Equatable {
  final String id;
  final String userId;
  final String awardName;
  final String? issuingOrganization;
  final DateTime? issueDate;
  final String? description;
  final DateTime? createdAt;

  const AwardModel({
    required this.id,
    required this.userId,
    required this.awardName,
    this.issuingOrganization,
    this.issueDate,
    this.description,
    this.createdAt,
  });

  factory AwardModel.fromJson(Map<String, dynamic> json) {
    return AwardModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      awardName: json['award_name'] as String,
      issuingOrganization: json['issuing_organization'] as String?,
      issueDate: json['issue_date'] != null
          ? DateTime.parse(json['issue_date'] as String)
          : null,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'award_name': awardName,
      'issuing_organization': issuingOrganization,
      'issue_date': issueDate?.toIso8601String(),
      'description': description,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        awardName,
        issuingOrganization,
        issueDate,
        description,
        createdAt,
      ];
}

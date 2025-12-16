import 'package:equatable/equatable.dart';

class CertificationModel extends Equatable {
  final String id;
  final String userId;
  final String certificationName;
  final String issuingOrganization;
  final DateTime? issueDate;
  final DateTime? expirationDate;
  final String? credentialId;
  final String? credentialUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CertificationModel({
    required this.id,
    required this.userId,
    required this.certificationName,
    required this.issuingOrganization,
    this.issueDate,
    this.expirationDate,
    this.credentialId,
    this.credentialUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      certificationName: json['certification_name'] as String,
      issuingOrganization: json['issuing_organization'] as String,
      issueDate: json['issue_date'] != null
          ? DateTime.parse(json['issue_date'] as String)
          : null,
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'] as String)
          : null,
      credentialId: json['credential_id'] as String?,
      credentialUrl: json['credential_url'] as String?,
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
      'certification_name': certificationName,
      'issuing_organization': issuingOrganization,
      'issue_date': issueDate?.toIso8601String(),
      'expiration_date': expirationDate?.toIso8601String(),
      'credential_id': credentialId,
      'credential_url': credentialUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        certificationName,
        issuingOrganization,
        issueDate,
        expirationDate,
        credentialId,
        credentialUrl,
        createdAt,
        updatedAt,
      ];
}

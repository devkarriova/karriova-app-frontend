import 'package:equatable/equatable.dart';

/// Experience model matching backend structure
class Experience extends Equatable {
  final String title;
  final String company;
  final String companyId;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool current;
  final String description;

  const Experience({
    required this.title,
    required this.company,
    required this.companyId,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.current,
    required this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      title: json['Title'] as String,
      company: json['Company'] as String,
      companyId: json['CompanyID'] as String,
      location: json['Location'] as String,
      startDate: DateTime.parse(json['StartDate'] as String),
      endDate: json['EndDate'] != null ? DateTime.parse(json['EndDate'] as String) : null,
      current: json['Current'] as bool,
      description: json['Description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Company': company,
      'CompanyID': companyId,
      'Location': location,
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate?.toIso8601String(),
      'Current': current,
      'Description': description,
    };
  }

  @override
  List<Object?> get props => [title, company, companyId, location, startDate, endDate, current, description];
}

/// Education model matching backend structure
class Education extends Equatable {
  final String degree;
  final String institution;
  final DateTime startDate;
  final DateTime endDate;
  final String grade;
  final List<String> achievements;

  const Education({
    required this.degree,
    required this.institution,
    required this.startDate,
    required this.endDate,
    required this.grade,
    required this.achievements,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      degree: json['Degree'] as String,
      institution: json['Institution'] as String,
      startDate: DateTime.parse(json['StartDate'] as String),
      endDate: DateTime.parse(json['EndDate'] as String),
      grade: json['Grade'] as String,
      achievements: (json['Achievements'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Degree': degree,
      'Institution': institution,
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate.toIso8601String(),
      'Grade': grade,
      'Achievements': achievements,
    };
  }

  @override
  List<Object?> get props => [degree, institution, startDate, endDate, grade, achievements];
}

/// Certification model matching backend structure
class Certification extends Equatable {
  final String name;
  final String issuer;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String credentialUrl;

  const Certification({
    required this.name,
    required this.issuer,
    required this.issueDate,
    this.expiryDate,
    required this.credentialUrl,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      name: json['Name'] as String,
      issuer: json['Issuer'] as String,
      issueDate: DateTime.parse(json['IssueDate'] as String),
      expiryDate: json['ExpiryDate'] != null ? DateTime.parse(json['ExpiryDate'] as String) : null,
      credentialUrl: json['CredentialURL'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Issuer': issuer,
      'IssueDate': issueDate.toIso8601String(),
      'ExpiryDate': expiryDate?.toIso8601String(),
      'CredentialURL': credentialUrl,
    };
  }

  @override
  List<Object?> get props => [name, issuer, issueDate, expiryDate, credentialUrl];
}

/// Profile model matching backend PublicProfile structure
class ProfileModel extends Equatable {
  final String userId;
  final String bio;
  final String headline;
  final String location;
  final String website;
  final List<String> skills;
  final List<Experience> experience;
  final List<Education> education;
  final List<Certification> certifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.userId,
    required this.bio,
    required this.headline,
    required this.location,
    required this.website,
    required this.skills,
    required this.experience,
    required this.education,
    required this.certifications,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'] as String,
      bio: json['bio'] as String,
      headline: json['headline'] as String,
      location: json['location'] as String,
      website: json['website'] as String,
      skills: (json['skills'] as List<dynamic>).map((e) => e as String).toList(),
      experience: (json['experience'] as List<dynamic>)
          .map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList(),
      education: (json['education'] as List<dynamic>)
          .map((e) => Education.fromJson(e as Map<String, dynamic>))
          .toList(),
      certifications: (json['certifications'] as List<dynamic>)
          .map((e) => Certification.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'bio': bio,
      'headline': headline,
      'location': location,
      'website': website,
      'skills': skills,
      'experience': experience.map((e) => e.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
      'certifications': certifications.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        userId,
        bio,
        headline,
        location,
        website,
        skills,
        experience,
        education,
        certifications,
        createdAt,
        updatedAt,
      ];
}

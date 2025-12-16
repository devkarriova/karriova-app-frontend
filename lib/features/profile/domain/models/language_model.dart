import 'package:equatable/equatable.dart';

class LanguageModel extends Equatable {
  final String id;
  final String userId;
  final String languageName;
  final String proficiencyLevel;
  final DateTime? createdAt;

  const LanguageModel({
    required this.id,
    required this.userId,
    required this.languageName,
    required this.proficiencyLevel,
    this.createdAt,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      languageName: json['language_name'] as String,
      proficiencyLevel: json['proficiency_level'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'language_name': languageName,
      'proficiency_level': proficiencyLevel,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        languageName,
        proficiencyLevel,
        createdAt,
      ];
}

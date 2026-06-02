import 'package:karriova_app/core/config/app_config.dart';
import 'package:karriova_app/core/network/api_client.dart';

import 'legal_document_model.dart';

class LegalService {
  final ApiClient _apiClient;

  LegalService(this._apiClient);

  Future<List<LegalDocument>> getDocuments() async {
    final response = await _apiClient.get('/legal/documents');
    if (!response.isSuccess || response.data == null) {
      throw Exception(
          response.errorMessage ?? 'Failed to load legal documents');
    }
    final data = response.data as Map<String, dynamic>;
    final list = (data['documents'] as List?) ?? const [];
    return list
        .map((e) => LegalDocument.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LegalDocument> getDocument(String slug) async {
    final response = await _apiClient.get('/legal/documents/$slug');
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to load legal document');
    }
    return LegalDocument.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> acceptDocuments({
    required List<LegalDocument> documents,
    String context = 'in_app',
    String acceptedBy = 'user',
    String? guardianName,
    String? guardianPhone,
  }) async {
    final response = await _apiClient.post(
      '/legal/acceptance',
      requiresAuth: true,
      body: {
        'acceptance_context': context,
        'accepted_by': acceptedBy,
        if (guardianName != null) 'guardian_name': guardianName,
        if (guardianPhone != null) 'guardian_phone': guardianPhone,
        'documents': documents.map((d) => d.acceptancePayload()).toList(),
      },
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to record acceptance');
    }
  }

  static String absoluteDownloadUrl(String? downloadUrl) {
    if (downloadUrl == null || downloadUrl.isEmpty) return '';
    if (downloadUrl.startsWith('http')) return downloadUrl;
    final base = AppConfig.apiBaseUrl.replaceFirst('/api/v1', '');
    return '$base$downloadUrl';
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/assessment_models.dart';

/// Assessment remote data source interface
abstract class AssessmentRemoteDataSource {
  /// Get the active assessment with all sections, dimensions, questions, and options
  Future<AssessmentModel> getActiveAssessment();

  /// Submit assessment responses
  Future<AssessmentResultModel> submitAssessment(List<ResponseInput> responses);

  /// Get current user's assessment results
  Future<AssessmentResultModel> getMyResults();

  /// Download KIT report PDF (short or detailed)
  Future<QuestionTemplateModel> downloadKitReportPdf({
    String type = 'short',
    String? blueprintId,
  });

  /// Check if user has completed the assessment
  Future<bool> hasCompletedAssessment();

  // Admin methods
  Future<SectionModel> createSection(String name, String description, {int displayOrder = 0});
  Future<DimensionModel> createDimension(
    String sectionId,
    String name,
    String description, {
    String poleALabel = 'Low',
    String poleBLabel = 'High',
    int displayOrder = 0,
  });
  Future<QuestionModel> createQuestion(
    String dimensionId,
    String text,
    List<OptionInput> options, {
    String poleDirection = 'A',
    int displayOrder = 0,
  });
  Future<void> deleteSection(String sectionId);
  Future<void> deleteDimension(String dimensionId);
  Future<void> deleteQuestion(String questionId);

  // Update methods
  Future<SectionModel> updateSection(String sectionId, {String? name, String? description});
  Future<DimensionModel> updateDimension(
    String dimensionId, {
    String? name,
    String? description,
    String? poleALabel,
    String? poleBLabel,
  });

  // KIT bulk upload methods
  Future<QuestionTemplateModel> downloadQuestionTemplate(String sectionId);
  Future<BulkValidationResponseModel> validateBulkQuestions(
    String sectionId, {
    required List<int> fileBytes,
    required String fileName,
  });
  Future<BulkUploadResponseModel> bulkUploadQuestions(
    String sectionId, {
    required List<int> fileBytes,
    required String fileName,
  });
}

/// Input for creating question options
class OptionInput {
  final String text;
  final int score;

  OptionInput({required this.text, required this.score});

  Map<String, dynamic> toJson() => {'text': text, 'score': score};
}

/// Implementation of assessment remote data source
class AssessmentRemoteDataSourceImpl implements AssessmentRemoteDataSource {
  final ApiClient _apiClient;

  AssessmentRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<AssessmentModel> getActiveAssessment() async {
    final response = await _apiClient.get('/assessments/active', requiresAuth: true);

    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to load assessment');
    }

    final assessment = AssessmentModel.fromJson(response.data as Map<String, dynamic>);

    return assessment;
  }

  @override
  Future<AssessmentResultModel> submitAssessment(
      List<ResponseInput> responses) async {
    final response = await _apiClient.post(
      '/assessments/submit',
      requiresAuth: true,
      body: {
        'responses': responses.map((r) => r.toJson()).toList(),
      },
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to submit assessment');
    }
    return AssessmentResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AssessmentResultModel> getMyResults() async {
    final response = await _apiClient.get('/assessments/results', requiresAuth: true);
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to load results');
    }
    return AssessmentResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<QuestionTemplateModel> downloadKitReportPdf({
    String type = 'short',
    String? blueprintId,
  }) async {
    final reportType = type.toLowerCase().trim();
    if (reportType != 'short' && reportType != 'detailed') {
      throw Exception('Invalid report type. Use short or detailed.');
    }

    final token = _apiClient.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Unauthorized. Please login again.');
    }

    final params = <String, String>{'type': reportType};
    if (blueprintId != null && blueprintId.trim().isNotEmpty) {
      params['blueprint_id'] = blueprintId.trim();
    }
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/assessments/reports/kit/download')
        .replace(queryParameters: params);

    http.Response response;
    try {
      response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );
    } catch (e) {
      rethrow;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final disposition = response.headers['content-disposition'] ?? '';
      final fileName = _extractFilename(disposition) ?? 'KIT_${reportType}_Report.pdf';
      return QuestionTemplateModel(bytes: response.bodyBytes, fileName: fileName);
    }

    throw Exception(_extractApiError(response.body) ?? 'Failed to download KIT report PDF');
  }

  @override
  Future<bool> hasCompletedAssessment() async {
    final response = await _apiClient.get('/assessments/status', requiresAuth: true);
    if (!response.isSuccess) {
      return false;
    }
    final data = response.data as Map<String, dynamic>?;
    return data?['completed'] as bool? ?? false;
  }

  // Admin methods
  @override
  Future<SectionModel> createSection(String name, String description, {int displayOrder = 0}) async {
    final response = await _apiClient.post(
      '/admin/assessments/sections',
      requiresAuth: true,
      body: {
        'name': name,
        'description': description,
        'display_order': displayOrder,
        'is_active': true,
      },
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to create section');
    }
    return SectionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DimensionModel> createDimension(
    String sectionId,
    String name,
    String description, {
    String poleALabel = 'Low',
    String poleBLabel = 'High',
    int displayOrder = 0,
  }) async {
    final response = await _apiClient.post(
      '/admin/assessments/dimensions',
      requiresAuth: true,
      body: {
        'section_id': sectionId,
        'name': name,
        'description': description,
        'pole_a_label': poleALabel,
        'pole_b_label': poleBLabel,
        'display_order': displayOrder,
      },
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to create dimension');
    }
    return DimensionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<QuestionModel> createQuestion(
    String dimensionId,
    String text,
    List<OptionInput> options, {
    String poleDirection = 'A',
    int displayOrder = 0,
  }) async {
    // Add display_order to options
    final optionsWithOrder = options.asMap().entries.map((e) {
      return {
        'text': e.value.text,
        'score': e.value.score,
        'display_order': e.key,
      };
    }).toList();

    final response = await _apiClient.post(
      '/admin/assessments/questions',
      requiresAuth: true,
      body: {
        'dimension_id': dimensionId,
        'text': text,
        'pole_direction': poleDirection,
        'display_order': displayOrder,
        'is_active': true,
        'options': optionsWithOrder,
      },
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to create question');
    }
    return QuestionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSection(String sectionId) async {
    final response = await _apiClient.delete(
      '/admin/assessments/sections/$sectionId',
      requiresAuth: true,
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to delete section');
    }
  }

  @override
  Future<void> deleteDimension(String dimensionId) async {
    final response = await _apiClient.delete(
      '/admin/assessments/dimensions/$dimensionId',
      requiresAuth: true,
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to delete dimension');
    }
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    final response = await _apiClient.delete(
      '/admin/assessments/questions/$questionId',
      requiresAuth: true,
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to delete question');
    }
  }

  @override
  Future<SectionModel> updateSection(String sectionId, {String? name, String? description}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;

    final response = await _apiClient.put(
      '/admin/assessments/sections/$sectionId',
      requiresAuth: true,
      body: body,
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to update section');
    }
    return SectionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DimensionModel> updateDimension(
    String dimensionId, {
    String? name,
    String? description,
    String? poleALabel,
    String? poleBLabel,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (poleALabel != null) body['pole_a_label'] = poleALabel;
    if (poleBLabel != null) body['pole_b_label'] = poleBLabel;

    final response = await _apiClient.put(
      '/admin/assessments/dimensions/$dimensionId',
      requiresAuth: true,
      body: body,
    );
    if (!response.isSuccess) {
      throw Exception(response.errorMessage ?? 'Failed to update dimension');
    }
    return DimensionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<QuestionTemplateModel> downloadQuestionTemplate(String sectionId) async {
    final token = _apiClient.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Unauthorized. Please login again.');
    }

    final uri = Uri.parse('${AppConfig.apiBaseUrl}/admin/assessments/sections/$sectionId/questions/template');

    http.Response response;
    try {
      response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        },
      );
    } catch (e) {
      rethrow;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final disposition = response.headers['content-disposition'] ?? '';
      final fileName = _extractFilename(disposition) ?? 'KIT_Question_Template.xlsx';
      return QuestionTemplateModel(bytes: response.bodyBytes, fileName: fileName);
    }

    throw Exception(_extractApiError(response.body) ?? 'Failed to download template');
  }

  @override
  Future<BulkValidationResponseModel> validateBulkQuestions(
    String sectionId, {
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final response = await _sendBulkMultipart(
      sectionId: sectionId,
      endpoint: 'validate',
      fileBytes: fileBytes,
      fileName: fileName,
    );

    return BulkValidationResponseModel.fromJson(response);
  }

  @override
  Future<BulkUploadResponseModel> bulkUploadQuestions(
    String sectionId, {
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final response = await _sendBulkMultipart(
      sectionId: sectionId,
      endpoint: 'bulk',
      fileBytes: fileBytes,
      fileName: fileName,
    );

    return BulkUploadResponseModel.fromJson(response);
  }

  Future<Map<String, dynamic>> _sendBulkMultipart({
    required String sectionId,
    required String endpoint,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final token = _apiClient.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('Unauthorized. Please login again.');
    }

    final uri = Uri.parse('${AppConfig.apiBaseUrl}/admin/assessments/sections/$sectionId/questions/$endpoint');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ),
    );

    http.StreamedResponse streamed;
    try {
      streamed = await request.send();
    } catch (e) {
      rethrow;
    }

    final response = await http.Response.fromStream(streamed);

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['data'] as Map<String, dynamic>;
    }

    final message = (body['error']?['message'] as String?) ?? 'Bulk request failed';
    throw Exception(message);
  }

  String? _extractFilename(String contentDisposition) {
    if (contentDisposition.isEmpty) return null;

    final match = RegExp(r'filename="?([^";]+)"?').firstMatch(contentDisposition);
    return match?.group(1);
  }

  String? _extractApiError(String body) {
    if (body.isEmpty) return null;
    try {
      final parsed = jsonDecode(body) as Map<String, dynamic>;
      return parsed['error']?['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}

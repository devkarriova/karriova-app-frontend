import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:mime/mime.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/models/attachment_model.dart';

abstract class MediaRemoteDataSource {
  Future<AttachmentModel> uploadImage(String postId, File imageFile);
  Future<List<AttachmentModel>> uploadMultipleImages(String postId, List<File> imageFiles);
}

class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  final ApiClient apiClient;

  MediaRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AttachmentModel> uploadImage(String postId, File imageFile) async {
    try {
      // Create multipart request
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/media/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      final token = apiClient.accessToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add post_id field
      request.fields['post_id'] = postId;

      // Add file
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: http_parser.MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return AttachmentModel.fromJson(jsonData['data'] as Map<String, dynamic>);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['error']?['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<List<AttachmentModel>> uploadMultipleImages(String postId, List<File> imageFiles) async {
    try {
      // Create multipart request
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/v1/media/upload-multiple');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      final token = apiClient.accessToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add post_id field
      request.fields['post_id'] = postId;

      // Add files
      for (final imageFile in imageFiles) {
        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        final multipartFile = await http.MultipartFile.fromPath(
          'files',
          imageFile.path,
          contentType: http_parser.MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> attachmentsJson = jsonData['data'] as List<dynamic>;
        return attachmentsJson
            .map((json) => AttachmentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['error']?['message'] ?? 'Failed to upload images');
      }
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }
  }
}

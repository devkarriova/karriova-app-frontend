import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Callback type for token refresh
typedef TokenRefreshCallback = Future<bool> Function();

/// Callback type for logout on token expiration
typedef LogoutCallback = Future<void> Function();

/// API Client for making HTTP requests to the backend
class ApiClient {
  final http.Client _client;
  String? _accessToken;
  TokenRefreshCallback? _onTokenExpired;
  LogoutCallback? _onLogoutRequired;
  bool _isRefreshing = false;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Set the access token for authenticated requests
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  /// Get the current access token
  String? get accessToken => _accessToken;

  /// Set callback for token refresh
  void setTokenRefreshCallback(TokenRefreshCallback callback) {
    _onTokenExpired = callback;
  }

  /// Set callback for logout when token refresh fails
  void setLogoutCallback(LogoutCallback callback) {
    _onLogoutRequired = callback;
  }

  /// Build headers for requests
  Map<String, String> _buildHeaders({
    bool requiresAuth = false,
    Map<String, String>? additionalHeaders,
  }) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Build full URL from endpoint
  String _buildUrl(String endpoint) {
    return '${AppConfig.apiBaseUrl}$endpoint';
  }

  /// Generic GET request
  Future<ApiResponse> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse(_buildUrl(endpoint));
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _client
          .get(
            uri,
            headers: _buildHeaders(requiresAuth: requiresAuth),
          )
          .timeout(AppConfig.connectionTimeout);

      return await _handleResponseWithRetry(response, () => get(endpoint, requiresAuth: requiresAuth, queryParams: queryParams));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Generic POST request
  Future<ApiResponse> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(_buildUrl(endpoint)),
            headers: _buildHeaders(requiresAuth: requiresAuth),
            body: jsonEncode(body),
          )
          .timeout(AppConfig.connectionTimeout);

      return await _handleResponseWithRetry(response, () => post(endpoint, body: body, requiresAuth: requiresAuth));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Generic PUT request
  Future<ApiResponse> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse(_buildUrl(endpoint)),
            headers: _buildHeaders(requiresAuth: requiresAuth),
            body: jsonEncode(body),
          )
          .timeout(AppConfig.connectionTimeout);

      return await _handleResponseWithRetry(response, () => put(endpoint, body: body, requiresAuth: requiresAuth));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Generic DELETE request
  Future<ApiResponse> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(_buildUrl(endpoint)),
            headers: _buildHeaders(requiresAuth: requiresAuth),
          )
          .timeout(AppConfig.connectionTimeout);

      return await _handleResponseWithRetry(response, () => delete(endpoint, requiresAuth: requiresAuth));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Handle response with automatic token refresh on 401
  Future<ApiResponse> _handleResponseWithRetry(
    http.Response response,
    Future<ApiResponse> Function() retry,
  ) async {
    final apiResponse = _handleResponse(response);

    // If 401 Unauthorized, handle based on token state
    if (apiResponse.statusCode == 401) {
      // If no access token at all, logout immediately (shouldn't be here)
      if (_accessToken == null || _accessToken!.isEmpty) {
        if (_onLogoutRequired != null) {
          await _onLogoutRequired!();
        }
        return apiResponse;
      }

      // If we have a token but got 401, try to refresh it
      if (_onTokenExpired != null && !_isRefreshing) {
        _isRefreshing = true;
        try {
          final refreshed = await _onTokenExpired!();
          _isRefreshing = false;

          if (refreshed) {
            // Retry the original request with new token
            return await retry();
          } else {
            // Token refresh failed - logout user
            if (_onLogoutRequired != null) {
              await _onLogoutRequired!();
            }
          }
        } catch (e) {
          _isRefreshing = false;
          // Token refresh threw exception - logout user
          if (_onLogoutRequired != null) {
            await _onLogoutRequired!();
          }
        }
      }
    }

    return apiResponse;
  }

  /// Handle HTTP response
  ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse.success(
        data: body['data'],
        statusCode: statusCode,
      );
    } else {
      final errorMessage = body['error']?['message'] ?? 'Unknown error occurred';
      final errorCode = body['error']?['code'] ?? 'UNKNOWN_ERROR';

      return ApiResponse.error(
        message: errorMessage,
        code: errorCode,
        statusCode: statusCode,
      );
    }
  }

  /// Handle request errors
  ApiResponse _handleError(dynamic error) {
    String message;

    if (error is http.ClientException) {
      message = 'Network error. Please check your connection.';
    } else if (error.toString().contains('TimeoutException')) {
      message = 'Request timeout. Please try again.';
    } else {
      message = 'An unexpected error occurred.';
    }

    return ApiResponse.error(
      message: message,
      code: 'NETWORK_ERROR',
      statusCode: 0,
    );
  }

  /// Dispose the client
  void dispose() {
    _client.close();
  }
}

/// API Response wrapper
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? errorMessage;
  final String? errorCode;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.errorMessage,
    this.errorCode,
    required this.statusCode,
  });

  factory ApiResponse.success({
    dynamic data,
    required int statusCode,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required String message,
    required String code,
    required int statusCode,
  }) {
    return ApiResponse(
      success: false,
      errorMessage: message,
      errorCode: code,
      statusCode: statusCode,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
}

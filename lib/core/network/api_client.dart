import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Callback type for token refresh
typedef TokenRefreshCallback = Future<bool> Function();

/// Callback type for logout on token expiration
typedef LogoutCallback = Future<void> Function();

/// Callback type for fetching token from storage
typedef TokenProviderCallback = Future<String?> Function();

/// Rate limiter to prevent runaway API calls
class ApiRateLimiter {
  final int maxRequestsPerEndpoint;
  final Duration windowDuration;
  final Duration cooldownDuration;

  // Track requests per endpoint: endpoint -> list of timestamps
  final Map<String, List<DateTime>> _requestTimestamps = {};

  // Track endpoints in cooldown
  final Map<String, DateTime> _cooldownEndpoints = {};

  ApiRateLimiter({
    this.maxRequestsPerEndpoint = 10,
    this.windowDuration = const Duration(seconds: 5),
    this.cooldownDuration = const Duration(seconds: 10),
  });

  /// Check if request should be allowed
  /// Returns true if allowed, false if rate limited
  bool shouldAllowRequest(String endpoint) {
    final now = DateTime.now();

    // Check if endpoint is in cooldown
    if (_cooldownEndpoints.containsKey(endpoint)) {
      final cooldownEnd = _cooldownEndpoints[endpoint]!;
      if (now.isBefore(cooldownEnd)) {
        if (kDebugMode) {
          print(
              '🚫 [RateLimiter] Endpoint "$endpoint" is in cooldown until $cooldownEnd');
        }
        return false;
      } else {
        // Cooldown expired, remove it
        _cooldownEndpoints.remove(endpoint);
        _requestTimestamps.remove(endpoint);
      }
    }

    // Initialize tracking for this endpoint if needed
    _requestTimestamps[endpoint] ??= [];

    // Remove timestamps outside the window
    final windowStart = now.subtract(windowDuration);
    _requestTimestamps[endpoint]!.removeWhere((ts) => ts.isBefore(windowStart));

    // Check if we've exceeded the limit
    if (_requestTimestamps[endpoint]!.length >= maxRequestsPerEndpoint) {
      // Put endpoint in cooldown
      _cooldownEndpoints[endpoint] = now.add(cooldownDuration);
      if (kDebugMode) {
        print('⚠️ [RateLimiter] ALERT: Endpoint "$endpoint" hit rate limit '
            '(${_requestTimestamps[endpoint]!.length} requests in ${windowDuration.inSeconds}s). '
            'Entering ${cooldownDuration.inSeconds}s cooldown.');
      }
      return false;
    }

    // Record this request
    _requestTimestamps[endpoint]!.add(now);
    return true;
  }

  /// Get current request count for an endpoint (for debugging)
  int getRequestCount(String endpoint) {
    final now = DateTime.now();
    final windowStart = now.subtract(windowDuration);
    final timestamps = _requestTimestamps[endpoint] ?? [];
    return timestamps.where((ts) => ts.isAfter(windowStart)).length;
  }

  /// Check if endpoint is in cooldown
  bool isInCooldown(String endpoint) {
    final cooldownEnd = _cooldownEndpoints[endpoint];
    if (cooldownEnd == null) return false;
    return DateTime.now().isBefore(cooldownEnd);
  }

  /// Reset rate limiter (useful for testing or logout)
  void reset() {
    _requestTimestamps.clear();
    _cooldownEndpoints.clear();
  }

  /// Force reset a specific endpoint (e.g., after user action)
  void resetEndpoint(String endpoint) {
    _requestTimestamps.remove(endpoint);
    _cooldownEndpoints.remove(endpoint);
  }
}

/// API Client for making HTTP requests to the backend
class ApiClient {
  final http.Client _client;
  String? _accessToken;
  TokenRefreshCallback? _onTokenExpired;
  LogoutCallback? _onLogoutRequired;
  TokenProviderCallback? _tokenProvider;
  bool _isRefreshing = false;
  /// Completer shared by all callers queued behind an in-progress token refresh.
  Completer<bool>? _refreshCompleter;

  /// Rate limiter to prevent runaway API calls
  final ApiRateLimiter _rateLimiter;

  ApiClient({
    http.Client? client,
    ApiRateLimiter? rateLimiter,
  })  : _client = client ?? http.Client(),
        _rateLimiter = rateLimiter ?? ApiRateLimiter();

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

  /// Set callback for fetching token from storage (fallback when in-memory token is null)
  void setTokenProvider(TokenProviderCallback callback) {
    _tokenProvider = callback;
  }

  /// Get the access token, fetching from storage if in-memory is null
  Future<String?> _getAccessToken() async {
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      return _accessToken;
    }
    // Fallback to storage if in-memory token is null
    if (_tokenProvider != null) {
      if (kDebugMode) {
        print(
            '🔑 [ApiClient] In-memory token is null, fetching from storage...');
      }
      final token = await _tokenProvider!();
      if (token != null && token.isNotEmpty) {
        _accessToken = token; // Cache it in memory
        if (kDebugMode) {
          print('🔑 [ApiClient] Token loaded from storage successfully');
        }
        return token;
      }
      if (kDebugMode) {
        print('⚠️ [ApiClient] No token found in storage either');
      }
    }
    return null;
  }

  /// Build headers for requests (async to support token fetching)
  Future<Map<String, String>> _buildHeadersAsync({
    bool requiresAuth = false,
    Map<String, String>? additionalHeaders,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
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

  /// Check rate limit before making a request
  ApiResponse? _checkRateLimit(String endpoint) {
    if (!_rateLimiter.shouldAllowRequest(endpoint)) {
      return ApiResponse.error(
        message: 'Too many requests. Please wait a moment.',
        code: 'RATE_LIMITED',
        statusCode: 429,
      );
    }
    return null;
  }

  /// Reset rate limit for an endpoint (call after user-initiated actions)
  void resetRateLimitFor(String endpoint) {
    _rateLimiter.resetEndpoint(endpoint);
  }

  /// Reset all rate limits (call on logout)
  void resetAllRateLimits() {
    _rateLimiter.reset();
  }

  /// Generic GET request
  Future<ApiResponse> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? queryParams,
  }) async {
    // Check rate limit
    final rateLimitResponse = _checkRateLimit(endpoint);
    if (rateLimitResponse != null) return rateLimitResponse;

    try {
      var uri = Uri.parse(_buildUrl(endpoint));
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _buildHeadersAsync(requiresAuth: requiresAuth);
      final response = await _client
          .get(
            uri,
            headers: headers,
          )
          .timeout(AppConfig.connectionTimeout);

      return await _handleResponseWithRetry(
          response,
          () => get(endpoint,
              requiresAuth: requiresAuth, queryParams: queryParams));
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
    // Check rate limit
    final rateLimitResponse = _checkRateLimit(endpoint);
    if (rateLimitResponse != null) return rateLimitResponse;

    try {
      final headers = await _buildHeadersAsync(requiresAuth: requiresAuth);
      final response = await _client
          .post(
            Uri.parse(_buildUrl(endpoint)),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(AppConfig.connectionTimeout);

      return await _handleResponseWithRetry(response,
          () => post(endpoint, body: body, requiresAuth: requiresAuth));
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
    // Check rate limit
    final rateLimitResponse = _checkRateLimit(endpoint);
    if (rateLimitResponse != null) return rateLimitResponse;

    try {
      final headers = await _buildHeadersAsync(requiresAuth: requiresAuth);
      final response = await _client
          .put(
            Uri.parse(_buildUrl(endpoint)),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(AppConfig.connectionTimeout);

      return await _handleResponseWithRetry(response,
          () => put(endpoint, body: body, requiresAuth: requiresAuth));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Generic DELETE request
  Future<ApiResponse> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    // Check rate limit
    final rateLimitResponse = _checkRateLimit(endpoint);
    if (rateLimitResponse != null) return rateLimitResponse;

    try {
      final headers = await _buildHeadersAsync(requiresAuth: requiresAuth);
      final response = await _client
          .delete(
            Uri.parse(_buildUrl(endpoint)),
            headers: headers,
          )
          .timeout(AppConfig.connectionTimeout);

      return await _handleResponseWithRetry(
          response, () => delete(endpoint, requiresAuth: requiresAuth));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Generic PATCH request
  Future<ApiResponse> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    // Check rate limit
    final rateLimitResponse = _checkRateLimit(endpoint);
    if (rateLimitResponse != null) return rateLimitResponse;

    try {
      final headers = await _buildHeadersAsync(requiresAuth: requiresAuth);
      final response = await _client
          .patch(
            Uri.parse(_buildUrl(endpoint)),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(AppConfig.connectionTimeout);

      return await _handleResponseWithRetry(response,
          () => patch(endpoint, body: body, requiresAuth: requiresAuth));
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

    // If 401 Unauthorized, handle token refresh with queuing so concurrent
    // requests don't each trigger their own refresh — they all wait for one.
    if (apiResponse.statusCode == 401) {
      // No token at all — logout immediately.
      if (_accessToken == null || _accessToken!.isEmpty) {
        if (_onLogoutRequired != null) {
          await _onLogoutRequired!();
        }
        return apiResponse;
      }

      if (_onTokenExpired == null) {
        return apiResponse;
      }

      if (_isRefreshing) {
        // A refresh is already in flight — wait for it, then retry.
        final refreshed = await _refreshCompleter!.future;
        if (refreshed) {
          return await retry();
        }
        return apiResponse;
      }

      // We are the first — kick off the refresh.
      _isRefreshing = true;
      _refreshCompleter = Completer<bool>();
      try {
        final refreshed = await _onTokenExpired!();
        _refreshCompleter!.complete(refreshed);
        _isRefreshing = false;
        _refreshCompleter = null;

        if (refreshed) {
          return await retry();
        } else {
          if (_onLogoutRequired != null) {
            await _onLogoutRequired!();
          }
        }
      } catch (e) {
        _refreshCompleter!.complete(false);
        _isRefreshing = false;
        _refreshCompleter = null;
        if (_onLogoutRequired != null) {
          await _onLogoutRequired!();
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
      final errorMessage =
          body['error']?['message'] ?? 'Unknown error occurred';
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

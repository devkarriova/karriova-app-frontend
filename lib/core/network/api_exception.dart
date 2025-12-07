/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  ApiException({
    required this.message,
    required this.code,
    this.statusCode = 0,
  });

  @override
  String toString() => message;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;
  bool get isValidationError => code == 'VALIDATION_ERROR';
}

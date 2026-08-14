/// Structured backend error payload from the API envelope.
class ApiError {
  const ApiError({
    required this.code,
    required this.message,
    this.details,
    this.requestId,
  });

  final String code;
  final String message;
  final Map<String, dynamic>? details;
  final String? requestId;

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final detailsRaw = json['details'];
    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? 'Unknown error',
      details: detailsRaw is Map<String, dynamic>
          ? detailsRaw
          : detailsRaw is Map
              ? Map<String, dynamic>.from(detailsRaw)
              : null,
      requestId: json['requestId'] as String?,
    );
  }

  @override
  String toString() =>
      'ApiError(code: $code, message: $message, requestId: $requestId)';
}

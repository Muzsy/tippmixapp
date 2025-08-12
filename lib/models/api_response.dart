enum ApiErrorType { none, unauthorized, rateLimit, network, empty, unknown }

class ApiResponse<T> {
  final T? data;
  final ApiErrorType errorType;
  final String? errorMessage;
  final bool rateLimitWarning;

  const ApiResponse({
    this.data,
    this.errorType = ApiErrorType.none,
    this.errorMessage,
    this.rateLimitWarning = false,
  });
}

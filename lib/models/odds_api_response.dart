/// API-válasz objektum: adat és opcionális hiba.
enum ApiErrorType {
  none,
  unauthorized,
  rateLimit,
  network,
  empty,
  unknown,
}

class OddsApiResponse<T> {
  final T? data;
  final ApiErrorType errorType;
  final String? errorMessage;
  final bool rateLimitWarning;

  OddsApiResponse({
    this.data,
    this.errorType = ApiErrorType.none,
    this.errorMessage,
    this.rateLimitWarning = false,
  });
}

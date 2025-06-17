import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/odds_event.dart';
import '../models/odds_api_response.dart';

class OddsApiService {
  static final String _baseUrl = 'https://api.the-odds-api.com/v4/sports';

  Future<OddsApiResponse<List<OddsEvent>>> getOdds({
    required String sport,
    String? league,        // később: szűrés ligára is, ha támogatott
    DateTime? from,        // később: időintervallum
    DateTime? to,
  }) async {
    final String? apiKey = dotenv.env['ODDS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return OddsApiResponse(
        data: null,
        errorType: ApiErrorType.unauthorized,
        errorMessage: 'api_error_key',
      );
    }

    try {
      String url = '$_baseUrl/$sport/odds/?apiKey=$apiKey';
      if (league != null && league.isNotEmpty) {
        url += '&regions=$league';
      }
      if (from != null) {
        url += '&dateFrom=${from.toIso8601String()}';
      }
      if (to != null) {
        url += '&dateTo=${to.toIso8601String()}';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 429) {
        return OddsApiResponse(
          data: null,
          errorType: ApiErrorType.rateLimit,
          errorMessage: 'api_error_limit',
          rateLimitWarning: true,
        );
      }

      if (response.statusCode == 401) {
        return OddsApiResponse(
          data: null,
          errorType: ApiErrorType.unauthorized,
          errorMessage: 'api_error_key',
        );
      }

      if (response.statusCode != 200) {
        return OddsApiResponse(
          data: null,
          errorType: ApiErrorType.unknown,
          errorMessage: 'api_error_unknown',
        );
      }

      final jsonBody = jsonDecode(response.body);
      if (jsonBody == null || jsonBody.isEmpty) {
        return OddsApiResponse(
          data: null,
          errorType: ApiErrorType.empty,
          errorMessage: 'api_error_empty',
        );
      }

      final events = (jsonBody as List)
          .map((e) => OddsEvent.fromJson(e))
          .toList();

      bool quotaWarning = false;
      if (response.headers.containsKey('x-requests-remaining')) {
        final quota = int.tryParse(response.headers['x-requests-remaining']!);
        if (quota != null && quota < 5) {
          quotaWarning = true;
        }
      }

      return OddsApiResponse(
        data: events,
        errorType: ApiErrorType.none,
        errorMessage: null,
        rateLimitWarning: quotaWarning,
      );
    } on http.ClientException catch (_) {
      return OddsApiResponse(
        data: null,
        errorType: ApiErrorType.network,
        errorMessage: 'api_error_network',
      );
    } catch (_) {
      return OddsApiResponse(
        data: null,
        errorType: ApiErrorType.unknown,
        errorMessage: 'api_error_unknown',
      );
    }
  }
}

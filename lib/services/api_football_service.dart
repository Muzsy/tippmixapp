import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/odds_event.dart';

class ApiFootballService {
  static const String _baseUrl = 'https://v3.football.api-sports.io';
  final http.Client _client;

  ApiFootballService([http.Client? client]) : _client = client ?? http.Client();

  Future<ApiResponse<List<OddsEvent>>> getOdds({
    required String sport,
    String? league,
    DateTime? from,
    DateTime? to,
  }) async {
    final String? apiKey = dotenv.env['API_FOOTBALL_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return const ApiResponse(
        data: null,
        errorType: ApiErrorType.unauthorized,
        errorMessage: 'api_error_key',
      );
    }

    try {
      var url = '$_baseUrl/fixtures?';
      if (league != null) {
        url += 'league=$league&';
      }
      if (from != null) {
        url += 'from=${from.toIso8601String()}&';
      }
      if (to != null) {
        url += 'to=${to.toIso8601String()}&';
      }
      url += 'date=${DateTime.now().toIso8601String().split('T').first}';

      final response = await _client
          .get(Uri.parse(url), headers: {'x-apisports-key': apiKey})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 429) {
        return const ApiResponse(
          data: null,
          errorType: ApiErrorType.rateLimit,
          errorMessage: 'api_error_limit',
          rateLimitWarning: true,
        );
      }

      if (response.statusCode == 401) {
        return const ApiResponse(
          data: null,
          errorType: ApiErrorType.unauthorized,
          errorMessage: 'api_error_key',
        );
      }

      if (response.statusCode != 200) {
        return const ApiResponse(
          data: null,
          errorType: ApiErrorType.unknown,
          errorMessage: 'api_error_unknown',
        );
      }

      final body = jsonDecode(response.body);
      final fixtures = (body['response'] as List?) ?? [];
      if (fixtures.isEmpty) {
        return const ApiResponse(
          data: null,
          errorType: ApiErrorType.empty,
          errorMessage: 'api_error_empty',
        );
      }

      final events = fixtures
          .map((f) => _mapFixtureToOddsEvent(Map<String, dynamic>.from(f)))
          .toList();

      return ApiResponse(data: events);
    } on http.ClientException {
      return const ApiResponse(
        data: null,
        errorType: ApiErrorType.network,
        errorMessage: 'api_error_network',
      );
    } catch (_) {
      return const ApiResponse(
        data: null,
        errorType: ApiErrorType.unknown,
        errorMessage: 'api_error_unknown',
      );
    }
  }

  OddsEvent _mapFixtureToOddsEvent(Map<String, dynamic> json) {
    final fixture = Map<String, dynamic>.from(json['fixture'] as Map);
    final teams = Map<String, dynamic>.from(json['teams'] as Map);
    return OddsEvent(
      id: fixture['id'].toString(),
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: (teams['home'] as Map)['name'] as String,
      awayTeam: (teams['away'] as Map)['name'] as String,
      commenceTime: DateTime.parse(fixture['date'] as String),
      bookmakers: const [],
    );
  }
}

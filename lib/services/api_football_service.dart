import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/odds_bookmaker.dart';
import '../models/odds_event.dart';
import '../models/odds_market.dart';
import '../models/odds_outcome.dart';

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
      var url = '$_baseUrl/odds?date='
          '${DateTime.now().toIso8601String().split('T').first}';
      if (league != null) {
        url += '&league=$league';
      }

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
      final odds = (body['response'] as List?) ?? [];
      if (odds.isEmpty) {
        return const ApiResponse(
          data: null,
          errorType: ApiErrorType.empty,
          errorMessage: 'api_error_empty',
        );
      }

      final events = odds
          .map((o) => _mapOddsToEvent(Map<String, dynamic>.from(o)))
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

  OddsEvent _mapOddsToEvent(Map<String, dynamic> json) {
    final fixture = Map<String, dynamic>.from(json['fixture'] as Map);
    final league = Map<String, dynamic>.from(json['league'] as Map);
    final teams = Map<String, dynamic>.from(json['teams'] as Map);
    final homeTeam = (teams['home'] as Map)['name'] as String;
    final awayTeam = (teams['away'] as Map)['name'] as String;
    final bookmakers = _mapOddsBookmakers(
      (json['bookmakers'] as List?) ?? [],
      homeTeam,
      awayTeam,
    );
    return OddsEvent(
      id: fixture['id'].toString(),
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      countryName: league['country'] as String? ?? '',
      leagueName: league['name'] as String? ?? '',
      commenceTime: DateTime.parse(fixture['date'] as String),
      bookmakers: bookmakers,
    );
  }

  String? _betNameToMarketKey(String name) {
    if (name == 'Match Winner') return 'h2h';
    return null;
  }

  List<OddsBookmaker> _mapOddsBookmakers(
    List<dynamic> json,
    String homeTeam,
    String awayTeam,
  ) {
    return json.map<OddsBookmaker>((b) {
      final bets = (b['bets'] as List?) ?? [];
      final markets = bets
          .map<OddsMarket?>((bet) {
            final key = _betNameToMarketKey(bet['name'] as String);
            if (key == null) return null;
            final values = (bet['values'] as List?) ?? [];
            final outcomes = _mapH2HOutcomes(values, homeTeam, awayTeam);
            return OddsMarket(key: key, outcomes: outcomes);
          })
          .whereType<OddsMarket>()
          .toList();
      return OddsBookmaker(
        key: b['id'].toString(),
        title: b['name'] as String,
        markets: markets,
      );
    }).where((bm) => bm.markets.isNotEmpty).toList();
  }

  List<OddsOutcome> _mapH2HOutcomes(
    List<dynamic> values,
    String homeTeam,
    String awayTeam,
  ) {
    return values.map((v) {
      final label = v['value'] as String;
      final name = label == 'Home'
          ? homeTeam
          : label == 'Away'
              ? awayTeam
              : 'Draw';
      final price = double.tryParse(v['odd'].toString()) ?? 0.0;
      return OddsOutcome(name: name, price: price);
    }).toList();
  }

  Future<Map<String, dynamic>> getOddsForFixture(String fixtureId) async {
    // TODO: implement API call for a single fixture odds lookup
    return {};
  }
}

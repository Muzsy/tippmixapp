import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/odds_event.dart';
import '../models/odds_market.dart';
import 'market_mapping.dart';

class ApiFootballService {
  static const String _baseUrl = 'https://v3.football.api-sports.io';
  static const int defaultBookmakerId = 8; // Bet365
  static const _h2hTtl = Duration(seconds: 60);
  final Map<int, _CachedH2H> _h2hCache = {};
  final http.Client _client;

  ApiFootballService([http.Client? client]) : _client = client ?? http.Client();

  Future<ApiResponse<List<OddsEvent>>> getOdds({
    required String sport,
    String? country,
    String? league,
    DateTime? date,
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
      final datePart = (date ?? DateTime.now())
          .toIso8601String()
          .split('T')
          .first;
      var url = '$_baseUrl/fixtures?date=$datePart';
      // ország/league paramétereket nem küldünk – kliensoldali szűrés

      Future<http.Response> attempt() => _client
          .get(Uri.parse(url), headers: {'x-apisports-key': apiKey})
          .timeout(const Duration(seconds: 10));

      http.Response response;
      try {
        response = await attempt();
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 200));
        response = await attempt();
      }

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

      // H2H a kártyán töltődik, 60s cache
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
    final league = Map<String, dynamic>.from(json['league'] as Map);
    final teams = Map<String, dynamic>.from(json['teams'] as Map);
    final home = Map<String, dynamic>.from(teams['home'] as Map);
    final away = Map<String, dynamic>.from(teams['away'] as Map);
    return OddsEvent(
      id: fixture['id'].toString(),
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: home['name'] as String,
      awayTeam: away['name'] as String,
      season: (league['season'] as int?),
      countryName: league['country'] as String?,
      leagueName: league['name'] as String?,
      leagueLogoUrl: league['logo'] as String?,
      homeLogoUrl: home['logo'] as String?,
      awayLogoUrl: away['logo'] as String?,
      commenceTime: DateTime.parse(fixture['date'] as String),
      fetchedAt: DateTime.now().toUtc(),
      bookmakers: const [],
    );
  }

  Future<Map<String, dynamic>> getOddsForFixture(
    String fixtureId, {
    int? season,
    bool includeBet1 = true,
  }) async {
    final apiKey = dotenv.env['API_FOOTBALL_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Missing API_FOOTBALL_KEY');
    }
    final seasonPart = season != null ? '&season=$season' : '';
    final betPart = includeBet1 ? '&bet=1' : '';
    final url = '$_baseUrl/odds?fixture=$fixtureId$seasonPart$betPart';

    Future<http.Response> attempt() => _client
        .get(Uri.parse(url), headers: {'x-apisports-key': apiKey})
        .timeout(const Duration(seconds: 10));

    http.Response res;
    try {
      res = await attempt();
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 200));
      res = await attempt();
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body;
    }
    return {};
  }

  Future<OddsMarket?> getH2HForFixture(int fixtureId, {int? season}) {
    if (fixtureId <= 0) return Future.value(null);
    final now = DateTime.now();
    final cached = _h2hCache[fixtureId];
    if (cached != null && now.isBefore(cached.until)) {
      return cached.f;
    }
    final future = _fetchH2HForFixture(fixtureId, season: season);
    _h2hCache[fixtureId] = _CachedH2H(future, now.add(_h2hTtl));
    return future;
  }

  Future<OddsMarket?> _fetchH2HForFixture(int fixtureId, {int? season}) async {
    final json1 = await getOddsForFixture(
      fixtureId.toString(),
      season: season,
      includeBet1: true,
    );
    var h2h = MarketMapping.h2hFromApi(
      json1,
      preferredBookmakerId: defaultBookmakerId,
    );
    if (h2h != null) return h2h;
    final json2 = await getOddsForFixture(
      fixtureId.toString(),
      season: season,
      includeBet1: false,
    );
    return MarketMapping.h2hFromApi(
      json2,
      preferredBookmakerId: defaultBookmakerId,
    );
  }

  // Segédfüggvények – a saját modellekből/gyűjteményből adódnak vissza a nevek
  String? homeTeamNameFor(int fixtureId) {
    /* TODO: implement */
    return null;
  }

  String? awayTeamNameFor(int fixtureId) {
    /* TODO: implement */
    return null;
  }
}

class _CachedH2H {
  final Future<OddsMarket?> f;
  final DateTime until;

  _CachedH2H(this.f, this.until);
}

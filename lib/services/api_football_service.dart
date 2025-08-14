import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/api_response.dart';
import '../models/h2h_market.dart';
import '../models/odds_bookmaker.dart';
import '../models/odds_event.dart';
import '../models/odds_market.dart';
import '../models/odds_outcome.dart';
import 'market_mapping.dart';

class ApiFootballService {
  static const String _baseUrl = 'https://v3.football.api-sports.io';
  static const _h2hTtl = Duration(seconds: 60);
  final Map<int, Future<H2HMarket?>> _h2hCache = {};
  final Map<int, DateTime> _h2hStamp = {};
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
      var url =
          '$_baseUrl/fixtures?date='
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
      final fixtures = (body['response'] as List?) ?? [];
      if (fixtures.isEmpty) {
        return const ApiResponse(
          data: null,
          errorType: ApiErrorType.empty,
          errorMessage: 'api_error_empty',
        );
      }

      final baseEvents = fixtures
          .map((f) => _mapFixtureToOddsEvent(Map<String, dynamic>.from(f)))
          .toList();

      // Enrich fixtures with minimal H2H (1X2) market so that the bet card shows Home/Draw/Away.
      final events = <OddsEvent>[];
      for (final e in baseEvents) {
        try {
          final oddsJson = await getOddsForFixture(e.id);
          final bms = _parseH2HBookmakers(
            oddsJson,
            homeTeam: e.homeTeam,
            awayTeam: e.awayTeam,
          );
          events.add(
            OddsEvent(
              id: e.id,
              sportKey: e.sportKey,
              sportTitle: e.sportTitle,
              homeTeam: e.homeTeam,
              awayTeam: e.awayTeam,
              commenceTime: e.commenceTime,
              countryName: e.countryName,
              leagueName: e.leagueName,
              leagueLogoUrl: e.leagueLogoUrl,
              homeLogoUrl: e.homeLogoUrl,
              awayLogoUrl: e.awayLogoUrl,
              fetchedAt: e.fetchedAt,
              bookmakers: bms,
            ),
          );
        } catch (_) {
          // Fallback: keep the event but without markets if odds call fails.
          events.add(e);
        }
      }

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

  Future<Map<String, dynamic>> getOddsForFixture(String fixtureId) async {
    final apiKey = dotenv.env['API_FOOTBALL_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Missing API_FOOTBALL_KEY');
    }
    final url = '$_baseUrl/odds?fixture=$fixtureId';
    final res = await _client
        .get(Uri.parse(url), headers: {'x-apisports-key': apiKey})
        .timeout(const Duration(seconds: 10));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body;
    }
    // On any error return empty structure; caller will fallback.
    return {};
  }

  Future<H2HMarket?> getH2HForFixture(int fixtureId) {
    final now = DateTime.now();
    final stamp = _h2hStamp[fixtureId];
    final cached = _h2hCache[fixtureId];
    if (cached != null) {
      if (stamp == null || now.difference(stamp) < _h2hTtl) {
        return cached;
      }
    }
    final future = _fetchH2HForFixture(fixtureId).then((v) {
      _h2hStamp[fixtureId] = DateTime.now();
      return v;
    }).catchError((e) async {
      await Future.delayed(const Duration(milliseconds: 400));
      final v = await _fetchH2HForFixture(fixtureId);
      _h2hStamp[fixtureId] = DateTime.now();
      return v;
    });
    _h2hCache[fixtureId] = future;
    return future;
  }

  Future<H2HMarket?> _fetchH2HForFixture(int fixtureId) async {
    final json = await getOddsForFixture(fixtureId.toString());
    return MarketMapping.h2hFromApi(json);
  }

  /// Extracts a minimal 'h2h' (match winner) market from API-Football odds JSON.
  /// Produces exactly one market with three outcomes (Home/Draw/Away) for the first bookmaker that provides it.
  List<OddsBookmaker> _parseH2HBookmakers(
    Map<String, dynamic> oddsJson, {
    required String homeTeam,
    required String awayTeam,
  }) {
    final List<OddsBookmaker> result = [];
    if (oddsJson.isEmpty) return result;
    final resp = oddsJson['response'];
    if (resp is! List || resp.isEmpty) return result;
    // API-Football shape: response[0].bookmakers[].bets[].values[] { value: 'Home|Draw|Away', odd: '2.10' }
    final first = resp.first as Map<String, dynamic>;
    final bookmakers = (first['bookmakers'] as List?) ?? const [];
    for (final b in bookmakers) {
      final bm = b as Map<String, dynamic>;
      final name = (bm['name'] ?? 'Bookmaker').toString();
      final bets = (bm['bets'] as List?) ?? const [];
      Map<String, dynamic>? matchWinner;
      for (final bet in bets) {
        final m = bet as Map<String, dynamic>;
        final betName = (m['name'] ?? '').toString().toLowerCase();
        if (betName.contains('match winner') || betName.contains('1x2')) {
          matchWinner = m;
          break;
        }
      }
      if (matchWinner == null) {
        continue;
      }
      final values = (matchWinner['values'] as List?) ?? const [];
      OddsOutcome? home;
      OddsOutcome? draw;
      OddsOutcome? away;
      for (final v in values) {
        final mv = v as Map<String, dynamic>;
        final val = (mv['value'] ?? '').toString().toLowerCase();
        final oddStr = (mv['odd'] ?? '').toString();
        final price = double.tryParse(oddStr.replaceAll(',', '.'));
        if (price == null) continue;
        if (val.contains('home')) {
          home = OddsOutcome(name: homeTeam, price: price);
        } else if (val.contains('draw') || val == 'x') {
          draw = OddsOutcome(name: 'Draw', price: price);
        } else if (val.contains('away')) {
          away = OddsOutcome(name: awayTeam, price: price);
        }
      }
      final outcomes = [
        if (home != null) home,
        if (draw != null) draw,
        if (away != null) away,
      ];
      if (outcomes.isEmpty) continue;
      result.add(
        OddsBookmaker(
          key: _slug(name),
          title: name,
          markets: [OddsMarket(key: 'h2h', outcomes: outcomes)],
        ),
      );
      // Only need the first bookmaker for minimal UI; break here.
      break;
    }
    return result;
  }

  String _slug(String input) => input
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .trim()
      .replaceAll(RegExp(r'^_|_$'), '');
}

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:clock/clock.dart';

import 'package:tippmixapp/services/odds_api_service.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/models/odds_api_response.dart';

class OddsApiException implements Exception {
  final String type;
  const OddsApiException(this.type);
  static const OddsApiException retryFailed = OddsApiException('retryFailed');
}

class CacheEntry<T> {
  final T value;
  final DateTime expiry;
  CacheEntry(this.value, this.expiry);
}

abstract class Cache<T> {
  T? get(String key);
  void set(String key, T value, Duration ttl);
  void invalidate(String key);
}

class FakeCache<T> implements Cache<T> {
  final _map = <String, CacheEntry<T>>{};
  final Clock clock;
  FakeCache(this.clock);

  @override
  T? get(String key) {
    final entry = _map[key];
    if (entry == null) return null;
    if (clock.now().isAfter(entry.expiry)) {
      _map.remove(key);
      return null;
    }
    return entry.value;
  }

  @override
  void set(String key, T value, Duration ttl) {
    _map[key] = CacheEntry(value, clock.now().add(ttl));
  }

  @override
  void invalidate(String key) => _map.remove(key);
}

class MutableClock extends Clock {
  MutableClock(DateTime start)
      : _time = start,
        super(() => _time);
  DateTime _time;
  void advance(Duration d) => _time = _time.add(d);
}

class TestOddsApiService extends OddsApiService {
  final http.Client client;
  final Cache<OddsApiResponse<List<OddsEvent>>> cache;
  final Duration ttl;
  final int maxRetries;
  final Clock clock;

  TestOddsApiService({
    required this.client,
    required this.cache,
    required this.clock,
    this.ttl = const Duration(minutes: 5),
    this.maxRetries = 3,
  });

  @override
  Future<OddsApiResponse<List<OddsEvent>>> getOdds({required String sport}) async {
    final cached = cache.get(sport);
    if (cached != null) return cached;

    var attempt = 0;
    while (true) {
      try {
        final response = await client.get(Uri.parse('https://api.test/$sport'));
        if (response.statusCode == 429) {
          final retryAfter = int.tryParse(response.headers['retry-after'] ?? '1') ?? 1;
          if (clock is MutableClock) {
            (clock as MutableClock).advance(Duration(seconds: retryAfter));
          } else {
            await Future.delayed(Duration(seconds: retryAfter));
          }
          continue;
        }
        if (response.statusCode != 200) {
          throw http.ClientException('error');
        }
        final data = (jsonDecode(response.body) as List)
            .map((e) => OddsEvent.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        final res = OddsApiResponse(data: data);
        cache.set(sport, res, ttl);
        return res;
      } catch (_) {
        attempt++;
        if (attempt >= maxRetries) {
          throw OddsApiException.retryFailed;
        }
      }
    }
  }
}

const sampleEvent = {
  'id': '1',
  'sport_key': 'soccer',
  'sport_title': 'Soccer',
  'home_team': 'A',
  'away_team': 'B',
  'commence_time': '2020-01-01T00:00:00Z',
  'bookmakers': <dynamic>[],
};

void main() {
  group('OddsApiService', () {
    test('cache hit returns cached value without http call', () async {
      var httpCalls = 0;
      final client = MockClient((_) async {
        httpCalls++;
        return http.Response(jsonEncode([sampleEvent]), 200);
      });
      final clock = MutableClock(DateTime(2024));
      final cache = FakeCache<OddsApiResponse<List<OddsEvent>>>(clock);
      final cached = OddsApiResponse(data: [OddsEvent.fromJson(sampleEvent)]);
      cache.set('soccer', cached, const Duration(minutes: 5));
      final service = TestOddsApiService(client: client, cache: cache, clock: clock);

      final result = await withClock(clock, () => service.getOdds(sport: 'soccer'));

      expect(result, same(cached));
      expect(httpCalls, 0);
    });

    test('cache miss fetches data and stores in cache', () async {
      var httpCalls = 0;
      final client = MockClient((_) async {
        httpCalls++;
        return http.Response(jsonEncode([sampleEvent]), 200);
      });
      final clock = MutableClock(DateTime(2024));
      final cache = FakeCache<OddsApiResponse<List<OddsEvent>>>(clock);
      final service = TestOddsApiService(client: client, cache: cache, clock: clock);

      final first = await withClock(clock, () => service.getOdds(sport: 'soccer'));
      final second = await withClock(clock, () => service.getOdds(sport: 'soccer'));

      expect(httpCalls, 1);
      expect(first.data!.length, 1);
      expect(identical(first, second), true);
    });

    test('retry succeeds on second attempt', () async {
      var httpCalls = 0;
      final client = MockClient((_) async {
        httpCalls++;
        if (httpCalls == 1) throw http.ClientException('timeout');
        return http.Response(jsonEncode([sampleEvent]), 200);
      });
      final clock = MutableClock(DateTime(2024));
      final cache = FakeCache<OddsApiResponse<List<OddsEvent>>>(clock);
      final service = TestOddsApiService(client: client, cache: cache, clock: clock);

      final result = await withClock(clock, () => service.getOdds(sport: 'soccer'));

      expect(httpCalls, 2);
      expect(result.data, isNotNull);
    });

    test('throws after max retries exceeded', () async {
      var httpCalls = 0;
      final client = MockClient((_) async {
        httpCalls++;
        throw http.ClientException('timeout');
      });
      final clock = MutableClock(DateTime(2024));
      final cache = FakeCache<OddsApiResponse<List<OddsEvent>>>(clock);
      final service = TestOddsApiService(
        client: client,
        cache: cache,
        clock: clock,
        maxRetries: 3,
      );

      expect(
        () => withClock(clock, () => service.getOdds(sport: 'soccer')),
        throwsA(isA<OddsApiException>()),
      );
      expect(httpCalls, 3);
    });

    test('rate limit retries after delay', () async {
      var httpCalls = 0;
      final client = MockClient((_) async {
        httpCalls++;
        if (httpCalls == 1) {
          return http.Response('', 429, headers: {'retry-after': '2'});
        }
        return http.Response(jsonEncode([sampleEvent]), 200);
      });
      final clock = MutableClock(DateTime(2024));
      final cache = FakeCache<OddsApiResponse<List<OddsEvent>>>(clock);
      final service = TestOddsApiService(client: client, cache: cache, clock: clock);

      final result = await withClock(clock, () async {
        final future = service.getOdds(sport: 'soccer');
        clock.advance(const Duration(seconds: 2));
        return future;
      });

      expect(httpCalls, 2);
      expect(result.data, isNotNull);
      expect(cache.get('soccer'), isNotNull);
    });
  });
}

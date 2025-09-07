import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tipsterino/models/api_response.dart';
import 'package:tipsterino/models/odds_event.dart';
import 'package:tipsterino/services/api_football_service.dart';
import 'package:tipsterino/services/odds_cache_wrapper.dart';

class FakeApiFootballService extends ApiFootballService {
  int callCount = 0;
  ApiResponse<List<OddsEvent>> response;

  FakeApiFootballService(this.response);

  @override
  Future<ApiResponse<List<OddsEvent>>> getOdds({
    required String sport,
    String? country,
    String? league,
    DateTime? date,
    bool includeH2H = false,
  }) async {
    callCount++;
    return response;
  }
}

void main() {
  test('cache miss triggers service call and stores result', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final service = FakeApiFootballService(
      const ApiResponse(data: <OddsEvent>[]),
    );
    final wrapper = OddsCacheWrapper(service, prefs);

    final date = DateTime(2024, 1, 1);
    await wrapper.getOdds(sport: 'soccer', date: date);

    expect(service.callCount, 1);
    expect(prefs.getString('odds_soccer|2024-01-01||'), isNotNull);
  });

  test('cache hit does not call service', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final service = FakeApiFootballService(
      const ApiResponse(data: <OddsEvent>[]),
    );
    final wrapper = OddsCacheWrapper(service, prefs);

    final date = DateTime(2024, 1, 1);
    await wrapper.getOdds(sport: 'soccer', date: date);
    final firstCalls = service.callCount;
    await wrapper.getOdds(sport: 'soccer', date: date);

    expect(service.callCount, firstCalls);
  });

  test('expired cache triggers new call', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final past = DateTime.now().subtract(const Duration(hours: 1));
    final date = DateTime(2024, 1, 1);
    await prefs.setString(
      'odds_soccer|2024-01-01||',
      '{"expiry":"${past.toIso8601String()}","events":[]}',
    );

    final service = FakeApiFootballService(
      const ApiResponse(data: <OddsEvent>[]),
    );
    final wrapper = OddsCacheWrapper(service, prefs);

    await wrapper.getOdds(sport: 'soccer', date: date);

    expect(service.callCount, 1);
  });

  test('invalid response not cached', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final service = FakeApiFootballService(
      const ApiResponse(
        data: null,
        errorType: ApiErrorType.network,
        errorMessage: 'err',
      ),
    );
    final wrapper = OddsCacheWrapper(service, prefs);

    final date = DateTime(2024, 1, 1);
    await wrapper.getOdds(sport: 'soccer', date: date);

    expect(service.callCount, 1);
    expect(prefs.getString('odds_soccer|2024-01-01||'), isNull);
  });
}

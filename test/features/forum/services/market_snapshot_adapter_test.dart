import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/features/forum/services/market_snapshot_adapter.dart';
import 'package:tippmixapp/services/api_football_service.dart';

class _MockApiFootballService extends ApiFootballService {
  int callCount = 0;

  @override
  Future<Map<String, dynamic>> getOddsForFixture(
    String fixtureId, {
    int? season,
    bool includeBet1 = true,
  }) async {
    callCount++;
    return {'fixture': fixtureId};
  }
}

void main() {
  test('caches market snapshot per fixture', () async {
    final api = _MockApiFootballService();
    final adapter = MarketSnapshotAdapter(api: api);

    final first = await adapter.getSnapshot(42);
    final second = await adapter.getSnapshot(42);

    expect(first, second);
    expect(api.callCount, 1);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tipsterino/services/api_football_service.dart';

class CountingClient extends http.BaseClient {
  int calls = 0;
  final http.Client _inner;
  CountingClient(this._inner);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    calls += 1;
    return _inner.send(request);
  }
}

void main() {
  test(
    'getH2HForFixture guard: fixtureId<=0 esetén nincs hálózati hívás',
    () async {
      final inner = http.Client();
      final client = CountingClient(inner);
      final api = ApiFootballService(client);
      final res = await api.getH2HForFixture(0);
      expect(res, isNull);
      expect(client.calls, 0);
    },
  );
}

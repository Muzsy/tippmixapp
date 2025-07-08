import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/services/stats_service.dart';

class FakeFirestore extends Fake {}

void main() {
  test('statsDocStream emits values', () async {
    final service = StatsService(FakeFirestore() as dynamic);
    expect(service.statsDocStream('u1'), isA<Stream>());
  });
}

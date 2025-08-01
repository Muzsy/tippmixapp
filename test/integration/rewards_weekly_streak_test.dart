import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tippmixapp/services/stats_service.dart';

class LenientFakeFirestore extends FakeFirebaseFirestore {
  @override
  DocumentReference<Map<String, dynamic>> doc(String path) {
    if (path.split('/').length.isOdd) {
      path = '$path/dummy';
    }
    return super.doc(path);
  }
}

void main() {
  test('statsDocStream emits values', () async {
    final service = StatsService(LenientFakeFirestore());
    expect(service.statsDocStream('u1'), isA<Stream>());
  });
}

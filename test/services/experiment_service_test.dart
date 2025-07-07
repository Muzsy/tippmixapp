import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tippmixapp/services/experiment_service.dart';

class FakeRemoteConfig extends Fake implements FirebaseRemoteConfig {
  String variant;
  bool fetchCalled = false;
  FakeRemoteConfig(this.variant);
  @override
  Future<bool> fetchAndActivate() async {
    fetchCalled = true;
    return true;
  }

  @override
  String getString(String key) => variant;
}

void main() {
  group('ExperimentService', () {
    test('returns cached variant when fresh', () async {
      final ts = DateTime.now().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        'login_variant': 'B',
        'login_variant_ts': ts,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = ExperimentService(
        remoteConfig: FakeRemoteConfig('A'),
        prefs: prefs,
      );

      final result = await service.getLoginVariant();

      expect(result, 'B');
    });

    test('fetches remote when cache expired', () async {
      final past = DateTime.now()
              .subtract(const Duration(days: 30))
              .millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        'login_variant': 'A',
        'login_variant_ts': past,
      });
      final prefs = await SharedPreferences.getInstance();
      final remote = FakeRemoteConfig('B');
      final service = ExperimentService(remoteConfig: remote, prefs: prefs);

      final result = await service.getLoginVariant();

      expect(remote.fetchCalled, isTrue);
      expect(result, 'B');
    });
  });
}

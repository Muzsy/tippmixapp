import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tippmixapp/firebase_app_check_ext.dart';

class _MockAppCheck extends Mock
    implements FirebaseAppCheck, FirebaseAppCheckWithToken {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const tok = 'TEST_TOKEN';

  test('setToken hívódik a debug tokennel', () async {
    final mock = _MockAppCheck();
    when(() => mock.setToken(tok, isDebug: true)).thenAnswer((_) async {});

    await mock.setToken(tok, isDebug: true);

    verify(() => mock.setToken(tok, isDebug: true)).called(1);
  });
}

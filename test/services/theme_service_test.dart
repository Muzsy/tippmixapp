import 'package:flutter_test/flutter_test.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tippmixapp/services/theme_service.dart';

class FakeUser extends Fake implements User {
  @override
  final String uid;
  FakeUser(this.uid);
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  FakeFirebaseAuth(this._user);
  final User? _user;
  @override
  User? get currentUser => _user;
}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('ThemeService', () {
    Future<ThemeService> createService({User? user, FakeFirebaseFirestore? fs}) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      return ThemeService(
        prefs: prefs,
        firestore: fs ?? FakeFirebaseFirestore(),
        auth: FakeFirebaseAuth(user),
      );
    }

    test('initial state', () async {
      final service = await createService();
      expect(service.state.schemeIndex, 0);
      expect(service.state.isDark, isFalse);
    });

    test('toggleTheme cycles schemes', () async {
      final service = await createService();
      service.toggleTheme();
      expect(service.state.schemeIndex, 1);
      for (var i = 1; i < FlexScheme.values.length; i++) {
        service.toggleTheme();
      }
      expect(service.state.schemeIndex, 0);
    });

    test('toggleDarkMode switches flag', () async {
      final service = await createService();
      service.toggleDarkMode();
      expect(service.state.isDark, isTrue);
      service.toggleDarkMode();
      expect(service.state.isDark, isFalse);
    });

    test('setScheme only accepts valid indexes', () async {
      final service = await createService();
      service.setScheme(2);
      expect(service.state.schemeIndex, 2);
      service.setScheme(-1);
      expect(service.state.schemeIndex, 2);
      service.setScheme(999);
      expect(service.state.schemeIndex, 2);
    });

    test('notifies listeners on state changes', () async {
      final service = await createService();
      final emitted = <ThemeState>[];
      final remove = service.addListener(emitted.add, fireImmediately: false);

      service.toggleDarkMode();
      service.setScheme(3);

      remove();

      expect(emitted.length, 2);
      expect(emitted.first.isDark, isTrue);
      expect(emitted.last.schemeIndex, 3);
    });

    test('hydrate loads from preferences', () async {
      SharedPreferences.setMockInitialValues({
        'theme_scheme': 2,
        'theme_dark': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = ThemeService(
        prefs: prefs,
        firestore: FakeFirebaseFirestore(),
        auth: FakeFirebaseAuth(null),
      );

      await service.hydrate();

      expect(service.state.schemeIndex, 2);
      expect(service.state.isDark, isTrue);
    });

    test('hydrate loads from firestore when logged in', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final firestore = FakeFirebaseFirestore();
      await firestore
          .collection('users')
          .doc('u1')
          .collection('settings')
          .doc('theme')
          .set({'schemeIndex': 1, 'isDark': true});
      final service = ThemeService(
        prefs: prefs,
        firestore: firestore,
        auth: FakeFirebaseAuth(FakeUser('u1')),
      );

      await service.hydrate();

      expect(service.state.schemeIndex, 1);
      expect(service.state.isDark, isTrue);
    });

    test('hydrate falls back to defaults on error', () async {
      SharedPreferences.setMockInitialValues({'theme_scheme': 2, 'theme_dark': true});
      final prefs = await SharedPreferences.getInstance();
      final firestore = MockFirebaseFirestore();
      when(() => firestore.collection(any())).thenThrow(Exception('fail'));
      final service = ThemeService(
        prefs: prefs,
        firestore: firestore,
        auth: FakeFirebaseAuth(FakeUser('u1')),
      );

      await service.hydrate();

      expect(service.state.schemeIndex, 0);
      expect(service.state.isDark, isFalse);
    });

    test('saveTheme and saveDarkMode persist values', () async {
      final firestore = FakeFirebaseFirestore();
      final service = await createService(user: FakeUser('u1'), fs: firestore);

      service.setScheme(2);
      await service.saveTheme();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_scheme'), 2);
      final doc = await firestore
          .collection('users')
          .doc('u1')
          .collection('settings')
          .doc('theme')
          .get();
      expect(doc.data()?['schemeIndex'], 2);

      service.toggleDarkMode();
      await service.saveDarkMode();
      expect(prefs.getBool('theme_dark'), isTrue);
      final doc2 = await firestore
          .collection('users')
          .doc('u1')
          .collection('settings')
          .doc('theme')
          .get();
      expect(doc2.data()?['isDark'], isTrue);
    });
  });
}

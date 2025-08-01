import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:tippmixapp/services/profile_service.dart';
import 'package:tippmixapp/models/user_model.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

class MockUploadTask extends Mock implements UploadTask {}

void main() {
  setUpAll(() {
    registerFallbackValue(File('fallback.png'));
  });
  group('ProfileService.uploadAvatar', () {
    late MockFirebaseStorage storage;
    late MockReference reference;
    late MockUploadTask task;
    late FakeFirebaseFirestore firestore;
    late FakeCache<UserModel> cache;

    setUp(() {
      storage = MockFirebaseStorage();
      reference = MockReference();
      task = MockUploadTask();
      firestore = FakeFirebaseFirestore();
      cache = FakeCache<UserModel>();
      when(() => storage.ref()).thenReturn(reference);
      when(() => reference.child(any())).thenReturn(reference);
      when(() => reference.putFile(any())).thenAnswer((_) => task);
      when(
        () => reference.getDownloadURL(),
      ).thenAnswer((_) async => 'http://download');
    });

    test('uploads file and updates profile', () async {
      await firestore.collection('users').doc('u1').set({
        'uid': 'u1',
        'email': 'a@b.com',
        'displayName': 'Test',
        'nickname': 'nick',
        'avatarUrl': 'old.png',
        'isPrivate': false,
        'fieldVisibility': {},
      });
      final file = File('avatar.png');
      final url = await ProfileService.uploadAvatar(
        uid: 'u1',
        file: file,
        storage: storage,
        firestore: firestore,
        cache: cache,
        connectivity: FakeConnectivity(),
      );
      expect(url, 'http://download');
      final doc = await firestore.collection('users').doc('u1').get();
      expect(doc.data()?['avatarUrl'], 'http://download');
    });
  });
}

class FakeConnectivity {
  bool get online => true;
}

class FakeCache<T> {
  final _store = <String, T>{};
  T? get(String key) => _store[key];
  void set(String key, T value, Duration ttl) => _store[key] = value;
  void invalidate(String key) => _store.remove(key);
}

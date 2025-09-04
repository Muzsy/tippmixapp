import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:tippmixapp/services/profile_service.dart';
import 'package:tippmixapp/models/user_model.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

class MockUploadTask extends Mock implements UploadTask {}

class MockTaskSnapshot extends Mock implements TaskSnapshot {}

void main() {
  setUpAll(() {
    registerFallbackValue(File('fallback.png'));
    registerFallbackValue(Uint8List(0));
  });
  group('ProfileService.uploadAvatar', () {
    late MockFirebaseStorage storage;
    late MockReference reference;
    late MockUploadTask task;
    late MockTaskSnapshot snapshot;
    late FakeFirebaseFirestore firestore;
    late FakeCache<UserModel> cache;

    late File tempFile;
    setUp(() {
      storage = MockFirebaseStorage();
      reference = MockReference();
      task = MockUploadTask();
      snapshot = MockTaskSnapshot();
      firestore = FakeFirebaseFirestore();
      cache = FakeCache<UserModel>();
      when(() => storage.ref()).thenReturn(reference);
      when(() => reference.child(any())).thenReturn(reference);
      when(() => reference.putData(any(), any())).thenAnswer((_) => task);
      when(() => task.whenComplete(any())).thenAnswer((_) async => snapshot);
      when(
        () => reference.getDownloadURL(),
      ).thenAnswer((_) async => 'http://download');
      // create a small temp PNG file that exists on disk
      tempFile = File('${Directory.systemTemp.createTempSync().path}/a.png')
        ..writeAsBytesSync(const [
          0x89,
          0x50,
          0x4E,
          0x47,
          0x0D,
          0x0A,
          0x1A,
          0x0A,
          0x00,
          0x00,
          0x00,
          0x0D,
          0x49,
          0x48,
          0x44,
          0x52,
          0x00,
          0x00,
          0x00,
          0x01,
          0x00,
          0x00,
          0x00,
          0x01,
          0x08,
          0x06,
          0x00,
          0x00,
          0x00,
          0x1F,
          0x15,
          0xC4,
          0x89,
          0x00,
          0x00,
          0x00,
          0x0A,
          0x49,
          0x44,
          0x41,
          0x54,
          0x78,
          0x9C,
          0x63,
          0x00,
          0x01,
          0x00,
          0x00,
          0x05,
          0x00,
          0x01,
          0x0D,
          0x0A,
          0x2D,
          0xB4,
          0x00,
          0x00,
          0x00,
          0x00,
          0x49,
          0x45,
          0x4E,
          0x44,
          0xAE,
        ]);
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
      final file = tempFile;
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
      verify(() => reference.child('users/u1/avatar/avatar_256.png')).called(1);
      // cleanup temp file
      try {
        await file.parent.delete(recursive: true);
      } catch (_) {}
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

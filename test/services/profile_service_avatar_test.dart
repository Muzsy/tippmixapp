import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:tippmixapp/services/profile_service.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

class MockUploadTask extends Mock implements UploadTask {}

void main() {
  group('ProfileService.uploadAvatar', () {
    late MockFirebaseStorage storage;
    late MockReference reference;
    late MockUploadTask task;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      storage = MockFirebaseStorage();
      reference = MockReference();
      task = MockUploadTask();
      firestore = FakeFirebaseFirestore();
      when(() => storage.ref()).thenReturn(reference);
      when(() => reference.child(any())).thenReturn(reference);
      when(() => reference.putFile(any())).thenReturn(task);
      when(
        () => reference.getDownloadURL(),
      ).thenAnswer((_) async => 'http://download');
    });

    test('uploads file and updates profile', () async {
      await firestore.collection('users').doc('u1').set({'uid': 'u1'});
      final file = File('avatar.png');
      final url = await ProfileService.uploadAvatar(
        uid: 'u1',
        file: file,
        storage: storage,
        firestore: firestore,
        cache: null,
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

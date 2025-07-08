import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:tippmixapp/services/user_service.dart';

void main() {
  test('updateNotificationPrefs writes and returns updated model', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('u1').set({
      'uid': 'u1',
      'email': 'a@b.com',
      'displayName': 'name',
      'nickname': 'nick',
      'avatarUrl': 'avatar.png',
      'isPrivate': false,
      'fieldVisibility': {},
    });
    final service = UserService(firestore);

    final updated = await service.updateNotificationPrefs('u1', {'tips': false});

    final doc = await firestore.collection('users').doc('u1').get();
    expect(doc.data()?['notificationPreferences']['tips'], false);
    expect(updated.notificationPreferences['tips'], false);
    expect(updated.uid, 'u1');
  });
}

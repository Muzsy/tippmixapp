import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:tipsterino/services/user_service.dart';

void main() {
  test('updateProfile merges changes', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc('u1').set({
      'uid': 'u1',
      'email': 'a@b.com',
      'displayName': 'old',
      'nickname': 'n',
      'avatarUrl': 'avatar.png',
      'isPrivate': false,
      'fieldVisibility': {},
    });
    final service = UserService(firestore);
    final updated = await service.updateProfile('u1', {'displayName': 'new'});
    final doc = await firestore.collection('users').doc('u1').get();
    expect(doc.data()?['displayName'], 'new');
    expect(updated.displayName, 'new');
  });
}

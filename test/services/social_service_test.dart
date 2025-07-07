import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tippmixapp/services/social_service.dart';

class FakeUser extends Fake implements User {
  @override
  final String uid;
  FakeUser(this.uid);
}

class FakeAuth extends Fake implements FirebaseAuth {
  final User _user;
  FakeAuth(this._user);
  @override
  User? get currentUser => _user;
}

// ignore: subtype_of_sealed_class
class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  @override
  final String id;
  final FakeFirebaseFirestore _firestore;
  final Map<String, Map<String, dynamic>> store;
  final String _path;
  FakeDocumentReference(this._firestore, this._path, this.store, this.id);
  @override
  String get path => _path;
  @override
  FirebaseFirestore get firestore => _firestore;
  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    store[id] = data;
  }
  @override
  Future<void> update(Map<Object?, Object?> data) async {
    store[id]?.addAll(data.cast<String, dynamic>());
  }
  @override
  Future<void> delete() async {
    store.remove(id);
  }

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection('${this.path}/$path');
  }
}

// ignore: subtype_of_sealed_class
class FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final FakeFirebaseFirestore _firestore;
  final String _path;
  final Map<String, Map<String, dynamic>> store;
  FakeCollectionReference(this._firestore, this._path, this.store);
  @override
  String get path => _path;
  @override
  FirebaseFirestore get firestore => _firestore;
  @override
  Future<DocumentReference<Map<String, dynamic>>> add(
      Map<String, dynamic> data) async {
    final id = 'doc${store.length}';
    store[id] = data;
    return FakeDocumentReference(_firestore, '$path/$id', store, id);
  }
  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) {
    final key = id ?? 'doc${store.length}';
    store.putIfAbsent(key, () => <String, dynamic>{});
    return FakeDocumentReference(_firestore, '$path/$key', store, key);
  }
}

// ignore: subtype_of_sealed_class
class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final Map<String, Map<String, Map<String, dynamic>>> data = {};
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    data.putIfAbsent(path, () => <String, Map<String, dynamic>>{});
    return FakeCollectionReference(this, path, data[path]!);
  }
}

void main() {
  test('followUser creates follower doc', () async {
    final fs = FakeFirebaseFirestore();
    final auth = FakeAuth(FakeUser('u1'));
    final service = SocialService(firestore: fs, auth: auth);

    await service.followUser('u2');

    expect(fs.data['relations/u2/followers']?['u1'] != null, isTrue);
  });

  test('sendFriendRequest adds request doc', () async {
    final fs = FakeFirebaseFirestore();
    final auth = FakeAuth(FakeUser('u1'));
    final service = SocialService(firestore: fs, auth: auth);

    await service.sendFriendRequest('u2');

    final reqs = fs.data['relations/u2/friendRequests']!;
    expect(reqs.length, 1);
    expect(reqs.values.first['fromUid'], 'u1');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clock/clock.dart';

import 'package:tippmixapp/services/profile_service.dart';
import 'package:tippmixapp/models/user_model.dart';

class CacheEntry<T> {
  final T value;
  final DateTime expiry;
  CacheEntry(this.value, this.expiry);
}

abstract class Cache<T> {
  T? get(String key);
  void set(String key, T value, Duration ttl);
  void invalidate(String key);
}

class FakeCache<T> implements Cache<T> {
  final _store = <String, CacheEntry<T>>{};
  final Clock clock;
  FakeCache(this.clock);

  @override
  T? get(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (clock.now().isAfter(entry.expiry)) {
      _store.remove(key);
      return null;
    }
    return entry.value;
  }

  @override
  void set(String key, T value, Duration ttl) {
    _store[key] = CacheEntry(value, clock.now().add(ttl));
  }

  @override
  void invalidate(String key) => _store.remove(key);
}

class FakeConnectivity {
  bool online;
  FakeConnectivity({this.online = true});
}

// ignore: subtype_of_sealed_class
class FakeDocumentSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  final String id;
  final Map<String, dynamic>? _data;
  FakeDocumentSnapshot(this.id, this._data);

  @override
  Map<String, dynamic>? data() => _data;
}

// ignore: subtype_of_sealed_class
class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  @override
  final FakeFirebaseFirestore firestore;
  @override
  final String id;
  final Map<String, Map<String, dynamic>> store;
  FakeDocumentReference(this.firestore, this.id, this.store);

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    store[id] = data;
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    if (firestore.failNextUpdate) {
      firestore.failNextUpdate = false;
      throw FirebaseException(plugin: 'firestore', code: 'permission-denied');
    }
    final current = store[id] ?? <String, dynamic>{};
    data.forEach((key, value) {
      if (key is String) current[key] = value;
    });
    store[id] = current;
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async {
    return FakeDocumentSnapshot(id, store[id]);
  }
}

// ignore: subtype_of_sealed_class
class FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  @override
  final FakeFirebaseFirestore firestore;
  final Map<String, Map<String, dynamic>> store;
  FakeCollectionReference(this.firestore, this.store);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) {
    final key = id ?? 'doc${store.length}';
    store.putIfAbsent(key, () => <String, dynamic>{});
    return FakeDocumentReference(firestore, key, store);
  }
}

// ignore: subtype_of_sealed_class
class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  final Map<String, Map<String, Map<String, dynamic>>> data = {};
  bool failNextUpdate = false;

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    data.putIfAbsent(path, () => <String, Map<String, dynamic>>{});
    return FakeCollectionReference(this, data[path]!);
  }
}

void main() {
  group('ProfileService', () {
    late FakeFirebaseFirestore firestore;
    late FakeCache<UserModel> cache;
    late FakeConnectivity connectivity;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      cache = FakeCache<UserModel>(Clock.fixed(DateTime(2024)));
      connectivity = FakeConnectivity();
    });

    test('online fetch caches profile', () async {
      await firestore.collection('users').doc('u1').set({
        'uid': 'u1',
        'email': 'a@b.com',
        'displayName': 'Test',
      });

      final profile = await withClock(Clock.fixed(DateTime(2024)), () {
        return ProfileService.getProfile(
          uid: 'u1',
          firestore: firestore,
          cache: cache,
          connectivity: connectivity,
        );
      });

      expect(profile.uid, 'u1');
      expect(cache.get('u1')?.uid, 'u1');
    });

    test('offline cache fallback', () async {
      cache.set(
        'u1',
        UserModel(
          uid: 'u1',
          email: 'cache@a.com',
          displayName: 'Cached',
          nickname: '',
          avatarUrl: '',
          isPrivate: false,
          fieldVisibility: const {},
        ),
        const Duration(hours: 1),
      );
      connectivity.online = false;

      final profile = await ProfileService.getProfile(
        uid: 'u1',
        firestore: firestore,
        cache: cache,
        connectivity: connectivity,
      );

      expect(profile.displayName, 'Cached');
    });

    test('update success updates firestore and cache', () async {
      await firestore.collection('users').doc('u1').set({
        'uid': 'u1',
        'email': 'a@b.com',
        'displayName': 'Old',
      });

      await ProfileService.updateProfile(
        uid: 'u1',
        data: {'displayName': 'New'},
        firestore: firestore,
        cache: cache,
        connectivity: connectivity,
      );

      final doc = await firestore.collection('users').doc('u1').get();
      expect(doc.data()?['displayName'], 'New');
      expect(cache.get('u1')?.displayName, 'New');
    });

    test('permission error surfaces as ProfileUpdateFailure', () async {
      firestore.failNextUpdate = true;
      expect(
        () => ProfileService.updateProfile(
          uid: 'u1',
          data: {'displayName': 'x'},
          firestore: firestore,
          cache: cache,
          connectivity: connectivity,
        ),
        throwsA(isA<ProfileUpdateFailure>()),
      );
    });

    test('offline update queued and flushed when online', () async {
      connectivity.online = false;
      await ProfileService.updateProfile(
        uid: 'u1',
        data: {'displayName': 'Queued'},
        firestore: firestore,
        cache: cache,
        connectivity: connectivity,
      );

      connectivity.online = true;
      await ProfileService.flushQueuedUpdates(
        firestore: firestore,
        cache: cache,
        connectivity: connectivity,
      );

      final doc = await firestore.collection('users').doc('u1').get();
      expect(doc.data()?['displayName'], 'Queued');
    });
  });
}

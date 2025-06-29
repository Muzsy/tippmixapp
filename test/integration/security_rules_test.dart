import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Utility to create an authenticated Firestore context.
FakeFirebaseFirestore _authed(String? uid) {
  final firestore = FakeFirebaseFirestore();
  firestore.setSecurityRules(File('firebase.rules').readAsStringSync());
  firestore.authUid = uid; // hypothetical API for auth
  return firestore;
}

void main() {
  group('Firestore security rules', () {
    test('SR-01 coin_logs create saját uid OK', () async {
      final db = _authed('user1');
      await expectLater(
        db.collection('coin_logs').doc('log1').set({
          'userId': 'user1',
          'amount': 50,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'bet',
        }),
        completes,
      );
    });

    test('SR-02 coin_logs create más uid FAIL', () async {
      final db = _authed('user1');
      await expectLater(
        db.collection('coin_logs').doc('log2').set({
          'userId': 'user2',
          'amount': 20,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'bet',
        }),
        throwsA(isA<FirebaseException>()),
      );
    });

    test('SR-03 coin_logs read saját uid OK', () async {
      final db = _authed('user1');
      await db.collection('coin_logs').doc('id1').set({
        'userId': 'user1',
        'amount': 10,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'deposit',
      });
      await expectLater(
        db.collection('coin_logs').doc('id1').get(),
        completes,
      );
    });

    test('SR-04 coin_logs read más uid FAIL', () async {
      final db = _authed('user1');
      await db.collection('coin_logs').doc('id2').set({
        'userId': 'user2',
        'amount': 10,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'deposit',
      });
      await expectLater(
        db.collection('coin_logs').doc('id2').get(),
        throwsA(isA<FirebaseException>()),
      );
    });

    test('SR-05 coin_logs update tiltott', () async {
      final db = _authed('user1');
      await db.collection('coin_logs').doc('id3').set({
        'userId': 'user1',
        'amount': 5,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'bet',
      });
      await expectLater(
        db.collection('coin_logs').doc('id3').update({'amount': 6}),
        throwsA(isA<FirebaseException>()),
      );
    });

    test('SR-06 badge read publikus', () async {
      final db = _authed(null);
      await db.collection('badges').doc('b1').set({'key': 'b1'});
      await expectLater(
        db.collection('badges').doc('b1').get(),
        completes,
      );
    });

    test('SR-07 notification read saját', () async {
      final db = _authed('user1');
      await db.collection('notifications').doc('user1').collection('n').doc('n1').set({
        'read': false,
      });
      await expectLater(
        db.collection('notifications').doc('user1').collection('n').doc('n1').get(),
        completes,
      );
    });

    test('SR-08 notification read idegen', () async {
      final db = _authed('user1');
      await db.collection('notifications').doc('user2').collection('n').doc('n1').set({
        'read': false,
      });
      await expectLater(
        db.collection('notifications').doc('user2').collection('n').doc('n1').get(),
        throwsA(isA<FirebaseException>()),
      );
    });

    test('SR-09 notification markRead saját', () async {
      final db = _authed('user1');
      await db.collection('notifications').doc('user1').collection('n').doc('n1').set({
        'read': false,
      });
      await expectLater(
        db.collection('notifications').doc('user1').collection('n').doc('n1').update({'read': true}),
        completes,
      );
    });

    test('SR-10 notification markRead idegen FAIL', () async {
      final db = _authed('user1');
      await db.collection('notifications').doc('user2').collection('n').doc('n2').set({
        'read': false,
      });
      await expectLater(
        db.collection('notifications').doc('user2').collection('n').doc('n2').update({'read': true}),
        throwsA(isA<FirebaseException>()),
      );
    });
  });
}

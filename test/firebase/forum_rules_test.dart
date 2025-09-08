// ignore: unnecessary_library_name
library forum_rules_test;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late String rules;
  setUpAll(() async {
    rules = await File('firebase.rules').readAsString();
  });

  group('forum security rules', () {
    test('authenticated user can create post', () async {
      final fs = FakeFirebaseFirestore(securityRules: rules);
      fs.authObject.add({'uid': 'u1'});
      await Future<void>.value();
      await fs.collection('threads').doc('t1').set({
        'title': 't',
        'type': 'general',
        'createdBy': 'u1',
        'createdAt': Timestamp.now(),
      });
      await fs.collection('threads/t1/posts').doc('p1').set({
        'threadId': 't1',
        'userId': 'u1',
        'type': 'tip',
        'content': 'hi',
        'createdAt': Timestamp.now(),
      });
    });

    test('unauthenticated user cannot create post', () async {
      final fs = FakeFirebaseFirestore(securityRules: rules);
      fs.authObject.add({'uid': 'u1'});
      await Future<void>.value();
      await fs.collection('threads').doc('t1').set({
        'title': 't',
        'type': 'general',
        'createdBy': 'u1',
        'createdAt': Timestamp.now(),
      });
      fs.authObject.add(null);
      await expectLater(
        () async => fs.collection('threads/t1/posts').doc('p1').set({
          'threadId': 't1',
          'userId': 'u2',
          'type': 'tip',
          'content': 'hi',
          'createdAt': Timestamp.now(),
        }),
        throwsA(isA<Exception>()),
      );
    });

    test('owner cannot update after 15 minutes', () async {
      final fs = FakeFirebaseFirestore(securityRules: rules);
      fs.authObject.add({'uid': 'u1'});
      await Future<void>.value();
      await fs.collection('threads').doc('t1').set({
        'title': 't',
        'type': 'general',
        'createdBy': 'u1',
        'createdAt': Timestamp.now(),
      });
      final past = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(minutes: 20)),
      );
      await fs.collection('threads/t1/posts').doc('p1').set({
        'threadId': 't1',
        'userId': 'u1',
        'type': 'tip',
        'content': 'hi',
        'createdAt': past,
      });
      await expectLater(
        () async => fs.collection('threads/t1/posts').doc('p1').update({
          'content': 'edit',
        }),
        throwsA(isA<Exception>()),
      );
    });

    test('moderator can lock thread', () async {
      final fs = FakeFirebaseFirestore(securityRules: rules);
      fs.authObject.add({
        'uid': 'mod',
        'token': {'moderator': true},
      });
      await Future<void>.value();
      await fs.collection('threads').doc('t1').set({
        'title': 't',
        'type': 'general',
        'createdBy': 'mod',
        'createdAt': Timestamp.now(),
        'locked': false,
      });
      await fs.collection('threads').doc('t1').update({'locked': true});
    });

    test('vote unique per user', () async {
      final fs = FakeFirebaseFirestore(securityRules: rules);
      fs.authObject.add({'uid': 'u1'});
      await Future<void>.value();
      await fs.collection('votes').doc('p1_u1').set({
        'entityType': 'post',
        'entityId': 'p1',
        'userId': 'u1',
        'createdAt': Timestamp.now(),
      });
      await expectLater(
        () async => fs.collection('votes').doc('p1_u1').set({
          'entityType': 'post',
          'entityId': 'p1',
          'userId': 'u1',
          'createdAt': Timestamp.now(),
        }),
        throwsA(isA<Exception>()),
      );
    });

    test('unauthenticated cannot create thread', () async {
      final fs = FakeFirebaseFirestore(securityRules: rules);
      await expectLater(
        () async => fs.collection('threads').doc('t1').set({
          'title': 't',
          'type': 'general',
          'createdBy': 'u1',
          'createdAt': Timestamp.now(),
        }),
        throwsA(isA<Exception>()),
      );
    });

    test('locked thread blocks new posts', () async {
      final fs = FakeFirebaseFirestore(securityRules: rules);
      fs.authObject.add({'uid': 'u1'});
      await Future<void>.value();
      await fs.collection('threads').doc('t1').set({
        'title': 't',
        'type': 'general',
        'createdBy': 'u1',
        'createdAt': Timestamp.now(),
        'locked': true,
      });
      await expectLater(
        () async => fs.collection('threads/t1/posts').doc('p1').set({
          'threadId': 't1',
          'userId': 'u1',
          'type': 'tip',
          'content': 'hi',
          'createdAt': Timestamp.now(),
        }),
        throwsA(isA<Exception>()),
      );
    });

    test('report status cannot be set by client', () async {
      final fs = FakeFirebaseFirestore(securityRules: rules);
      fs.authObject.add({'uid': 'u1'});
      await Future<void>.value();
      await expectLater(
        () async => fs.collection('reports').doc('r1').set({
          'entityType': 'post',
          'entityId': 'p1',
          'reason': 'spam',
          'reporterId': 'u1',
          'status': 'resolved',
          'createdAt': Timestamp.now(),
        }),
        throwsA(isA<Exception>()),
      );
    });

    test('mismatched owner id rejected on thread create', () async {
      final fs = FakeFirebaseFirestore(securityRules: rules);
      fs.authObject.add({'uid': 'u1'});
      await Future<void>.value();
      await expectLater(
        () async => fs.collection('threads').doc('t1').set({
          'title': 't',
          'type': 'general',
          'createdBy': 'u2', // different from auth.uid
          'createdAt': Timestamp.now(),
        }),
        throwsA(isA<Exception>()),
      );
    });

    test('mismatched userId rejected on post create', () async {
      final fs = FakeFirebaseFirestore(securityRules: rules);
      fs.authObject.add({'uid': 'u1'});
      await Future<void>.value();
      await fs.collection('threads').doc('t1').set({
        'title': 't',
        'type': 'general',
        'createdBy': 'u1',
        'createdAt': Timestamp.now(),
      });
      await expectLater(
        () async => fs.collection('threads/t1/posts').doc('p1').set({
          'threadId': 't1',
          'userId': 'u2', // different from auth.uid
          'type': 'tip',
          'content': 'hi',
          'createdAt': Timestamp.now(),
        }),
        throwsA(isA<Exception>()),
      );
    });

    test('disallowed field rejected on thread create', () async {
      final fs = FakeFirebaseFirestore(securityRules: rules);
      fs.authObject.add({'uid': 'u1'});
      await Future<void>.value();
      await expectLater(
        () async => fs.collection('threads').doc('t1').set({
          'title': 't',
          'type': 'general',
          'createdBy': 'u1',
          'createdAt': Timestamp.now(),
          'pinned': true, // not whitelisted in rules
        }),
        throwsA(isA<Exception>()),
      );
    });

    test('unauthenticated user cannot vote', () async {
      final fs = FakeFirebaseFirestore(securityRules: rules);
      await expectLater(
        () async => fs.collection('votes').doc('p1_u1').set({
          'entityType': 'post',
          'entityId': 'p1',
          'userId': 'u1',
          'createdAt': Timestamp.now(),
        }),
        throwsA(isA<Exception>()),
      );
    });

    test('unauthenticated user cannot report', () async {
      final fs = FakeFirebaseFirestore(securityRules: rules);
      await expectLater(
        () async => fs.collection('reports').doc('r1').set({
          'entityType': 'post',
          'entityId': 'p1',
          'reason': 'spam',
          'reporterId': 'u1',
          'createdAt': Timestamp.now(),
        }),
        throwsA(isA<Exception>()),
      );
    });
  });
}

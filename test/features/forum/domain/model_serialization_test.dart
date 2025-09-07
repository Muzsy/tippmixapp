import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/vote.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/user_forum_prefs.dart';

void main() {
  group('Thread', () {
    test('toJson only includes client fields', () {
      final thread = Thread(
        id: 't1',
        title: 'Hello',
        type: ThreadType.general,
        fixtureId: 'f1',
        createdBy: 'u1',
        createdAt: DateTime.utc(2024, 1, 1),
        locked: true,
        pinned: false,
        lastActivityAt: DateTime.utc(2024, 1, 2),
        postsCount: 1,
        votesCount: 2,
      );
      final json = thread.toJson();
      expect(json.keys, containsAll(['title', 'type', 'createdBy', 'createdAt']));
      expect(json.containsKey('locked'), isFalse);
    });

    test('fromJson parses full document', () {
      final json = {
        'title': 'Hello',
        'type': 'general',
        'fixtureId': 'f1',
        'createdBy': 'u1',
        'createdAt': Timestamp.fromDate(DateTime.utc(2024, 1, 1)),
        'locked': true,
        'pinned': false,
        'lastActivityAt': Timestamp.fromDate(DateTime.utc(2024, 1, 2)),
        'postsCount': 1,
        'votesCount': 2,
      };
      final copy = Thread.fromJson('t1', json);
      expect(copy.locked, isTrue);
      expect(copy.postsCount, 1);
    });

    test('missing field throws', () {
      expect(() => Thread.fromJson('t1', {}), throwsA(isA<TypeError>()));
    });
  });

  group('Post', () {
    test('toJson excludes server fields', () {
      final post = Post(
        id: 'p1',
        threadId: 't1',
        userId: 'u1',
        type: PostType.tip,
        content: 'hello',
        quotedPostId: 'q1',
        createdAt: DateTime.utc(2024, 1, 1),
        editedAt: DateTime.utc(2024, 1, 2),
        votesCount: 3,
        isHidden: true,
      );
      final json = post.toJson();
      expect(json.containsKey('votesCount'), isFalse);
      expect(json.containsKey('editedAt'), isFalse);
    });

    test('fromJson parses full document', () {
      final json = {
        'threadId': 't1',
        'userId': 'u1',
        'type': 'tip',
        'content': 'hello',
        'quotedPostId': 'q1',
        'createdAt': Timestamp.fromDate(DateTime.utc(2024, 1, 1)),
        'editedAt': Timestamp.fromDate(DateTime.utc(2024, 1, 2)),
        'votesCount': 3,
        'isHidden': true,
      };
      final copy = Post.fromJson('p1', json);
      expect(copy.votesCount, 3);
      expect(copy.isHidden, isTrue);
    });

    test('missing field throws', () {
      expect(() => Post.fromJson('p1', {}), throwsA(isA<TypeError>()));
    });
  });

  group('Vote', () {
    test('toJson/fromJson', () {
      final vote = Vote(
        id: 'v1',
        entityType: VoteEntityType.post,
        entityId: 'p1',
        userId: 'u1',
        createdAt: DateTime.utc(2024, 1, 1),
      );
      final json = vote.toJson();
      final copy = Vote.fromJson('v1', json);
      expect(copy.entityType, vote.entityType);
      expect(copy.entityId, vote.entityId);
    });

    test('missing field throws', () {
      expect(() => Vote.fromJson('v1', {}), throwsA(isA<TypeError>()));
    });
  });

  group('Report', () {
    test('toJson excludes status', () {
      final report = Report(
        id: 'r1',
        entityType: ReportEntityType.post,
        entityId: 'p1',
        reason: 'spam',
        message: 'pls',
        reporterId: 'u1',
        createdAt: DateTime.utc(2024, 1, 1),
        status: ReportStatus.open,
      );
      final json = report.toJson();
      expect(json.containsKey('status'), isFalse);
    });

    test('fromJson parses status', () {
      final json = {
        'entityType': 'post',
        'entityId': 'p1',
        'reason': 'spam',
        'message': 'pls',
        'reporterId': 'u1',
        'createdAt': Timestamp.fromDate(DateTime.utc(2024, 1, 1)),
        'status': 'open',
      };
      final copy = Report.fromJson('r1', json);
      expect(copy.status, ReportStatus.open);
    });

    test('missing field throws', () {
      expect(() => Report.fromJson('r1', {}), throwsA(isA<TypeError>()));
    });
  });

  group('UserForumPrefs', () {
    test('toJson/fromJson', () {
      final prefs = UserForumPrefs(
        userId: 'u1',
        followedThreadIds: ['t1'],
        lastReads: {'t1': DateTime.utc(2024, 1, 1)},
      );
      final json = prefs.toJson();
      final copy = UserForumPrefs.fromJson('u1', json);
      expect(copy.followedThreadIds, prefs.followedThreadIds);
      expect(
        copy.lastReads['t1']!.isAtSameMomentAs(prefs.lastReads['t1']!),
        isTrue,
      );
    });

    test('missing map handled', () {
      final copy = UserForumPrefs.fromJson('u1', {});
      expect(copy.followedThreadIds, isEmpty);
    });
  });
}

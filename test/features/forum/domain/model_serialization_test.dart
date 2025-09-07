import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/vote.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/user_forum_prefs.dart';

void main() {
  group('Thread', () {
    test('toJson/fromJson', () {
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
      final copy = Thread.fromJson('t1', json);
      expect(copy.id, thread.id);
      expect(copy.title, thread.title);
      expect(copy.locked, thread.locked);
      expect(copy.postsCount, thread.postsCount);
    });

    test('missing field throws', () {
      expect(() => Thread.fromJson('t1', {}), throwsA(isA<TypeError>()));
    });
  });

  group('Post', () {
    test('toJson/fromJson', () {
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
      final copy = Post.fromJson('p1', json);
      expect(copy.type, post.type);
      expect(copy.quotedPostId, post.quotedPostId);
      expect(copy.votesCount, post.votesCount);
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
    test('toJson/fromJson', () {
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
      final copy = Report.fromJson('r1', json);
      expect(copy.reason, report.reason);
      expect(copy.reporterId, report.reporterId);
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

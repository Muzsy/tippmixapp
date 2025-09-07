import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/vote.dart';
import 'package:tipsterino/features/forum/domain/report.dart';

void main() {
  group('Thread', () {
    test('toJson/fromJson', () {
      final thread = Thread(
        id: 't1',
        fixtureId: 'f1',
        type: 'pre',
        createdAt: DateTime.utc(2024, 1, 1),
        locked: true,
      );
      final json = thread.toJson();
      final copy = Thread.fromJson('t1', json);
      expect(copy.id, thread.id);
      expect(copy.locked, thread.locked);
      expect(copy.createdAt.isAtSameMomentAs(thread.createdAt), true);
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
        createdAt: DateTime.utc(2024, 1, 1),
      );
      final json = post.toJson();
      final copy = Post.fromJson('p1', json);
      expect(copy.type, post.type);
      expect(copy.content, post.content);
    });

    test('missing field throws', () {
      expect(() => Post.fromJson('p1', {}), throwsA(isA<TypeError>()));
    });
  });

  group('Vote', () {
    test('toJson/fromJson', () {
      final vote = Vote(
        postId: 'p1',
        userId: 'u1',
        value: 1,
        createdAt: DateTime.utc(2024, 1, 1),
      );
      final json = vote.toJson();
      final copy = Vote.fromJson(json);
      expect(copy.value, vote.value);
      expect(copy.postId, vote.postId);
    });

    test('missing field throws', () {
      expect(() => Vote.fromJson({}), throwsA(isA<TypeError>()));
    });
  });

  group('Report', () {
    test('toJson/fromJson', () {
      final report = Report(
        postId: 'p1',
        userId: 'u1',
        reason: 'spam',
        createdAt: DateTime.utc(2024, 1, 1),
      );
      final json = report.toJson();
      final copy = Report.fromJson(json);
      expect(copy.reason, report.reason);
      expect(copy.userId, report.userId);
    });

    test('missing field throws', () {
      expect(() => Report.fromJson({}), throwsA(isA<TypeError>()));
    });
  });
}

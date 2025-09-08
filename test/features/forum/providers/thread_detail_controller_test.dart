import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';

class _MockRepo extends Mock implements ForumRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Post(
        id: 'p',
        threadId: 't',
        userId: 'u',
        type: PostType.tip,
        content: 'c',
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      Report(
        id: 'r',
        entityType: ReportEntityType.post,
        entityId: 'p',
        reason: 'spam',
        reporterId: 'u',
        createdAt: DateTime.now(),
      ),
    );
  });

  test('merges pages without duplicates', () async {
    final repo = _MockRepo();
    final p1 = Post(
      id: 'p1',
      threadId: 't1',
      userId: 'u1',
      type: PostType.tip,
      content: 'hi',
      createdAt: DateTime.now(),
    );
    when(
      () => repo.getPostsByThread('t1', startAfter: any(named: 'startAfter')),
    ).thenAnswer((invocation) {
      final startAfter = invocation.namedArguments[#startAfter] as DateTime?;
      return Stream.value(startAfter == null ? [p1] : [p1]);
    });
    final controller = ThreadDetailController(repo, 't1');
    await Future.delayed(Duration.zero);
    controller.loadMore();
    await Future.delayed(Duration.zero);
    expect(controller.state.value, [p1]);
    controller.dispose();
  });

  test('actions delegate to repository', () async {
    final repo = _MockRepo();
    when(
      () => repo.getPostsByThread('t1', startAfter: any(named: 'startAfter')),
    ).thenAnswer((_) => const Stream.empty());
    when(() => repo.addPost(any())).thenAnswer((_) async {});
    when(
      () => repo.voteOnPost(
        postId: any(named: 'postId'),
        userId: any(named: 'userId'),
      ),
    ).thenAnswer((_) async {});
    when(() => repo.reportPost(any())).thenAnswer((_) async {});
    final controller = ThreadDetailController(repo, 't1');
    final post = Post(
      id: 'p2',
      threadId: 't1',
      userId: 'u1',
      type: PostType.tip,
      content: 'hi',
      createdAt: DateTime.now(),
    );
    final report = Report(
      id: 'r1',
      entityType: ReportEntityType.post,
      entityId: 'p2',
      reason: 'spam',
      reporterId: 'u1',
      createdAt: DateTime.now(),
    );
    await controller.addPost(post);
    await controller.voteOnPost('p2', 'u1');
    await controller.reportPost(report);
    verify(() => repo.addPost(post)).called(1);
    verify(() => repo.voteOnPost(postId: 'p2', userId: 'u1')).called(1);
    verify(() => repo.reportPost(report)).called(1);
    controller.dispose();
  });
}

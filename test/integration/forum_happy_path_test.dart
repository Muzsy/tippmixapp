import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/forum/data/firestore_forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/composer_controller.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';

void main() {
  test('forum happy path: thread, comment, vote, report', () async {
    final fs = FakeFirebaseFirestore();
    final repo = FirestoreForumRepository(fs);
    final composer = ComposerController(repo);

    final now = DateTime.now();
    final thread = Thread(
      id: 't1',
      title: 'Hello',
      type: ThreadType.general,
      createdBy: 'u1',
      createdAt: now,
      lastActivityAt: now,
    );
    final firstPost = Post(
      id: 'p1',
      threadId: thread.id,
      userId: 'u1',
      type: PostType.tip,
      content: 'First',
      createdAt: now,
    );

    await composer.createThread(thread, firstPost);

    final controller = ThreadDetailController(repo, thread.id);
    final secondPost = Post(
      id: 'p2',
      threadId: thread.id,
      userId: 'u1',
      type: PostType.comment,
      content: 'Reply',
      createdAt: now.add(const Duration(minutes: 1)),
    );
    await controller.addPost(secondPost);
    await controller.voteOnPost(secondPost.id, 'u1');
    await controller.reportPost(
      Report(
        id: '',
        entityType: ReportEntityType.post,
        entityId: secondPost.id,
        reason: 'spam',
        reporterId: 'u1',
        createdAt: DateTime.now(),
      ),
    );

    final threadSnap = await fs.collection('threads').doc(thread.id).get();
    expect(threadSnap.data()?['postsCount'], 2);
    final voteSnap = await fs.collection('votes').doc('p2_u1').get();
    expect(voteSnap.exists, isTrue);
    final reports = await fs.collection('reports').get();
    expect(reports.docs.length, 1);
  });
}

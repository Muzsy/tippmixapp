import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/forum/data/firestore_forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';

void main() {
  late FakeFirebaseFirestore fs;
  late FirestoreForumRepository repo;

  setUp(() {
    fs = FakeFirebaseFirestore();
    repo = FirestoreForumRepository(fs);
  });

  test('addPost writes to thread subcollection', () async {
    await fs.collection('threads').doc('t1').set({
      'fixtureId': 'f1',
      'type': 'pre',
      'createdAt': Timestamp.now(),
    });
    final post = Post(
      id: 'p1',
      threadId: 't1',
      userId: 'u1',
      type: PostType.tip,
      content: 'hello',
      createdAt: DateTime.now(),
    );
    await repo.addPost(post);
    final snap = await fs.collection('threads/t1/posts').doc('p1').get();
    expect(snap.exists, isTrue);
  });

  test('addPost updates thread aggregates', () async {
    final now = DateTime.now();
    await fs.collection('threads').doc('t1').set({
      'fixtureId': 'f1',
      'type': 'pre',
      'createdAt': Timestamp.fromDate(now),
      'lastActivityAt': Timestamp.fromDate(now),
      'postsCount': 0,
    });
    final post = Post(
      id: 'p1',
      threadId: 't1',
      userId: 'u1',
      type: PostType.tip,
      content: 'hello',
      createdAt: now.add(const Duration(minutes: 1)),
    );
    await repo.addPost(post);
    final threadSnap = await fs.collection('threads').doc('t1').get();
    expect(threadSnap['postsCount'], 1);
    expect(
      (threadSnap['lastActivityAt'] as Timestamp).toDate(),
      post.createdAt,
    );
  });

  test('getPostsByThread returns ordered posts', () async {
    await fs.collection('threads').doc('t1').set({
      'fixtureId': 'f1',
      'type': 'pre',
      'createdAt': Timestamp.now(),
    });
    await fs.collection('threads/t1/posts').doc('p1').set({
      'userId': 'u1',
      'type': 'tip',
      'threadId': 't1',
      'content': 'old',
      'createdAt': Timestamp.fromDate(
        DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    });
    await fs.collection('threads/t1/posts').doc('p2').set({
      'userId': 'u1',
      'type': 'tip',
      'threadId': 't1',
      'content': 'new',
      'createdAt': Timestamp.now(),
    });

    final posts = await repo.getPostsByThread('t1').first;
    expect(posts.first.id, 'p2');
    expect(posts.last.id, 'p1');
  });

  test('addThread writes to threads collection', () async {
    final thread = Thread(
      id: 't1',
      title: 'Hello',
      type: ThreadType.general,
      createdBy: 'u1',
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    await repo.addThread(thread);
    final snap = await fs.collection('threads').doc('t1').get();
    expect(snap.exists, isTrue);
  });

  test('updateThread modifies fields', () async {
    await fs.collection('threads').doc('t1').set({
      'title': 't',
      'type': 'general',
      'createdBy': 'u1',
      'createdAt': Timestamp.now(),
      'lastActivityAt': Timestamp.now(),
    });
    await repo.updateThread('t1', {'locked': true});
    final snap = await fs.collection('threads').doc('t1').get();
    expect(snap['locked'], true);
  });

  test('deleteThread removes document', () async {
    await fs.collection('threads').doc('t1').set({
      'title': 't',
      'type': 'general',
      'createdBy': 'u1',
      'createdAt': Timestamp.now(),
      'lastActivityAt': Timestamp.now(),
    });
    await repo.deleteThread('t1');
    final snap = await fs.collection('threads').doc('t1').get();
    expect(snap.exists, isFalse);
  });

  test('deletePost decrements count and recomputes lastActivity', () async {
    final now = DateTime.now();
    await fs.collection('threads').doc('t1').set({
      'fixtureId': 'f1',
      'type': 'pre',
      'createdAt': Timestamp.fromDate(now),
      'lastActivityAt': Timestamp.fromDate(now),
      'postsCount': 2,
    });
    await fs.collection('threads/t1/posts').doc('p1').set({
      'userId': 'u1',
      'type': 'tip',
      'threadId': 't1',
      'content': 'old',
      'createdAt': Timestamp.fromDate(now.add(const Duration(minutes: 1))),
    });
    await fs.collection('threads/t1/posts').doc('p2').set({
      'userId': 'u1',
      'type': 'tip',
      'threadId': 't1',
      'content': 'new',
      'createdAt': Timestamp.fromDate(now.add(const Duration(minutes: 2))),
    });

    await repo.deletePost(threadId: 't1', postId: 'p2');
    final threadSnap = await fs.collection('threads').doc('t1').get();
    expect(threadSnap['postsCount'], 1);
    expect(
      (threadSnap['lastActivityAt'] as Timestamp).toDate(),
      DateTime.fromMillisecondsSinceEpoch(
          now.add(const Duration(minutes: 1)).millisecondsSinceEpoch),
    );
  });
}

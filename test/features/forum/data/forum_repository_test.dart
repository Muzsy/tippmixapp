import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/forum/data/firestore_forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';

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
      'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 1))),
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
}

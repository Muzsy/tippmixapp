import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/composer_controller.dart';

class _MockRepo extends Mock implements ForumRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(Thread(
      id: 't',
      title: 'a',
      type: ThreadType.general,
      createdBy: 'u',
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    ));
    registerFallbackValue(Post(
      id: 'p',
      threadId: 't',
      userId: 'u',
      type: PostType.tip,
      content: 'c',
      createdAt: DateTime.now(),
    ));
  });

  test('createThread writes thread and post', () async {
    final repo = _MockRepo();
    when(() => repo.addThread(any())).thenAnswer((_) async {});
    when(() => repo.addPost(any())).thenAnswer((_) async {});
    final controller = ComposerController(repo);
    final thread = Thread(
      id: 't1',
      title: 'x',
      type: ThreadType.general,
      createdBy: 'u1',
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    final post = Post(
      id: 'p1',
      threadId: 't1',
      userId: 'u1',
      type: PostType.tip,
      content: 'hi',
      createdAt: DateTime.now(),
    );
    final future = controller.createThread(thread, post);
    expect(controller.state, const AsyncLoading());
    await future;
    expect(controller.state, const AsyncData<void>(null));
    verify(() => repo.addThread(thread)).called(1);
    verify(() => repo.addPost(post)).called(1);
  });
}

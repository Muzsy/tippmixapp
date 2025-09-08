import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/thread_list_controller.dart';

class _MockRepo extends Mock implements ForumRepository {}

void main() {
  test('emits threads from repository', () async {
    final repo = _MockRepo();
    final threads = [
      Thread(
        id: 't1',
        title: 'hi',
        type: ThreadType.general,
        createdBy: 'u1',
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      ),
    ];
    when(
      () => repo.getRecentThreads(startAfter: any(named: 'startAfter')),
    ).thenAnswer((_) => Stream.value(threads));

    final controller = ThreadListController(repo);
    await Future.delayed(Duration.zero);
    expect(controller.state.value, threads);
    controller.dispose();
  });
}

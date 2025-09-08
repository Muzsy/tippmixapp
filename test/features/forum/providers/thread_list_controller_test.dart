import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';
import 'package:tipsterino/features/forum/providers/thread_list_controller.dart';

class _MockRepo extends Mock implements ForumRepository {}

void main() {
  test('merges pages without duplicates', () async {
    final repo = _MockRepo();
    final t1 = Thread(
      id: 't1',
      title: 'hi',
      type: ThreadType.general,
      createdBy: 'u1',
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    final t2 = Thread(
      id: 't2',
      title: 'yo',
      type: ThreadType.general,
      createdBy: 'u2',
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    when(
      () => repo.queryThreads(
        filter: any(named: 'filter'),
        sort: any(named: 'sort'),
        startAfter: any(named: 'startAfter'),
      ),
    ).thenAnswer((invocation) {
      final startAfter = invocation.namedArguments[#startAfter] as DateTime?;
      return Stream.value(startAfter == null ? [t1, t2] : [t2]);
    });

    final controller = ThreadListController(repo, const ForumFilterState());
    await Future.delayed(Duration.zero);
    controller.loadMore();
    await Future.delayed(Duration.zero);
    expect(controller.state.value, [t1, t2]);
    controller.dispose();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';
import 'package:tipsterino/features/forum/providers/thread_list_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/forum_screen.dart';
import '../mocks/fake_forum_repository.dart';

class _LoadMoreController extends ThreadListController {
  _LoadMoreController(List<Thread> threads)
      : super(FakeForumRepository(), const ForumFilterState()) {
    state = AsyncData(threads);
  }

  bool called = false;

  @override
  void loadMore() {
    called = true;
  }
}


void main() {
  testWidgets('scrolling triggers loadMore', (tester) async {
    final threads = List.generate(
      30,
      (i) => Thread(
        id: '$i',
        title: 'T$i',
        type: ThreadType.general,
        createdBy: 'u',
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      ),
    );
    final controller = _LoadMoreController(threads);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          threadListControllerProvider.overrideWith((ref) => controller),
        ],
          child: const MaterialApp(
            home: ForumScreen(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
      ),
    );
    await tester.pumpAndSettle();
    // Scroll near the end to trigger the listener threshold
    final listFinder = find.byType(ListView);
    await tester.dragUntilVisible(
      find.text('T29'),
      listFinder,
      const Offset(0, -300),
    );
    await tester.pump();
    expect(controller.called, isTrue);
  });
}

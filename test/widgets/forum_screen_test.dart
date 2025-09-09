import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';
import 'package:tipsterino/features/forum/providers/thread_list_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/l10n/app_localizations_en.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/forum_screen.dart';
import '../mocks/fake_forum_repository.dart';

class _FakeThreadListController extends ThreadListController {
  _FakeThreadListController(AsyncValue<List<Thread>> initial)
      : super(FakeForumRepository(), const ForumFilterState()) {
    state = initial;
  }
}

Widget _buildApp(AsyncValue<List<Thread>> state) {
  return ProviderScope(
    overrides: [
      threadListControllerProvider.overrideWith(
        (ref) => _FakeThreadListController(state),
      ),
    ],
    child: MaterialApp(
      home: const ForumScreen(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  testWidgets('shows empty state', (tester) async {
    await tester.pumpWidget(_buildApp(const AsyncData([])));
    await tester.pump();
    expect(find.text(AppLocalizationsEn().forum_empty), findsOneWidget);
  });

  testWidgets('shows error state', (tester) async {
    await tester.pumpWidget(
      _buildApp(const AsyncError('err', StackTrace.empty)),
    );
    await tester.pump();
    expect(find.text(AppLocalizationsEn().forum_error), findsOneWidget);
  });

  testWidgets('shows thread list', (tester) async {
    final threads = [
      Thread(
        id: '1',
        title: 'Thread 1',
        type: ThreadType.general,
        createdBy: 'u1',
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      ),
    ];
    await tester.pumpWidget(_buildApp(AsyncData(threads)));
    await tester.pump();
    expect(find.text('Thread 1'), findsOneWidget);
  });
}

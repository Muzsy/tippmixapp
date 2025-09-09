import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/thread_view_screen.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import '../mocks/fake_forum_repository.dart';

class _FakeController extends ThreadDetailController {
  _FakeController(AsyncValue<List<Post>> state)
      : super(FakeForumRepository(), 't1') {
    this.state = state;
  }
}

void main() {
  testWidgets('shows empty state when no posts', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          threadDetailControllerProviderFamily('t1').overrideWith(
            (ref) => _FakeController(const AsyncValue.data([])),
          ),
        ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ThreadViewScreen(threadId: 't1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No threads yet'), findsOneWidget);
  });
}

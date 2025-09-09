import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/composer_bar.dart';
import 'package:tipsterino/screens/forum/thread_view_screen.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import '../mocks/fake_forum_repository.dart';

class _FakeController extends ThreadDetailController {
  _FakeController() : super(FakeForumRepository(), 't1');

  bool addCalled = false;

  @override
  Future<void> addPost(Post post) async {
    addCalled = true;
  }
}

void main() {
  testWidgets('shows banner and prevents posting when locked', (tester) async {
    final controller = _FakeController();
    final lockedThread = Thread(
      id: 't1',
      title: 't1',
      type: ThreadType.general,
      createdBy: 'u1',
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
      locked: true,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          threadDetailControllerProviderFamily('t1').overrideWith((ref) => controller),
          threadProviderFamily.overrideWith((ref, id) => Stream.value(lockedThread)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ThreadViewScreen(threadId: 't1'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Thread is locked'), findsOneWidget);
    final composer = tester.widget<ComposerBar>(find.byType(ComposerBar));
    await composer.onSubmit!.call();
    await tester.pump();
    expect(controller.addCalled, isFalse);
  });

  testWidgets('composer enabled when unlocked', (tester) async {
    final thread = Thread(
      id: 't1',
      title: 't1',
      type: ThreadType.general,
      createdBy: 'u1',
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        threadDetailControllerProviderFamily('t1')
            .overrideWith((ref) => _FakeController()),
        threadProviderFamily.overrideWith((ref, id) => Stream.value(thread)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ThreadViewScreen(threadId: 't1'),
      ),
    ));
    final sendButton = find.widgetWithIcon(IconButton, Icons.send);
    expect(tester.widget<IconButton>(sendButton).onPressed, isNotNull);
    expect(find.text('Thread is locked'), findsNothing);
  });
}

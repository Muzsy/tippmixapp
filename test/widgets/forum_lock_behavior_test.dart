import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/thread_view_screen.dart';
import '../mocks/fake_forum_repository.dart';

class _FakeController extends ThreadDetailController {
  _FakeController() : super(FakeForumRepository(), 't1') {
    state = const AsyncData(<Post>[]);
  }
}

void main() {
  testWidgets('composer disables when thread locks', (tester) async {
    final controller = StreamController<Thread>();
    final base = Thread(
      id: 't1',
      title: 't1',
      type: ThreadType.general,
      createdBy: 'u1',
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    controller.add(base);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        threadDetailControllerProviderFamily('t1').overrideWith((ref) => _FakeController()),
        threadProviderFamily.overrideWith((ref, id) => controller.stream),
      ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ThreadViewScreen(threadId: 't1'),
        ),
    ));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);

    controller.add(base.copyWith(locked: true));
    await tester.pump();
    expect(find.byType(MaterialBanner), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    await controller.close();
  });
}

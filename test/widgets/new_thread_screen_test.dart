import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/composer_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/l10n/app_localizations_en.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/new_thread_screen.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/routes/app_route.dart';

import '../mocks/mock_auth_service.dart';
import '../mocks/fake_forum_repository.dart';

class _FakeComposer extends ComposerController {
  _FakeComposer() : super(FakeForumRepository());
  bool called = false;

  @override
  Future<void> createThread(Thread thread, Post firstPost) async {
    called = true;
  }
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier()
      : super(MockAuthService()) {
    state = AuthState(user: User(id: 'u1', email: 'e', displayName: 'Me'));
  }
}

Widget _buildApp(_FakeComposer composer) {
  return ProviderScope(
    overrides: [
      composerControllerProvider.overrideWith((ref) => composer),
      authProvider.overrideWith((ref) => _FakeAuthNotifier()),
    ],
      child: const MaterialApp(
        home: NewThreadScreen(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
  );
}

Widget _buildRouterApp(_FakeComposer composer) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const NewThreadScreen(),
      ),
      GoRoute(
        path: '/thread/:threadId',
        name: AppRoute.threadView.name,
        builder: (context, state) =>
            Text('Thread ${state.pathParameters['threadId']}'),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      composerControllerProvider.overrideWith((ref) => composer),
      authProvider.overrideWith((ref) => _FakeAuthNotifier()),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  testWidgets('button disabled when fields empty', (tester) async {
    final composer = _FakeComposer();
    await tester.pumpWidget(_buildApp(composer));
    final btn = tester.widget<ElevatedButton>(find.byKey(const Key('submit')));
    expect(btn.onPressed, isNull);
  });

  testWidgets('creates thread when valid', (tester) async {
    final composer = _FakeComposer();
    await tester.pumpWidget(_buildRouterApp(composer));
    await tester.enterText(find.byKey(const Key('title')), 'Hello');
    await tester.enterText(find.byKey(const Key('content')), 'First post');
    await tester.pump();
    await tester.tap(find.text(AppLocalizationsEn().btn_create_thread));
    await tester.pump();
    expect(composer.called, isTrue);
  });

  testWidgets('navigates to thread view after creation', (tester) async {
    final composer = _FakeComposer();
    await tester.pumpWidget(_buildRouterApp(composer));
    await tester.enterText(find.byKey(const Key('title')), 'Hi');
    await tester.enterText(find.byKey(const Key('content')), 'Post');
    await tester.pump();
    await tester.tap(find.text(AppLocalizationsEn().btn_create_thread));
    await tester.pumpAndSettle();
    expect(find.textContaining('Thread '), findsOneWidget);
  });
}

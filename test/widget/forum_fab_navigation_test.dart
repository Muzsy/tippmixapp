import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/features/forum/providers/composer_controller.dart';
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';
import 'package:tipsterino/features/forum/providers/thread_list_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/routes/app_route.dart';
import 'package:tipsterino/screens/forum/forum_screen.dart';
import 'package:tipsterino/screens/forum/new_thread_screen.dart';

import '../mocks/mock_auth_service.dart';
import '../mocks/fake_forum_repository.dart';

class _FakeComposer extends ComposerController {
  _FakeComposer() : super(FakeForumRepository());
}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier() : super(MockAuthService()) {
    state = AuthState(user: User(id: 'u1', email: '', displayName: '')); 
  }
}

void main() {
  testWidgets('FAB opens new thread form', (tester) async {
    final router = GoRouter(
      initialLocation: '/forum',
      routes: [
        GoRoute(
          path: '/forum',
          name: AppRoute.forum.name,
          builder: (context, state) => const ForumScreen(),
          routes: [
            GoRoute(
              path: 'new',
              name: AppRoute.newThread.name,
              builder: (context, state) => const NewThreadScreen(),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          composerControllerProvider.overrideWith((ref) => _FakeComposer()),
          authProvider.overrideWith((ref) => _FakeAuthNotifier()),
          threadListControllerProvider.overrideWith(
            (ref) => ThreadListController(FakeForumRepository(), const ForumFilterState()),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(NewThreadScreen), findsOneWidget);
  });
}

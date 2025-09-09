import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tipsterino/features/forum/providers/composer_controller.dart';
import 'package:tipsterino/screens/forum/new_thread_screen.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/l10n/app_localizations_en.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import '../mocks/mock_auth_service.dart';
import '../mocks/fake_forum_repository.dart';

class _Composer extends ComposerController {
  _Composer() : super(FakeForumRepository());
}

class _Auth extends AuthNotifier {
  _Auth() : super(MockAuthService()) {
    state = AuthState(user: User(id: 'u1', email: 'e', displayName: 'u'));
  }
}

void main() {
  testWidgets('requires fixture when match type selected', (tester) async {
    final composer = _Composer();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        composerControllerProvider.overrideWith((ref) => composer),
        authProvider.overrideWith((ref) => _Auth()),
      ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NewThreadScreen(),
        ),
    ));
    await tester.tap(find.byType(DropdownButtonFormField<ThreadType>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLocalizationsEn().thread_type_match).last);
    await tester.pump();
    expect(find.byKey(const Key('fixture')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('title')), 't');
    await tester.enterText(find.byKey(const Key('content')), 'c');
    await tester.enterText(find.byKey(const Key('fixture')), '1');
    await tester.pump();
    final btn = tester.widget<ElevatedButton>(find.byKey(const Key('submit')));
    expect(btn.onPressed, isNotNull);
  });
}

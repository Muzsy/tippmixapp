import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/l10n/app_localizations_en.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/providers/moderator_claim_provider.dart';
import 'package:tipsterino/screens/forum/thread_view_screen.dart';

import '../../mocks/fake_forum_repository.dart';
import '../../mocks/mock_auth_service.dart';

class _FakeAuth extends AuthNotifier {
  _FakeAuth() : super(MockAuthService()) {
    state = AuthState(user: User(id: 'u1', email: '', displayName: ''));
  }
}

class _DummyController extends ThreadDetailController {
  _DummyController() : super(FakeForumRepository(), 't1') {
    state = const AsyncData([]);
  }
}

final _lockedThread = Thread(
  id: 't1',
  title: 't',
  type: ThreadType.general,
  createdBy: 'u2',
  createdAt: DateTime(2024),
  locked: true,
  pinned: false,
  lastActivityAt: DateTime(2024),
);

Widget _buildApp() {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) => _FakeAuth()),
      forumRepositoryProvider.overrideWithValue(FakeForumRepository()),
      threadProviderFamily.overrideWith((ref, id) => Stream.value(_lockedThread)),
      threadDetailControllerProviderFamily('t1')
          .overrideWith((ref) => _DummyController()),
      threadDetailLoadingProviderFamily.overrideWithProvider(
        (id) => Provider((ref) => false),
      ),
      isModeratorProvider.overrideWithValue(false),
    ],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: false),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ThreadViewScreen(threadId: 't1'),
    ),
  );
}

void main() {
  testWidgets('composer disabled and banner visible when thread locked',
      (tester) async {
    await tester.pumpWidget(_buildApp());
      await tester.pump();
      expect(
        find.text(AppLocalizationsEn().forum_thread_locked_banner),
        findsWidgets,
      );
    final sendButton =
        tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send));
    expect(sendButton.onPressed, isNull);
  });
}

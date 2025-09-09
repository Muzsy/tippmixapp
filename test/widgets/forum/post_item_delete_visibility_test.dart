import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/providers/thread_detail_controller.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/moderator_claim_provider.dart';
import 'package:tipsterino/providers/forum_provider.dart';
import 'package:tipsterino/screens/forum/post_item.dart';

import '../../mocks/mock_auth_service.dart';
import '../../mocks/fake_forum_repository.dart';

class _FakeAuth extends AuthNotifier {
  _FakeAuth() : super(MockAuthService()) {
    state = AuthState(
      user: User(id: 'u1', email: '', displayName: ''),
    );
  }
}

class _DummyController extends ThreadDetailController {
  _DummyController() : super(FakeForumRepository(), 't1');
}

final _post = Post(
  id: 'p1',
  threadId: 't1',
  userId: 'u2',
  type: PostType.comment,
  content: 'Hello',
  createdAt: DateTime(2024),
);

Widget _buildApp({required bool isModerator}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) => _FakeAuth()),
      threadDetailControllerProviderFamily(
        't1',
      ).overrideWith((ref) => _DummyController()),
      isModeratorProvider.overrideWithValue(isModerator),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: PostItem(post: _post)),
    ),
  );
}

void main() {
  testWidgets('non-moderator does not see delete button', (tester) async {
    await tester.pumpWidget(_buildApp(isModerator: false));
    expect(find.byIcon(Icons.delete), findsNothing);
  });

  testWidgets('moderator sees delete button', (tester) async {
    await tester.pumpWidget(_buildApp(isModerator: true));
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });
}

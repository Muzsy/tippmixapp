import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/user_model.dart';
import 'package:tippmixapp/screens/profile/partials/notification_prefs_section.dart';
import 'package:tippmixapp/services/user_service.dart';

class FakeUserService extends UserService {
  int calls = 0;
  Map<String, bool>? last;
  FakeUserService(super.firestore);

  @override
  Future<UserModel> updateNotificationPrefs(
    String uid,
    Map<String, bool> prefs,
  ) async {
    calls++;
    last = Map.from(prefs);
    return UserModel(
      uid: uid,
      email: 'e',
      displayName: 'd',
      nickname: 'n',
      avatarUrl: 'a',
      isPrivate: false,
      fieldVisibility: const {},
      notificationPreferences: prefs,
    );
  }
}

void main() {
  testWidgets('toggle triggers service update', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final service = FakeUserService(firestore);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: NotificationPrefsSection(uid: 'u1', service: service),
        ),
      ),
    );

    await tester.tap(find.text('Tips'));
    await tester.pumpAndSettle();

    expect(service.calls, 1);
    expect(service.last?['tips'], isFalse);
  });
}

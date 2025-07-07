import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/user_model.dart';
import 'package:tippmixapp/screens/profile/edit_profile_screen.dart';
import 'package:tippmixapp/services/user_service.dart';

class FakeUserService extends UserService {
  FakeUserService(super.firestore);
  Map<String, dynamic>? last;
  @override
  Future<UserModel> updateProfile(String uid, Map<String, dynamic> changes) async {
    last = Map.from(changes);
    return UserModel(
      uid: uid,
      email: '',
      displayName: changes['displayName'] as String? ?? '',
      nickname: '',
      avatarUrl: '',
      isPrivate: false,
      fieldVisibility: const {},
    );
  }
}

void main() {
  testWidgets('happy path edit triggers service', (tester) async {
    final service = FakeUserService(null);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: EditProfileScreen(
        initial: UserModel(
          uid: 'u1',
          email: '',
          displayName: 'old',
          nickname: '',
          avatarUrl: '',
          isPrivate: false,
          fieldVisibility: const {},
        ),
        service: service,
      ),
    ));

    await tester.enterText(find.byType(TextFormField).first, 'newname');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(service.last?['displayName'], 'newname');
  });
}

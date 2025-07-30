import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/user_model.dart';
import 'package:tippmixapp/screens/profile/edit_profile_screen.dart';

void main() {
  testWidgets('invalid name shows error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
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
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'ab');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pump();

    expect(find.text('Name too short'), findsOneWidget);
  });
}

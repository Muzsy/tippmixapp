import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/l10n/app_localizations_en.dart';
import 'package:tippmixapp/models/user_model.dart';
import 'package:tippmixapp/screens/public_profile_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: child,
  );
}

void main() {
  testWidgets('private profile shows only nickname', (tester) async {
    final user = UserModel(
      uid: 'u1',
      email: 'a@b.com',
      displayName: 'Disp',
      nickname: 'Nick',
      avatarUrl: '',
      isPrivate: true,
      fieldVisibility: const {
        'city': true,
        'country': true,
      },
    );
    await tester.pumpWidget(_wrap(PublicProfileScreen(user: user)));
    await tester.pump();

    expect(find.text('Nick'), findsOneWidget);
    expect(find.text(AppLocalizationsEn().profile_city), findsNothing);
  });

  testWidgets('shows fields when public', (tester) async {
    final user = UserModel(
      uid: 'u1',
      email: 'a@b.com',
      displayName: 'Disp',
      nickname: 'Nick',
      avatarUrl: '',
      isPrivate: false,
      fieldVisibility: const {
        'city': true,
        'country': false,
      },
    );
    await tester.pumpWidget(_wrap(PublicProfileScreen(user: user)));
    await tester.pump();

    expect(find.text(AppLocalizationsEn().profile_city), findsOneWidget);
    expect(find.text(AppLocalizationsEn().profile_country), findsNothing);
  });
}

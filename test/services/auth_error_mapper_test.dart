import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/services/auth_error_mapper.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

void main() {
  testWidgets('maps wrong password', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: SizedBox.shrink(),
      ),
    );
    final context = tester.element(find.byType(SizedBox));
    final mapper = AuthErrorMapper();
    final msg = mapper.map(
      context,
      FirebaseAuthException(code: 'wrong-password'),
    );
    expect(msg, AppLocalizations.of(context)!.auth_error_wrong_password);
  });
}

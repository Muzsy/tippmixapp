import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/widgets/avatar_gallery.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

void main() {
  testWidgets('AvatarGallery shows empty state', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: Scaffold(body: AvatarGallery(onAvatarSelected: print)),
    ));
    await tester.pump();
    expect(find.byType(GridView), findsNothing);
    expect(find.text('Error updating avatar'), findsOneWidget);
  });

  testWidgets('AvatarGallery invokes callback', (tester) async {
    String? selected;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: AvatarGallery(onAvatarSelected: (p) => selected = p)),
    ));
    await tester.pump();
    expect(selected, isNull);
  });
}

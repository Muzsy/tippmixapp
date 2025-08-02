import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/l10n/app_localizations_en.dart';
import 'package:tippmixapp/models/user_model.dart';
import 'package:tippmixapp/screens/public_profile_screen.dart';
import 'package:tippmixapp/constants.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: child,
  );
}

void _mockAssets() {
  TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    final key = utf8.decode(message!.buffer.asUint8List());
    if (key == 'AssetManifest.bin') {
      final manifest = <String, Object?>{
        kDefaultAvatarPath: const [
          <String, Object?>{'asset': kDefaultAvatarPath},
        ],
      };
      return const StandardMessageCodec().encodeMessage(manifest)!;
    }
    if (key == 'AssetManifest.json') {
      final manifest = json.encode({
        kDefaultAvatarPath: const [
          <String, String>{'asset': kDefaultAvatarPath},
        ],
      });
      return ByteData.view(
        Uint8List.fromList(utf8.encode(manifest)).buffer,
      );
    }
    if (key == kDefaultAvatarPath) {
      return ByteData.view(Uint8List.fromList(_kTransparentImage).buffer);
    }
    return null;
  });
}

void _resetAssets() {
  TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', null);
}

const List<int> _kTransparentImage = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
];

void main() {
  setUp(_mockAssets);
  tearDown(_resetAssets);

  testWidgets('private profile shows only nickname', (tester) async {
    final user = UserModel(
      uid: 'u1',
      email: 'a@b.com',
      displayName: 'Disp',
      nickname: 'Nick',
      avatarUrl: kDefaultAvatarPath,
      isPrivate: true,
      fieldVisibility: const {'city': true, 'country': true},
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
      avatarUrl: kDefaultAvatarPath,
      isPrivate: false,
      fieldVisibility: const {'city': true, 'country': false},
    );
    await tester.pumpWidget(_wrap(PublicProfileScreen(user: user)));
    await tester.pump();

    expect(find.text(AppLocalizationsEn().profile_city), findsOneWidget);
    expect(find.text(AppLocalizationsEn().profile_country), findsNothing);
  });
}

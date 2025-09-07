import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/user_model.dart';
import 'package:tipsterino/screens/profile/edit_profile_screen.dart';
import 'package:tipsterino/services/user_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:tipsterino/constants.dart';

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
  testWidgets('invalid name shows error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: EditProfileScreen(
          initial: UserModel(
            uid: 'u1',
            email: 't@example.com',
            displayName: 'old',
            nickname: 'nick',
            avatarUrl: kDefaultAvatarPath,
            isPrivate: false,
            fieldVisibility: const {},
          ),
          service: UserService(FakeFirebaseFirestore()),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'ab');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pump();

    expect(find.text('name_error_short'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/user_model.dart';
import 'package:tippmixapp/screens/profile/edit_profile_screen.dart';
import 'package:tippmixapp/services/user_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:tippmixapp/constants.dart';

class _FakeUserService extends UserService {
  _FakeUserService(super.firestore);
  Map<String, dynamic>? last;
  @override
  Future<UserModel> updateProfile(String uid, Map<String, dynamic> changes) async {
    last = Map.from(changes);
    return UserModel(
      uid: uid,
      email: 'e',
      displayName: changes['displayName'] as String? ?? 'd',
      nickname: changes['nickname'] as String? ?? 'n',
      avatarUrl: 'a',
      isPrivate: false,
      fieldVisibility: const {},
    );
  }
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      if (key == 'AssetManifest.bin') {
        final manifest = <String, Object?>{
          'a': const [<String, Object?>{'asset': 'a'}],
          kDefaultAvatarPath: const [<String, Object?>{'asset': kDefaultAvatarPath}],
        };
        return const StandardMessageCodec().encodeMessage(manifest)!;
      }
      if (key == 'AssetManifest.json') {
        final manifest = json.encode({
          'a': const [<String, String>{'asset': 'a'}],
          kDefaultAvatarPath: const [<String, String>{'asset': kDefaultAvatarPath}],
        });
        return ByteData.view(Uint8List.fromList(utf8.encode(manifest)).buffer);
      }
      if (key == 'a' || key == kDefaultAvatarPath) {
        final bytes = Uint8List.fromList([
          0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,
          0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,0x08,0x06,0x00,0x00,0x00,0x1F,0x15,0xC4,
          0x89,0x00,0x00,0x00,0x0A,0x49,0x44,0x41,0x54,0x78,0x9C,0x63,0x00,0x01,0x00,0x00,
          0x05,0x00,0x01,0x0D,0x0A,0x2D,0xB4,0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44,0xAE
        ]);
        return ByteData.view(bytes.buffer);
      }
      return null;
    });
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  testWidgets('Edit Profile: nickname change persists', (tester) async {
    final service = _FakeUserService(FakeFirebaseFirestore());
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: EditProfileScreen(
          initial: UserModel(
            uid: 'u1',
            email: 'e',
            displayName: 'John',
            nickname: 'oldnick',
            avatarUrl: 'a',
            isPrivate: false,
            fieldVisibility: const {},
          ),
          service: service,
          checkNicknameUnique: (n) async => true,
        ),
      ),
    );

    // Name is first TextFormField, nickname is second
    await tester.enterText(find.byType(TextFormField).at(1), 'newnick');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(service.last?['nickname'], 'newnick');
  });
}

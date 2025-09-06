import 'package:flutter/material.dart';
import 'dart:convert';
// 'Uint8List' and 'ByteData' are available via flutter/services.dart in this test context
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/user_model.dart';
import 'package:tipsterino/screens/profile/edit_profile_screen.dart';
import 'package:tipsterino/services/user_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:tipsterino/constants.dart';
import 'package:cloud_functions/cloud_functions.dart';

class _FakeUserService extends UserService {
  _FakeUserService(super.firestore);
  Map<String, dynamic>? last;
  @override
  Future<UserModel> updateProfile(
    String uid,
    Map<String, dynamic> changes,
  ) async {
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

class _FakeCallableResult<T> implements HttpsCallableResult<T> {
  @override
  final T data;
  _FakeCallableResult(this.data);
}

class _FakeCallable extends Fake implements HttpsCallable {
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    return _FakeCallableResult<T>(null as T);
  }
}

class _FakeFunctions extends Fake implements FirebaseFunctions {
  final _callable = _FakeCallable();
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return _callable;
  }
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
          final key = utf8.decode(message!.buffer.asUint8List());
          if (key == 'AssetManifest.bin') {
            final manifest = <String, Object?>{
              'a': const [
                <String, Object?>{'asset': 'a'},
              ],
              kDefaultAvatarPath: const [
                <String, Object?>{'asset': kDefaultAvatarPath},
              ],
            };
            return const StandardMessageCodec().encodeMessage(manifest)!;
          }
          if (key == 'AssetManifest.json') {
            final manifest = json.encode({
              'a': const [
                <String, String>{'asset': 'a'},
              ],
              kDefaultAvatarPath: const [
                <String, String>{'asset': kDefaultAvatarPath},
              ],
            });
            return ByteData.view(
              Uint8List.fromList(utf8.encode(manifest)).buffer,
            );
          }
          if (key == 'a' || key == kDefaultAvatarPath) {
            final bytes = Uint8List.fromList([
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
          functions: _FakeFunctions(),
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

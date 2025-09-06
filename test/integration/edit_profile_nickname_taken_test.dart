import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/user_model.dart';
import 'package:tipsterino/screens/profile/edit_profile_screen.dart';
import 'package:tipsterino/services/user_service.dart';
import 'package:tipsterino/constants.dart';

class _ThrowAlreadyExists extends Fake implements HttpsCallable {
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    throw FirebaseFunctionsException(code: 'already-exists', message: '');
  }
}

class _FakeFunctions extends Fake implements FirebaseFunctions {
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    expect(name, 'reserve_nickname');
    return _ThrowAlreadyExists();
  }
}

class _CapturingUserService extends UserService {
  _CapturingUserService(super.firestore);
  bool called = false;
  Map<String, dynamic>? last;
  @override
  Future<UserModel> updateProfile(String uid, Map<String, dynamic> changes) async {
    called = true;
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
  testWidgets('Edit Profile: nickname taken shows error and skips update', (tester) async {
    final service = _CapturingUserService(FakeFirebaseFirestore());
    final functions = _FakeFunctions();

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
            nickname: 'old',
            avatarUrl: 'a',
            isPrivate: false,
            fieldVisibility: {},
          ),
          service: service,
          functions: functions,
        ),
      ),
    );

    // Change nickname to a taken one
    await tester.enterText(find.byType(TextFormField).at(1), 'taken');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    // Expect localized error text and no update call
    expect(find.text('Nickname already taken'), findsOneWidget);
    expect(service.called, isFalse);
    expect(service.last, isNull);
  });
}

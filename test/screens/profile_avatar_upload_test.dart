import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/models/auth_state.dart';
import 'package:tipsterino/models/user.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/screens/profile_screen.dart';
import 'package:tipsterino/services/auth_service.dart';
import 'dart:async';

class FakeFile extends Fake implements File {}

class FakeAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  User? _current;

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  Future<User?> signInWithEmail(String email, String password) async => null;

  @override
  Future<User?> registerWithEmail(String email, String password) async => null;

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  bool get isEmailVerified => true;

  @override
  User? get currentUser => _current;
  @override
  Future<bool> validateEmailUnique(String email) async => true;
  @override
  Future<bool> validateNicknameUnique(String nickname) async => true;

  @override
  Future<User?> signInWithGoogle() async => null;

  @override
  Future<User?> signInWithApple() async => null;

  @override
  Future<User?> signInWithFacebook() async => null;
  @override
  Future<bool> pollEmailVerification({
    Duration timeout = const Duration(minutes: 3),
    Duration interval = const Duration(seconds: 5),
  }) async => true;
  @override
  Future<void> confirmPasswordReset(String code, String newPassword) async {}
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(User user) : super(FakeAuthService()) {
    state = AuthState(user: user);
  }
}

class FakeImagePicker extends Fake implements ImagePicker {
  FakeImagePicker(this.result);
  final XFile? result;
  @override
  Future<XFile?> pickImage({
    int? imageQuality,
    double? maxHeight,
    double? maxWidth,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = false,
    required ImageSource source,
  }) async => result;
}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

class MockUploadTask extends Mock implements UploadTask {}

class MockTaskSnapshot extends Mock implements TaskSnapshot {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeFile());
    registerFallbackValue(Uint8List(0));
  });

  group('ProfileScreen.pickPhoto', () {
    late MockFirebaseStorage storage;
    late MockReference reference;
    late MockUploadTask task;
    late MockTaskSnapshot snapshot;
    late FakeFirebaseFirestore firestore;
    late User user;

    setUp(() {
      storage = MockFirebaseStorage();
      reference = MockReference();
      task = MockUploadTask();
      snapshot = MockTaskSnapshot();
      firestore = FakeFirebaseFirestore();
      when(() => storage.ref()).thenReturn(reference);
      when(() => reference.child(any())).thenReturn(reference);
      when(() => reference.putData(any(), any())).thenAnswer((_) => task);
      when(() => task.whenComplete(any())).thenAnswer((_) async => snapshot);
      when(
        () => reference.getDownloadURL(),
      ).thenAnswer((_) async => 'http://download');
      user = User(id: 'u1', email: 'e@x.com', displayName: 'Tester');
    });

    Future<File> pumpWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => FakeAuthNotifier(user)),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: [Locale('en'), Locale('hu'), Locale('de')],
            locale: Locale('en'),
            home: ProfileScreen(showAppBar: false),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final state = tester.state(find.byType(ProfileScreen)) as dynamic;
      final file = File('${Directory.systemTemp.createTempSync().path}/a.png')
        ..writeAsBytesSync(const [
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
      state.imagePicker = FakeImagePicker(XFile(file.path));
      state.storage = storage;
      state.firestore = firestore;
      return file;
    }

    testWidgets('successful upload shows snackbar', (tester) async {
      final file = await pumpWidget(tester);
      final state = tester.state(find.byType(ProfileScreen)) as dynamic;
      await tester.runAsync(() => state.pickPhoto(user));
      await tester.pump();
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      try {
        await file.parent.delete(recursive: true);
      } catch (_) {}
    }, skip: true);

    testWidgets('error shows snackbar', (tester) async {
      when(
        () => reference.putData(any(), any()),
      ).thenThrow(FirebaseException(plugin: 'storage'));
      final file = await pumpWidget(tester);
      final state = tester.state(find.byType(ProfileScreen)) as dynamic;
      await tester.runAsync(() => state.pickPhoto(user));
      await tester.pump();
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);
      try {
        await file.parent.delete(recursive: true);
      } catch (_) {}
    }, skip: true);
  });
}

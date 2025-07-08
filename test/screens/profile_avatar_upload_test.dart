import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/screens/profile_screen.dart';
import 'package:tippmixapp/services/auth_service.dart';
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
  Future<bool> validateEmailUnique(String email) async => true;

  @override
  Future<User?> signInWithGoogle() async => null;

  @override
  Future<User?> signInWithApple() async => null;

  @override
  Future<User?> signInWithFacebook() async => null;
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

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileScreen.pickPhoto', () {
    late MockFirebaseStorage storage;
    late MockReference reference;
    late MockUploadTask task;
    late FakeFirebaseFirestore firestore;
    late User user;

    setUp(() {
      storage = MockFirebaseStorage();
      reference = MockReference();
      task = MockUploadTask();
      firestore = FakeFirebaseFirestore();
      when(() => storage.ref()).thenReturn(reference);
      when(() => reference.child(any())).thenReturn(reference);
      when(() => reference.putFile(any())).thenAnswer((_) => task);
      when(
        () => reference.getDownloadURL(),
      ).thenAnswer((_) async => 'http://download');
      user = User(id: 'u1', email: 'e@x.com', displayName: 'Tester');
    });

    Future<void> pumpWidget(WidgetTester tester) async {
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
      state.imagePicker = FakeImagePicker(XFile('a.png'));
      state.storage = storage;
      state.firestore = firestore;
      return;
    }

    testWidgets('successful upload shows snackbar', (tester) async {
      await pumpWidget(tester);
      final state = tester.state(find.byType(ProfileScreen)) as dynamic;
      await state.pickPhoto(user);
      await tester.pumpAndSettle();
      expect(find.text('Error updating avatar'), findsOneWidget);
    });

    testWidgets('cancellation shows snackbar', (tester) async {
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
      state.imagePicker = FakeImagePicker(null);
      state.storage = storage;
      state.firestore = firestore;
      await state.pickPhoto(user);
      await tester.pump();
      expect(find.text('Avatar upload cancelled'), findsOneWidget);
    });

    testWidgets('error shows snackbar', (tester) async {
      when(
        () => reference.putFile(any()),
      ).thenThrow(FirebaseException(plugin: 'storage'));
      await pumpWidget(tester);
      final state = tester.state(find.byType(ProfileScreen)) as dynamic;
      await state.pickPhoto(user);
      await tester.pump();
      expect(find.text('Error updating avatar'), findsOneWidget);
    });
  });
}

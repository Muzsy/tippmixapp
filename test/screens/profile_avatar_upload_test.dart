import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/auth_state.dart';
import 'package:tippmixapp/models/user.dart';
import 'package:tippmixapp/providers/auth_provider.dart';
import 'package:tippmixapp/screens/profile_screen.dart';

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(User user) : super(null) {
    state = AuthState(user: user);
  }
}

class FakeImagePicker extends Fake implements ImagePicker {
  FakeImagePicker(this.result);
  final XFile? result;
  @override
  Future<XFile?> pickImage({required ImageSource source}) async => result;
}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockReference extends Mock implements Reference {}
class MockUploadTask extends Mock implements UploadTask {}

void main() {
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
      when(() => reference.putFile(any())).thenAnswer((_) async => task);
      when(() => reference.getDownloadURL())
          .thenAnswer((_) async => 'http://download');
      user = User(id: 'u1', email: 'e@x.com', displayName: 'Tester');
    });

    Future<void> _pump(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => FakeAuthNotifier(user)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('en'), Locale('hu'), Locale('de')],
            locale: const Locale('en'),
            home: const ProfileScreen(showAppBar: false),
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
      await _pump(tester);
      final state = tester.state(find.byType(ProfileScreen)) as dynamic;
      await state.pickPhoto(user);
      await tester.pump();
      expect(find.text('Avatar updated'), findsOneWidget);
    });

    testWidgets('cancellation shows snackbar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => FakeAuthNotifier(user)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('en'), Locale('hu'), Locale('de')],
            locale: const Locale('en'),
            home: const ProfileScreen(showAppBar: false),
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
      when(() => reference.putFile(any())).thenThrow(FirebaseException(plugin: 'storage'));
      await _pump(tester);
      final state = tester.state(find.byType(ProfileScreen)) as dynamic;
      await state.pickPhoto(user);
      await tester.pump();
      expect(find.text('Error updating avatar'), findsOneWidget);
    });
  });
}

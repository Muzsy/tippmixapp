import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tipsterino/services/auth_repository.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mockAuth = _MockAuth();
  test('email not in use returns true', () async {
    when(
      // ignore: deprecated_member_use
      () => mockAuth.fetchSignInMethodsForEmail(any()),
    ).thenAnswer((_) async => <String>[]);
    final repo = AuthRepository(firebaseAuth: mockAuth);
    expect(await repo.isEmailAvailable('x@y.hu'), true);
  });

  test('email exists returns false', () async {
    when(
      // ignore: deprecated_member_use
      () => mockAuth.fetchSignInMethodsForEmail(any()),
    ).thenAnswer((_) async => <String>['password']);
    final repo = AuthRepository(firebaseAuth: mockAuth);
    expect(await repo.isEmailAvailable('x@y.hu'), false);
  });
}

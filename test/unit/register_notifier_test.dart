import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tippmixapp/providers/register_state_notifier.dart';
import 'package:tippmixapp/services/auth_service.dart';

class _MockAuth extends Mock implements AuthService {}

void main() {
  test('completeRegistration awaits auth call', () async {
    final mockAuth = _MockAuth();
    var completed = false;
    when(() => mockAuth.registerWithEmail(any(), any())).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 10));
      completed = true;
      return null;
    });
    final notifier = RegisterStateNotifier(mockAuth);
    await notifier.completeRegistration();
    verify(() => mockAuth.registerWithEmail(any(), any())).called(1);
    expect(completed, isTrue);
  });
}

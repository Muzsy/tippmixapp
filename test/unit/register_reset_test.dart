import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/providers/register_state_notifier.dart';
import 'package:tipsterino/services/auth_service.dart';

class _FakeAuth extends Fake implements AuthService {}

void main() {
  test('reset clears state', () {
    final notifier = RegisterStateNotifier(_FakeAuth());
    notifier.state = notifier.state.copyWith(email: 'x@y.hu');
    expect(notifier.state.email, isNotEmpty);
    notifier.reset();
    expect(notifier.state.email, isEmpty);
  });
}

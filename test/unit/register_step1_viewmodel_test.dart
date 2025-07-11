import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/controllers/register_step1_viewmodel.dart';
import 'package:tippmixapp/services/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  bool throwConflict;
  FakeAuthRepository(this.throwConflict);
  @override
  Future<bool> isEmailAvailable(String email) async {
    if (throwConflict) {
      throw EmailAlreadyInUseFailure();
    }
    return true;
  }
}

void main() {
  test('emits emailExists when repository throws', () async {
    final vm = RegisterStep1ViewModel(FakeAuthRepository(true));
    await vm.checkEmail('a@b.com');
    expect(vm.state, RegisterStep1State.emailExists);
  });

  test('returns idle when email free', () async {
    final vm = RegisterStep1ViewModel(FakeAuthRepository(false));
    await vm.checkEmail('a@b.com');
    expect(vm.state, RegisterStep1State.idle);
  });
}

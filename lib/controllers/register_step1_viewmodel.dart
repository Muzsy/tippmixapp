import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_repository.dart';
import '../providers/auth_repository_provider.dart';

/// Possible states for the first registration step.
enum RegisterStep1State { idle, checkingEmail, emailExists }

class RegisterStep1ViewModel extends StateNotifier<RegisterStep1State> {
  final AuthRepository _repository;

  RegisterStep1ViewModel(this._repository) : super(RegisterStep1State.idle);

  /// Checks whether the given email already exists.
  Future<void> checkEmail(String email) async {
    state = RegisterStep1State.checkingEmail;
    try {
      await _repository.isEmailAvailable(email);
      state = RegisterStep1State.idle;
    } on EmailAlreadyInUseFailure {
      state = RegisterStep1State.emailExists;
    } finally {
      if (state != RegisterStep1State.emailExists) {
        state = RegisterStep1State.idle;
      }
    }
  }
}

final registerStep1ViewModelProvider =
    StateNotifierProvider<RegisterStep1ViewModel, RegisterStep1State>((ref) {
      final repo = ref.watch(authRepositoryProvider);
      return RegisterStep1ViewModel(repo);
    });

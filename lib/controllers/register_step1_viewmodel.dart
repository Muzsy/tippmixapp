import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Possible states for the first registration step.
enum RegisterStep1State { idle, checkingEmail, emailExists }

class RegisterStep1ViewModel extends StateNotifier<RegisterStep1State> {
  RegisterStep1ViewModel() : super(RegisterStep1State.idle);

  /// Minimal email check placeholder – always returns idle (no remote RC).
  Future<void> checkEmail(String email) async {
    state = RegisterStep1State.checkingEmail;
    state = RegisterStep1State.idle;
  }
}

final registerStep1ViewModelProvider =
    StateNotifierProvider<RegisterStep1ViewModel, RegisterStep1State>(
      (ref) => RegisterStep1ViewModel(),
    );

import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterData {
  final String email;
  final String password;

  const RegisterData({this.email = '', this.password = ''});

  RegisterData copyWith({String? email, String? password}) {
    return RegisterData(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class RegisterStateNotifier extends StateNotifier<RegisterData> {
  RegisterStateNotifier() : super(const RegisterData());

  void saveStep1(String email, String password) {
    state = state.copyWith(email: email, password: password);
  }
}

final registerStateNotifierProvider =
    StateNotifierProvider<RegisterStateNotifier, RegisterData>(
      (ref) => RegisterStateNotifier(),
    );

final registerPageControllerProvider = Provider.autoDispose<PageController>((
  ref,
) {
  final controller = PageController();
  ref.onDispose(controller.dispose);
  return controller;
});

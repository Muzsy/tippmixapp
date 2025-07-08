import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterData {
  final String email;
  final String password;
  final String nickname;
  final DateTime? birthDate;
  final bool gdprConsent;

  const RegisterData({
    this.email = '',
    this.password = '',
    this.nickname = '',
    this.birthDate,
    this.gdprConsent = false,
  });

  RegisterData copyWith({
    String? email,
    String? password,
    String? nickname,
    DateTime? birthDate,
    bool? gdprConsent,
  }) {
    return RegisterData(
      email: email ?? this.email,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      birthDate: birthDate ?? this.birthDate,
      gdprConsent: gdprConsent ?? this.gdprConsent,
    );
  }
}

class RegisterStateNotifier extends StateNotifier<RegisterData> {
  RegisterStateNotifier() : super(const RegisterData());

  void saveStep1(String email, String password) {
    state = state.copyWith(email: email, password: password);
  }

  void saveStep2(String nickname, DateTime birthDate, bool gdprConsent) {
    state = state.copyWith(
      nickname: nickname,
      birthDate: birthDate,
      gdprConsent: gdprConsent,
    );
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

import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/auth_service.dart';
import 'auth_provider.dart';
import '../services/profile_service.dart';
import '../models/user_model.dart';
import '../constants.dart';

class RegisterData {
  final String email;
  final String password;
  final String nickname;
  final DateTime? birthDate;
  final bool gdprConsent;
  final String avatarUrl;

  const RegisterData({
    this.email = '',
    this.password = '',
    this.nickname = '',
    this.birthDate,
    this.gdprConsent = false,
    this.avatarUrl = '',
  });

  RegisterData copyWith({
    String? email,
    String? password,
    String? nickname,
    DateTime? birthDate,
    bool? gdprConsent,
    String? avatarUrl,
  }) {
    return RegisterData(
      email: email ?? this.email,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      birthDate: birthDate ?? this.birthDate,
      gdprConsent: gdprConsent ?? this.gdprConsent,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class RegisterStateNotifier extends StateNotifier<RegisterData> {
  final AuthService _auth;
  RegisterStateNotifier(this._auth) : super(const RegisterData());

  void saveStep1(String email, String password) {
    state = state.copyWith(email: email, password: password);
  }

  void saveStep2(String nickname, DateTime birthDate, bool gdprConsent) {
    state = state.copyWith(nickname: nickname, birthDate: birthDate, gdprConsent: gdprConsent);
  }

  void saveAvatar(String url) {
    state = state.copyWith(avatarUrl: url);
  }

  Future<void> completeRegistration() async {
    // ignore: avoid_print
    print('[REGISTER] STARTED');
    final user = await _auth.registerWithEmail(state.email, state.password);
    // ignore: avoid_print
    print('[REGISTER] SUCCESS');
    if (user == null) return;
    if (Firebase.apps.isNotEmpty) {
      final model = UserModel(
        uid: user.id,
        email: state.email,
        displayName: state.nickname,
        nickname: state.nickname,
        avatarUrl: state.avatarUrl.isEmpty ? kDefaultAvatarPath : state.avatarUrl,
        isPrivate: false,
        fieldVisibility: const {},
        notificationPreferences: const {},
        dateOfBirth: state.birthDate,
      );
      await ProfileService.createUserProfile(model);
    }
  }
}

final registerStateNotifierProvider = StateNotifierProvider<RegisterStateNotifier, RegisterData>(
  (ref) => RegisterStateNotifier(ref.read(authServiceProvider)),
);

final registerPageControllerProvider = Provider.autoDispose<PageController>((ref) {
  final controller = PageController();
  ref.onDispose(controller.dispose);
  return controller;
});

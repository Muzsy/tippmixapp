import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../models/user_model.dart';

class UserService {
  UserService();

  Future<UserModel> updateNotificationPrefs(
    String uid,
    Map<String, bool> prefs,
  ) async {
    final client = sb.Supabase.instance.client;
    await client.from('user_settings').upsert({
      'user_id': uid,
      'notification_prefs': prefs,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
    final profRow = await client.from('profiles').select('*').eq('id', uid).maybeSingle();
    final settingsRow = await client.from('user_settings').select('*').eq('user_id', uid).maybeSingle();
    final p = (profRow as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final s = (settingsRow as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    return UserModel(
      uid: uid,
      email: (p['email'] as String?) ?? '',
      displayName: (p['display_name'] as String?) ?? '',
      nickname: (p['nickname'] as String?) ?? '',
      avatarUrl: (p['avatar_url'] as String?) ?? '',
      isPrivate: (p['is_private'] as bool?) ?? false,
      fieldVisibility: const {},
      notificationPreferences: Map<String, bool>.from(
        (s['notification_prefs'] as Map?) ?? const <String, bool>{},
      ),
    );
  }

  Future<UserModel> updateProfile(
    String uid,
    Map<String, dynamic> changes,
  ) async {
    final client = sb.Supabase.instance.client;
    final patch = <String, dynamic>{};
    if (changes.containsKey('email')) patch['email'] = changes['email'];
    if (changes.containsKey('displayName')) patch['display_name'] = changes['displayName'];
    if (changes.containsKey('nickname')) {
      final nick = changes['nickname'];
      patch['nickname'] = nick;
      if (nick is String) patch['nickname_norm'] = nick.trim().toLowerCase();
    }
    if (changes.containsKey('avatarUrl')) patch['avatar_url'] = changes['avatarUrl'];
    if (changes.containsKey('isPrivate')) patch['is_private'] = changes['isPrivate'];
    if (patch.isNotEmpty) {
      await client.from('profiles').update(patch).eq('id', uid);
    }
    final row = await client.from('profiles').select('*').eq('id', uid).maybeSingle();
    final p = (row as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    return UserModel(
      uid: uid,
      email: (p['email'] as String?) ?? '',
      displayName: (p['display_name'] as String?) ?? '',
      nickname: (p['nickname'] as String?) ?? '',
      avatarUrl: (p['avatar_url'] as String?) ?? '',
      isPrivate: (p['is_private'] as bool?) ?? false,
      fieldVisibility: const {},
    );
  }

  Future<void> markOnboardingCompleted(String uid) async {
    final client = sb.Supabase.instance.client;
    await client.from('user_settings').upsert({
      'user_id': uid,
      'onboarding_completed': true,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }
}

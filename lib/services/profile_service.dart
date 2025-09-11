import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'dart:io';
import '../models/user_model.dart';

class ProfileService {
  const ProfileService._();

  static Future<bool> isNicknameUnique(String nickname) async {
    String normalize(String input) {
      final s = input.trim().toLowerCase();
      const map = {
        'á': 'a',
        'é': 'e',
        'í': 'i',
        'ó': 'o',
        'ö': 'o',
        'ő': 'o',
        'ú': 'u',
        'ü': 'u',
        'ű': 'u',
        'ä': 'a',
        'ß': 'ss',
      };
      final buf = StringBuffer();
      for (final ch in s.split('')) {
        buf.write(map[ch] ?? ch);
      }
      return buf.toString().replaceAll(RegExp(r"\s+"), ' ');
    }

    final norm = normalize(nickname);
    final client = sb.Supabase.instance.client;
    final rows = await client
        .from('profiles')
        .select('id')
        .ilike('nickname_norm', norm)
        .limit(1);
    return (rows as List).isEmpty;
  }

  static Future<void> createUserProfile(UserModel user) async {
    final client = sb.Supabase.instance.client;
    await client.from('profiles').upsert({
      'id': user.uid,
      'email': user.email,
      'display_name': user.displayName,
      'nickname': user.nickname,
      'nickname_norm': user.nickname.trim().toLowerCase(),
      'avatar_url': user.avatarUrl,
      'is_private': user.isPrivate,
    }, onConflict: 'id');
  }

  static Stream<UserModel?> streamUserProfile(String uid) {
    return Stream.fromFuture(() async {
      final client = sb.Supabase.instance.client;
      final row = await client
          .from('profiles')
          .select('*')
          .eq('id', uid)
          .maybeSingle();
      final data = (row as Map?)?.cast<String, dynamic>();
      if (data == null) return null;
      return UserModel.fromJson({
        'uid': uid,
        'email': data['email'],
        'displayName': data['display_name'],
        'nickname': data['nickname'],
        'avatarUrl': data['avatar_url'],
        'isPrivate': data['is_private'] ?? false,
        'fieldVisibility': <String, bool>{},
      });
    }());
  }
  static Future<void> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    final client = sb.Supabase.instance.client;
    final patch = <String, dynamic>{};
    if (data.containsKey('email')) patch['email'] = data['email'];
    if (data.containsKey('displayName')) patch['display_name'] = data['displayName'];
    if (data.containsKey('nickname')) {
      final nick = data['nickname'];
      patch['nickname'] = nick;
      if (nick is String) patch['nickname_norm'] = nick.trim().toLowerCase();
    }
    if (data.containsKey('avatarUrl')) patch['avatar_url'] = data['avatarUrl'];
    if (data.containsKey('isPrivate')) patch['is_private'] = data['isPrivate'];
    if (data.containsKey('fieldVisibility')) {
      // Optional: store per-field prefs in user_settings if desired
    }
    if (patch.isNotEmpty) {
      await client.from('profiles').update(patch).eq('id', uid);
    }
  }

  static Future<String> uploadAvatar({
    required String uid,
    required File file,
  }) async {
    final client = sb.Supabase.instance.client;
    final raw = await file.readAsBytes();
    final path = 'avatars/$uid/avatar_256.png';
    await client.storage.from('avatars').uploadBinary(
          path,
          raw,
          fileOptions: const sb.FileOptions(contentType: 'image/png', upsert: true),
        );
    final url = await client.storage.from('avatars').createSignedUrl(path, 60 * 60 * 24);
    await updateProfile(uid: uid, data: {'avatarUrl': url});
    return url;
  }

}

class ProfileUpdateFailure implements Exception {}

class AvatarUploadFailure implements Exception {}

class ProfileServiceException implements Exception {}

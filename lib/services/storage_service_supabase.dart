import 'dart:typed_data';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/image_resizer.dart';

class SupabaseStorageService {
  SupabaseStorageService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<String> uploadAvatar(File image) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('No user');
    }
    Uint8List bytes = await image.readAsBytes();
    bytes = await ImageResizer.cropSquareResize256(bytes);
    final path = 'avatars/$uid/avatar_256.png';
    await _client.storage.from('avatars').uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/png', upsert: true));
    // Generate a signed URL valid for 24h
    final signed = await _client.storage.from('avatars').createSignedUrl(path, 60 * 60 * 24);
    return signed;
  }
}


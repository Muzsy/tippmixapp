import 'dart:io';
// No resizing here; handled by Supabase service if needed

import "package:flutter_riverpod/flutter_riverpod.dart";
import 'storage_service_supabase.dart';

class StorageServiceSupabaseWrapper {
  final SupabaseStorageService _inner;
  StorageServiceSupabaseWrapper([SupabaseStorageService? inner])
      : _inner = inner ?? SupabaseStorageService();

  Future<String> uploadAvatar(File image) => _inner.uploadAvatar(image);
}

final storageServiceProvider =
    Provider<dynamic>((ref) => StorageServiceSupabaseWrapper());

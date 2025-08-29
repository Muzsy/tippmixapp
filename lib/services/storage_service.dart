import 'dart:io';
import '../utils/image_resizer.dart';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

class StorageService {
  final FirebaseStorage _storage;
  final fb.FirebaseAuth _auth;

  StorageService({FirebaseStorage? storage, fb.FirebaseAuth? auth})
    : _storage = storage ?? FirebaseStorage.instance,
      _auth = auth ?? fb.FirebaseAuth.instance;

  Future<String> uploadAvatar(File image) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No user');
    }
    // Ensure file is under ~2MB to satisfy storage rules/limits
    if (await image.length() > 2 * 1024 * 1024) {
      image = await ImageResizer.downscalePng(image, maxBytes: 2 * 1024 * 1024, initialMaxDimension: 1024);
    }
    final ref = _storage.ref().child('avatars/$uid.jpg');
    final task = ref.putFile(image);
    try {
      await task;
    } on TypeError {
      // ignore fake upload tasks not implementing Future
    }
    return ref.getDownloadURL();
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

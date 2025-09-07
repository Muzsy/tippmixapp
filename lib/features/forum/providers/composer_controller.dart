import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/forum_repository.dart';
import '../domain/post.dart';
import '../domain/thread.dart';

/// Handles creating new threads and posts.
class ComposerController extends StateNotifier<AsyncValue<void>> {
  ComposerController(this._repository) : super(const AsyncData(null));

  final ForumRepository _repository;

  /// Creates a thread with its first post.
  Future<void> createThread(Thread thread, Post firstPost) async {
    state = const AsyncLoading();
    try {
      await _repository.addThread(thread);
      await _repository.addPost(firstPost);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

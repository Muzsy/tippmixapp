import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/forum/data/firestore_forum_repository.dart';
import '../features/forum/data/forum_repository.dart';
import '../features/forum/domain/thread.dart';
import '../features/forum/providers/forum_filter_state.dart';
import '../features/forum/providers/thread_list_controller.dart';

/// Provides the [ForumRepository] implementation.
final forumRepositoryProvider = Provider<ForumRepository>(
  (ref) => FirestoreForumRepository(FirebaseFirestore.instance),
);

/// Holds the current filter and sort state.
final forumFilterProvider =
    StateProvider<ForumFilterState>((ref) => const ForumFilterState());

/// Exposes the list of threads based on [forumFilterProvider].
final threadListControllerProvider = StateNotifierProvider<
    ThreadListController, AsyncValue<List<Thread>>>(
  (ref) {
    final repo = ref.watch(forumRepositoryProvider);
    final filter = ref.watch(forumFilterProvider);
    return ThreadListController(repo, filter);
  },
);

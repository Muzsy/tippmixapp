import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/forum/data/firestore_forum_repository.dart';
import '../features/forum/data/forum_repository.dart';
import '../features/forum/domain/thread.dart';
import '../features/forum/providers/forum_filter_state.dart';
import '../features/forum/providers/thread_list_controller.dart';
import '../features/forum/providers/composer_controller.dart';
import '../features/forum/providers/thread_detail_controller.dart';
import '../features/forum/domain/post.dart';
import 'admin_provider.dart';

/// Provides the [ForumRepository] implementation.
final forumRepositoryProvider = Provider<ForumRepository>(
  (ref) => FirestoreForumRepository(FirebaseFirestore.instance),
);

/// Holds the current filter and sort state.
final forumFilterProvider = StateProvider<ForumFilterState>(
  (ref) => const ForumFilterState(),
);

/// Exposes the list of threads based on [forumFilterProvider].
final threadListControllerProvider =
    StateNotifierProvider<ThreadListController, AsyncValue<List<Thread>>>((
      ref,
    ) {
      final repo = ref.watch(forumRepositoryProvider);
      final filter = ref.watch(forumFilterProvider);
      return ThreadListController(repo, filter);
    });

final threadListLoadingProvider = Provider<bool>(
  (ref) => ref.watch(threadListControllerProvider.notifier).isLoadingMore,
);

/// Handles composing new threads and first posts.
final composerControllerProvider =
    StateNotifierProvider<ComposerController, AsyncValue<void>>(
      (ref) => ComposerController(ref.watch(forumRepositoryProvider)),
    );

/// Exposes [ThreadDetailController] for a given thread.
final threadDetailControllerProviderFamily =
    StateNotifierProvider.family<
      ThreadDetailController,
      AsyncValue<List<Post>>,
      String
    >(
      (ref, threadId) =>
          ThreadDetailController(ref.watch(forumRepositoryProvider), threadId),
    );

final threadDetailLoadingProviderFamily = Provider.family<bool, String>(
  (ref, threadId) =>
      ref.watch(threadDetailControllerProviderFamily(threadId).notifier)
          .isLoadingMore,
);

/// Provides a single thread stream by id.
final threadProviderFamily = StreamProvider.family<Thread, String>(
  (ref, threadId) =>
      ref.watch(forumRepositoryProvider).watchThread(threadId),
);

final isModeratorProvider = Provider<bool>(
  (ref) => ref.watch(isAdminProvider),
);

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/forum_repository.dart';
import '../domain/post.dart';
import '../domain/report.dart';

/// Manages a single thread's post list and actions.
class ThreadDetailController extends StateNotifier<AsyncValue<List<Post>>> {
  ThreadDetailController(this._repository, this.threadId)
      : super(const AsyncLoading()) {
    _subscribe();
  }

  final ForumRepository _repository;
  final String threadId;
  StreamSubscription<List<Post>>? _sub;
  DateTime? _last;

  void _subscribe({DateTime? startAfter}) {
    _sub?.cancel();
    final stream =
        _repository.getPostsByThread(threadId, startAfter: startAfter);
    _sub = stream.listen(
      (posts) {
        _last = posts.isNotEmpty ? posts.last.createdAt : _last;
        state = AsyncData([
          if (startAfter != null && state.hasValue) ...state.value!,
          ...posts,
        ]);
      },
      onError: (e, st) => state = AsyncError(e, st),
    );
  }

  /// Loads the next page of posts.
  void loadMore() => _subscribe(startAfter: _last);

  Future<void> addPost(Post post) => _repository.addPost(post);

  Future<void> updatePost(String postId, String content) => _repository
      .updatePost(threadId: threadId, postId: postId, content: content);

  Future<void> deletePost(String postId) =>
      _repository.deletePost(threadId: threadId, postId: postId);

  Future<void> voteOnPost(String postId, String userId) =>
      _repository.voteOnPost(postId: postId, userId: userId); // userId == auth.uid

  Future<void> reportPost(Report report) => _repository.reportPost(report);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

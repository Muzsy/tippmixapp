import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/forum_repository.dart';
import '../domain/thread.dart';

/// Controls the list of forum threads based on [ForumFilterState].
class ThreadListController extends StateNotifier<AsyncValue<List<Thread>>> {
  ThreadListController(this._repository) : super(const AsyncLoading()) {
    _subscribe();
  }

  final ForumRepository _repository;
  StreamSubscription<List<Thread>>? _sub;
  DateTime? _last;

  void _subscribe({DateTime? startAfter}) {
    _sub?.cancel();
    final stream = _repository.getRecentThreads(startAfter: startAfter);
    _sub = stream.listen((threads) {
      _last = threads.isNotEmpty ? threads.last.createdAt : _last;
      state = AsyncData([
        if (startAfter != null && state.hasValue) ...state.value!,
        ...threads,
      ]);
    }, onError: (e, st) => state = AsyncError(e, st));
  }

  /// Loads the next page of threads.
  void loadMore() => _subscribe(startAfter: _last);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

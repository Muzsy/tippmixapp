import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/forum_repository.dart';
import '../domain/thread.dart';
import 'forum_filter_state.dart';

/// Controls the list of forum threads based on [ForumFilterState].
class ThreadListController extends StateNotifier<AsyncValue<List<Thread>>> {
  ThreadListController(this._repository, this._filter)
      : super(const AsyncLoading()) {
    _subscribe();
  }

  final ForumRepository _repository;
  final ForumFilterState _filter;
  StreamSubscription<List<Thread>>? _sub;
  DateTime? _last;
  bool _isLoadingMore = false;

  bool get isLoadingMore => _isLoadingMore;

  void _subscribe({DateTime? startAfter}) {
    _sub?.cancel();
    if (startAfter != null) {
      _isLoadingMore = true;
    }
    final stream = _repository.queryThreads(
      filter: _filter.filter,
      sort: _filter.sort,
      startAfter: startAfter,
    );
    _sub = stream.listen((threads) {
      _last = threads.isNotEmpty
          ? (_filter.sort == ForumSort.latest
              ? threads.last.lastActivityAt
              : threads.last.createdAt)
          : _last;
      final existing =
          startAfter != null && state.hasValue ? state.value! : <Thread>[];
      final combined = [...existing, ...threads];
      final unique = {
        for (final t in combined) t.id: t,
      }.values.toList();
      state = AsyncData(unique);
      _isLoadingMore = false;
    }, onError: (e, st) {
      state = AsyncError(e, st);
      _isLoadingMore = false;
    });
  }

  /// Loads the next page of threads.
  void loadMore() {
    if (_isLoadingMore) return;
    _subscribe(startAfter: _last);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

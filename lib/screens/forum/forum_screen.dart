import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/forum/providers/forum_filter_state.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/forum_provider.dart';
import '../../routes/app_route.dart';

/// Displays a list of forum threads with filtering, sorting and pagination.
class ForumScreen extends ConsumerStatefulWidget {
  const ForumScreen({super.key});

  @override
  ConsumerState<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends ConsumerState<ForumScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(threadListControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final threadsAsync = ref.watch(threadListControllerProvider);
    final filter = ref.watch(forumFilterProvider);
    final isLoadingMore = ref.watch(threadListLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.forum_title),
        actions: [
          PopupMenuButton<ForumSort>(
            onSelected: (value) =>
                ref.read(forumFilterProvider.notifier).state =
                    filter.copyWith(sort: value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ForumSort.latest,
                child: Text(loc.forum_sort_latest),
              ),
              PopupMenuItem(
                value: ForumSort.newest,
                child: Text(loc.forum_sort_newest),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButton<ForumFilter>(
              value: filter.filter,
              onChanged: (value) {
                if (value != null) {
                  ref.read(forumFilterProvider.notifier).state =
                      filter.copyWith(filter: value);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ForumFilter.all,
                  child: Text(loc.forum_filter_all),
                ),
                DropdownMenuItem(
                  value: ForumFilter.matches,
                  child: Text(loc.forum_filter_matches),
                ),
                DropdownMenuItem(
                  value: ForumFilter.general,
                  child: Text(loc.forum_filter_general),
                ),
                DropdownMenuItem(
                  value: ForumFilter.pinned,
                  child: Text(loc.forum_filter_pinned),
                ),
              ],
            ),
          ),
          Expanded(
            child: threadsAsync.when(
              data: (threads) {
                if (threads.isEmpty) {
                  return Center(child: Text(loc.forum_empty));
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: threads.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == threads.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final thread = threads[index];
                    return ListTile(
                      title: Text(thread.title),
                      subtitle: Text('${thread.postsCount}'),
                      leading:
                          thread.pinned ? const Icon(Icons.push_pin) : null,
                      trailing: thread.locked ? const Icon(Icons.lock) : null,
                      onTap: () => context.pushNamed(
                        AppRoute.threadView.name,
                        pathParameters: {'threadId': thread.id},
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(loc.forum_error)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AppRoute.newThread.name),
        child: const Icon(Icons.add),
      ),
    );
  }
}

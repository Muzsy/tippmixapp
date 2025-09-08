import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/forum/providers/forum_filter_state.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/forum_provider.dart';
import '../../routes/app_route.dart';
import 'package:go_router/go_router.dart';

/// Displays a list of forum threads with basic filtering and sorting.
class ForumScreen extends ConsumerWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final threadsAsync = ref.watch(threadListControllerProvider);
    final filter = ref.watch(forumFilterProvider);

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
                  itemCount: threads.length,
                  itemBuilder: (context, index) {
                    final thread = threads[index];
                    return ListTile(
                      title: Text(thread.title),
                      subtitle: Text('${thread.postsCount}'),
                      leading:
                          thread.pinned ? const Icon(Icons.push_pin) : null,
                      trailing: thread.locked ? const Icon(Icons.lock) : null,
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/forum_provider.dart';

import 'composer_bar.dart';
import 'post_item.dart';

class ThreadViewScreen extends ConsumerStatefulWidget {
  const ThreadViewScreen({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<ThreadViewScreen> createState() => _ThreadViewScreenState();
}

class _ThreadViewScreenState extends ConsumerState<ThreadViewScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  String? _quotedPostId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref
            .read(threadDetailControllerProviderFamily(widget.threadId).notifier)
            .loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final postsAsync =
        ref.watch(threadDetailControllerProviderFamily(widget.threadId));
    final isLoadingMore =
        ref.watch(threadDetailLoadingProviderFamily(widget.threadId));
    final threadAsync = ref.watch(threadProviderFamily(widget.threadId));
    final locked = threadAsync.asData?.value.locked ?? false;
    final pinned = threadAsync.asData?.value.pinned ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Thread'),
            if (pinned) const Icon(Icons.push_pin),
          ],
        ),
      ),
      body: Column(
        children: [
          if (locked)
            MaterialBanner(
              content: Text(loc.forum_thread_locked_banner),
              actions: [
                TextButton(onPressed: () {}, child: Text(loc.ok)),
              ],
            ),
          Expanded(
            child: postsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return Center(child: Text(loc.forum_empty));
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: posts.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == posts.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final post = posts[index];
                    Post? quoted;
                    try {
                      quoted = posts.firstWhere(
                        (p) => p.id == post.quotedPostId,
                      );
                    } catch (_) {
                      quoted = null;
                    }
                    return PostItem(
                      post: post,
                      quotedPost: quoted,
                      onReply: () {
                        _quotedPostId = post.id;
                        _textController.text = '@${post.userId} ';
                        _focusNode.requestFocus();
                      },
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
      bottomNavigationBar: ComposerBar(
        controller: _textController,
        focusNode: _focusNode,
        enabled: !locked,
        onSubmit: () async {
          if (locked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.forum_thread_locked_banner)),
            );
            return;
          }
          final text = _textController.text.trim();
          final user = ref.read(authProvider).user;
          if (text.isEmpty || user == null) return;
          final post = Post(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            threadId: widget.threadId,
            userId: user.id, // uses auth uid per rules
            type: PostType.comment,
            content: text,
            createdAt: DateTime.now(),
            quotedPostId: _quotedPostId,
          );
          await ref
              .read(threadDetailControllerProviderFamily(widget.threadId).notifier)
              .addPost(post);
          _textController.clear();
          _quotedPostId = null;
        },
      ),
    );
  }
}

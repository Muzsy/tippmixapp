import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/forum_provider.dart';

import 'composer_bar.dart';
import 'post_item.dart';

class ThreadViewScreen extends ConsumerStatefulWidget {
  const ThreadViewScreen({super.key, required this.threadId, this.locked = false});

  final String threadId;
  final bool locked;

  @override
  ConsumerState<ThreadViewScreen> createState() => _ThreadViewScreenState();
}

class _ThreadViewScreenState extends ConsumerState<ThreadViewScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final postsAsync =
        ref.watch(threadDetailControllerProviderFamily(widget.threadId));
    return Scaffold(
      appBar: AppBar(title: Text('Thread')),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return Center(child: Text(loc.forum_empty));
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: posts.length,
            itemBuilder: (context, index) => PostItem(post: posts[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(loc.forum_error)),
      ),
      bottomNavigationBar: ComposerBar(
        controller: _textController,
        enabled: !widget.locked,
        onSubmit: () async {
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
          );
          await ref
              .read(threadDetailControllerProviderFamily(widget.threadId).notifier)
              .addPost(post);
          _textController.clear();
        },
      ),
    );
  }
}

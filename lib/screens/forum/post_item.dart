import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/forum_provider.dart';

class PostItem extends ConsumerWidget {
  const PostItem({super.key, required this.post, this.onReply});

  final Post post;
  final VoidCallback? onReply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    final isOwner = user?.id == post.userId;
    return ListTile(
      title: Text(post.content),
      subtitle: Text(post.userId),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.reply),
            tooltip: loc.dialog_comment_title,
            onPressed: onReply,
          ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: loc.edit_title,
              onPressed: () async {
                final controller = TextEditingController(text: post.content);
                final result = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(loc.edit_title),
                    content: TextField(controller: controller),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(loc.dialog_cancel),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, controller.text.trim()),
                        child: Text(loc.dialog_send),
                      ),
                    ],
                  ),
                );
                if (result != null && result.isNotEmpty) {
                  await ref
                      .read(threadDetailControllerProviderFamily(post.threadId)
                          .notifier)
                      .updatePost(post.id, result);
                }
              },
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: loc.dialog_cancel,
              onPressed: () async {
                await ref
                    .read(threadDetailControllerProviderFamily(post.threadId)
                        .notifier)
                    .deletePost(post.id);
              },
            ),
          IconButton(
            icon: const Icon(Icons.thumb_up),
            tooltip: loc.feed_like,
            onPressed: () {
              final uid = user?.id;
              if (uid != null) {
                ref
                    .read(threadDetailControllerProviderFamily(post.threadId)
                        .notifier)
                    .voteOnPost(post.id, uid);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.flag),
            tooltip: loc.feed_report,
            onPressed: () {
              final uid = user?.id;
              if (uid != null) {
                final report = Report(
                  id: '',
                  entityType: ReportEntityType.post,
                  entityId: post.id,
                  reason: 'inappropriate',
                  reporterId: uid,
                  createdAt: DateTime.now(),
                );
                ref
                    .read(threadDetailControllerProviderFamily(post.threadId)
                        .notifier)
                    .reportPost(report);
              }
            },
          ),
        ],
      ),
    );
  }
}

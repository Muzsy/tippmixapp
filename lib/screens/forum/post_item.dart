import 'package:flutter/material.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

class PostItem extends StatelessWidget {
  const PostItem({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ListTile(
      title: Text(post.content),
      subtitle: Text(post.userId),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.reply),
            tooltip: loc.dialog_comment_title,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: loc.edit_title,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: loc.dialog_cancel,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.thumb_up),
            tooltip: loc.feed_like,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.flag),
            tooltip: loc.feed_report,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

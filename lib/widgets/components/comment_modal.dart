import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import '../../models/feed_event_type.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';

class CommentModal extends ConsumerStatefulWidget {
  final String postId;
  const CommentModal({super.key, required this.postId});

  @override
  ConsumerState<CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends ConsumerState<CommentModal> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(loc.dialog_comment_title),
      content: TextField(
        controller: _controller,
        maxLength: 250,
        maxLines: 3,
        decoration: InputDecoration(hintText: loc.dialog_add_comment_hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.dialog_cancel),
        ),
        TextButton(
          onPressed: () async {
            final user = ref.read(authProvider).user;
            if (user == null) return;
            final service = ref.read(feedServiceProvider);
            await service.addFeedEntry(
              userId: user.id,
              eventType: FeedEventType.comment,
              message: _controller.text,
              extraData: {'postId': widget.postId},
            );
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: Text(loc.dialog_send),
        ),
      ],
    );
  }
}

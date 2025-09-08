import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/features/forum/domain/post.dart';
import 'package:tipsterino/features/forum/domain/report.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/providers/auth_provider.dart';
import 'package:tipsterino/providers/forum_provider.dart';

class PostItem extends ConsumerStatefulWidget {
  const PostItem({super.key, required this.post, this.onReply});

  final Post post;
  final VoidCallback? onReply;

  @override
  ConsumerState<PostItem> createState() => _PostItemState();
}

class _PostItemState extends ConsumerState<PostItem> {
  bool _loading = false;
  bool _liked = false;

  Future<void> _showError(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(loc.unknown_error_try_again)));
  }

  Future<void> _onReport(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final user = ref.read(authProvider).user;
    if (user == null) return;
    String reason = 'spam';
    final noteController = TextEditingController();
    final result = await showDialog<(String, String?)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.report_dialog_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: reason,
              decoration:
                  InputDecoration(labelText: loc.report_reason_label),
              items: [
                DropdownMenuItem(
                  value: 'spam',
                  child: Text(loc.report_reason_spam),
                ),
                DropdownMenuItem(
                  value: 'abuse',
                  child: Text(loc.report_reason_abuse),
                ),
                DropdownMenuItem(
                  value: 'off_topic',
                  child: Text(loc.report_reason_off_topic),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Text(loc.report_reason_other),
                ),
              ],
              onChanged: (v) => reason = v ?? 'spam',
            ),
            TextField(
              controller: noteController,
              decoration: InputDecoration(labelText: loc.report_note_label),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.dialog_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              (
                reason,
                noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim(),
              ),
            ),
            child: Text(loc.dialog_send),
          ),
        ],
      ),
    );
    if (result != null) {
      final report = Report(
        id: '',
        entityType: ReportEntityType.post,
        entityId: widget.post.id,
        reporterId: user.id, // reporterId must equal auth.uid
        reason: result.$1,
        message: result.$2,
        createdAt: DateTime.now(),
      );
      setState(() => _loading = true);
      try {
        await ref
            .read(
                threadDetailControllerProviderFamily(widget.post.threadId)
                    .notifier)
            .reportPost(report);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.feed_report_success)),
          );
        }
      } catch (_) {
        await _showError(context);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    final isOwner = user?.id == widget.post.userId;
    return ListTile(
      title: Text(widget.post.content),
      subtitle: Text(widget.post.userId),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.reply),
            tooltip: loc.dialog_comment_title,
            onPressed: _loading ? null : widget.onReply,
          ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: loc.edit_title,
              onPressed: _loading
                  ? null
                  : () async {
                      final controller =
                          TextEditingController(text: widget.post.content);
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
                              onPressed: () => Navigator.pop(
                                  context, controller.text.trim()),
                              child: Text(loc.dialog_send),
                            ),
                          ],
                        ),
                      );
                      if (result != null && result.isNotEmpty) {
                        setState(() => _loading = true);
                        try {
                          await ref
                              .read(threadDetailControllerProviderFamily(
                                      widget.post.threadId)
                                  .notifier)
                              .updatePost(widget.post.id, result);
                        } catch (_) {
                          await _showError(context);
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      }
                    },
            ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: loc.dialog_cancel,
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      try {
                        await ref
                            .read(threadDetailControllerProviderFamily(
                                    widget.post.threadId)
                                .notifier)
                            .deletePost(widget.post.id);
                      } catch (_) {
                        await _showError(context);
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
            ),
          IconButton(
            icon: Icon(Icons.thumb_up,
                color: _liked
                    ? Theme.of(context).colorScheme.primary
                    : null),
            tooltip: loc.feed_like,
            onPressed: _loading
                ? null
                : () async {
                    final uid = user?.id; // auth.uid for vote idempotency
                    if (uid != null) {
                      setState(() {
                        _liked = !_liked;
                        _loading = true;
                      });
                      try {
                        await ref
                            .read(threadDetailControllerProviderFamily(
                                    widget.post.threadId)
                                .notifier)
                            .voteOnPost(widget.post.id, uid);
                      } catch (_) {
                        setState(() => _liked = !_liked); // revert
                        await _showError(context);
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.flag),
            tooltip: loc.feed_report,
            onPressed: _loading ? null : () => _onReport(context),
          ),
        ],
      ),
    );
  }
}

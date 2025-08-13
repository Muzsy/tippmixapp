import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tippmixapp/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';

class ReportDialog extends ConsumerStatefulWidget {
  final String postId;
  const ReportDialog({super.key, required this.postId});

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
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
      title: Text(loc.feed_report),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: loc.dialog_reason_hint),
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
            await service.reportFeedItem(
              userId: user.id,
              targetId: widget.postId,
              targetType: 'feed',
              reason: _controller.text,
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

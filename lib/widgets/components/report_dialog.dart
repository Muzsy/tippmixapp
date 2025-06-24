import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return AlertDialog(
      title: const Text('Report'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Reason'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final user = ref.read(authProvider);
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
          child: const Text('Send'),
        ),
      ],
    );
  }
}

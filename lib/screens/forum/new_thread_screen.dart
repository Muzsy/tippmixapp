import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/forum/domain/post.dart';
import '../../features/forum/domain/thread.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/forum_provider.dart';

/// Screen for composing a new forum thread with its first post.
class NewThreadScreen extends ConsumerStatefulWidget {
  const NewThreadScreen({super.key});

  @override
  ConsumerState<NewThreadScreen> createState() => _NewThreadScreenState();
}

class _NewThreadScreenState extends ConsumerState<NewThreadScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  bool get _isValid =>
      _titleCtrl.text.trim().isNotEmpty && _contentCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_onChanged);
    _contentCtrl.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    final controller = ref.read(composerControllerProvider.notifier);
    final user = ref.read(authProvider).user;
    if (user == null) return; // requires authentication
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final thread = Thread(
      id: id,
      title: _titleCtrl.text.trim(),
      type: ThreadType.general,
      createdBy: user.id, // uses auth uid per rules
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    final post = Post(
      id: '${id}_p1',
      threadId: id,
      userId: user.id, // uses auth uid per rules
      type: PostType.comment,
      content: _contentCtrl.text.trim(),
      createdAt: DateTime.now(),
    );
    await controller.createThread(thread, post);
    final state = ref.read(composerControllerProvider);
    final msg = state.when(
      data: (_) => loc.saved_success,
      error: (_, __) => loc.saved_error,
      loading: () => null,
    );
    if (msg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final asyncState = ref.watch(composerControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(loc.new_thread_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('title'),
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: loc.new_thread_title),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('content'),
              controller: _contentCtrl,
              maxLines: 5,
              decoration: InputDecoration(labelText: loc.first_post_hint),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('submit'),
              onPressed: _isValid && !asyncState.isLoading ? _submit : null,
              child: asyncState.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(loc.btn_create_thread),
            ),
          ],
        ),
      ),
    );
  }
}

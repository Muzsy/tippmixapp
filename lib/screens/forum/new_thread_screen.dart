import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/forum/domain/post.dart';
import '../../features/forum/domain/thread.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/forum_provider.dart';
import '../../routes/app_route.dart';

/// Screen for composing a new forum thread with its first post.
class NewThreadScreen extends ConsumerStatefulWidget {
  const NewThreadScreen({super.key});

  @override
  ConsumerState<NewThreadScreen> createState() => _NewThreadScreenState();
}

class _NewThreadScreenState extends ConsumerState<NewThreadScreen> {
  final _formKey = GlobalKey<FormState>();
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
    if (!(_formKey.currentState?.validate() ?? false)) return;
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
    if (!mounted) return;
    final state = ref.read(composerControllerProvider);
    state.when(
      data: (_) => context.goNamed(
        AppRoute.threadView.name,
        pathParameters: {'threadId': id},
      ),
      error: (_, __) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.saved_error)),
      ),
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final asyncState = ref.watch(composerControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(loc.new_thread_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                key: const Key('title'),
                controller: _titleCtrl,
                decoration: InputDecoration(labelText: loc.new_thread_title),
                validator: (v) =>
                    v!.trim().isEmpty ? loc.field_required : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('content'),
                controller: _contentCtrl,
                maxLines: 5,
                decoration: InputDecoration(labelText: loc.first_post_hint),
                validator: (v) =>
                    v!.trim().isEmpty ? loc.field_required : null,
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

import '../models/feed_event_type.dart';
import '../providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import '../flows/copy_bet_flow.dart';
import '../models/tip_model.dart';
import 'components/comment_modal.dart';
import 'components/report_dialog.dart';

/// Displays public feed items with like and comment actions.
class HomeFeedWidget extends ConsumerWidget {
  const HomeFeedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedStreamProvider);
    final user = ref.watch(authProvider).user;

    return feedAsync.when(
      loading: () => const _ShimmerList(),
      error: (e, st) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(AppLocalizations.of(context)!.feed_empty_state),
            ),
          );
        }

        return PageView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(item.message),
                    subtitle: Text(item.eventType.name),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up),
                        tooltip: AppLocalizations.of(context)!.feed_like,
                        onPressed: item.userId == user?.id
                            ? null
                            : () {
                                final service = ref.read(feedServiceProvider);
                                service.addFeedEntry(
                                  userId: user!.id,
                                  eventType: FeedEventType.like,
                                  message: '',
                                  extraData: {'targetUserId': item.userId},
                                );
                              },
                      ),
                      IconButton(
                        icon: const Icon(Icons.comment),
                        tooltip: AppLocalizations.of(context)!.feed_comment,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => CommentModal(postId: item.userId),
                          );
                        },
                      ),
                      if (item.extraData['ticketId'] != null)
                        IconButton(
                          key: const Key('copyButton'),
                          icon: const Icon(Icons.copy),
                          tooltip: AppLocalizations.of(context)!.copy_success,
                          onPressed: () async {
                            final uid = user?.id;
                            if (uid == null) return;
                            final tipsData =
                                (item.extraData['tips'] as List<dynamic>? ?? [])
                                    .cast<Map<String, dynamic>>();
                            final tips = tipsData
                                .map(TipModel.fromJson)
                                .toList();
                            await ref.read(copyTicketProvider)(
                              userId: uid,
                              ticketId: item.extraData['ticketId'] as String,
                              tips: tips,
                              sourceUserId: item.userId,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      AppLocalizations.of(context)!.copy_success),
                                ),
                              );
                            }
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.report),
                        tooltip: AppLocalizations.of(context)!.feed_report,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => ReportDialog(postId: item.userId),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ShimmerList extends StatefulWidget {
  const _ShimmerList();

  @override
  State<_ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<_ShimmerList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                key: const Key('shimmer'),
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(
                    ((0.3 + 0.3 * _controller.value) * 255).round(),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

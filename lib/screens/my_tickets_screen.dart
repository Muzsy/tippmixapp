import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

import '../models/ticket_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/ticket_card.dart';
import '../widgets/empty_ticket_placeholder.dart';
import '../widgets/ticket_details_dialog.dart';
import '../widgets/error_with_retry.dart';
import '../widgets/my_tickets_skeleton.dart';
import '../services/analytics_service.dart';

final ticketsProvider = StreamProvider.autoDispose<List<Ticket>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream.value([]);
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('tickets')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Ticket.fromFirestore(d)).toList());
});

final _listViewedLoggedProvider = StateProvider.autoDispose<bool>((ref) => false);

class MyTicketsScreen extends ConsumerWidget {
  final bool showAppBar;

  const MyTicketsScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final ticketsAsync = ref.watch(ticketsProvider);
    final loc = AppLocalizations.of(context)!;

    Widget content;
    if (user == null) {
      content = const EmptyTicketPlaceholder();
    } else {
      content = ticketsAsync.when(
        data: (tickets) {
          // Log list viewed once per screen lifecycle after build completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final logged = ref.read(_listViewedLoggedProvider);
            if (!logged) {
              ref.read(_listViewedLoggedProvider.notifier).state = true;
              // fire-and-forget telemetry
              // ignore: unawaited_futures
              ref.read(analyticsServiceProvider).logTicketsListViewed(tickets.length);
            }
          });
          return RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              await ref.refresh(ticketsProvider.future);
            },
            child: tickets.isEmpty
                ? ListView(children: const [EmptyTicketPlaceholder()])
                : ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) => TicketCard(
                      ticket: tickets[index],
                      onTap: () async {
                        final t = tickets[index];
                        // Telemetry: selected + details opened
                        // ignore: unawaited_futures
                        ref.read(analyticsServiceProvider).logTicketSelected(t.id);
                        // ignore: unawaited_futures
                        ref.read(analyticsServiceProvider).logTicketDetailsOpened(
                              ticketId: t.id,
                              tips: t.tips.length,
                              status: t.status.name,
                              stake: t.stake,
                              totalOdd: t.totalOdd,
                              potentialWin: t.potentialWin,
                            );
                        await showDialog(
                          context: context,
                          builder: (_) => TicketDetailsDialog(
                            ticket: t,
                            tips: t.tips,
                          ),
                        );
                      },
                    ),
                  ),
          );
        },
        loading: () => const MyTicketsSkeleton(),
        error: (e, _) {
          // fire-and-forget error telemetry
          // ignore: unawaited_futures
          ref.read(analyticsServiceProvider).logErrorShown(
                screen: 'my_tickets',
                code: e.runtimeType.toString(),
                message: e.toString(),
              );
          return ErrorWithRetry(
            message: e.toString(),
            retryLabel: loc.events_screen_refresh,
            onRetry: () async {
              // ignore: unused_result
              await ref.refresh(ticketsProvider.future);
            },
          );
        },
      );
    }

    if (!showAppBar) return content;
    if (Scaffold.maybeOf(context) != null) {
      return content;
    }
    return Scaffold(
      appBar: AppBar(title: Text(loc.my_tickets_title)),
      body: content,
    );
  }
}

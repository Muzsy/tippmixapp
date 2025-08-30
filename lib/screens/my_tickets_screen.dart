import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

import '../models/ticket_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/ticket_card.dart';
import '../widgets/empty_ticket_placeholder.dart';
import '../widgets/ticket_details_dialog.dart';

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
          return RefreshIndicator(
            onRefresh: () async {
              final _ = await ref.refresh(ticketsProvider.future);
            },
            child: tickets.isEmpty
                ? ListView(children: const [EmptyTicketPlaceholder()])
                : ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) => TicketCard(
                      ticket: tickets[index],
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (_) => TicketDetailsDialog(
                            ticket: tickets[index],
                            tips: tickets[index].tips,
                          ),
                        );
                      },
                    ),
                  ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await ref.refresh(ticketsProvider.future);
                  },
                  child: Text(loc.events_screen_refresh),
                ),
              ],
            ),
          ),
        ),
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

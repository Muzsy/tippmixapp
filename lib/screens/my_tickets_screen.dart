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

final ticketsProvider = StreamProvider.autoDispose<List<Ticket>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return Stream.value([]);
  }
  return FirebaseFirestore.instance
      .collection('tickets')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => Ticket.fromJson(d.data())).toList());
});

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final ticketsAsync = ref.watch(ticketsProvider);
    final loc = AppLocalizations.of(context)!;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.my_tickets_title)),
        body: const EmptyTicketPlaceholder(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(loc.my_tickets_title)),
      body: ticketsAsync.when(
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
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

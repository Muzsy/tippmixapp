import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

import '../models/ticket_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/ticket_card.dart';
import '../widgets/empty_ticket_placeholder.dart';
import '../widgets/ticket_details_dialog.dart';
import '../widgets/error_with_retry.dart';
import '../widgets/my_tickets_skeleton.dart';
import '../services/analytics_service.dart';
import '../services/finalizer_service.dart';
import '../providers/onboarding_provider.dart' show firebaseAuthProvider;

const _pageSize = 20;

final ticketsProvider = StreamProvider.autoDispose<List<Ticket>>((ref) {
  // Depend on authProvider so changes in auth state refresh the stream
  final uid = ref.watch(authProvider).user?.id;
  if (uid == null) {
    return Stream.value([]);
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('tickets')
      .orderBy('createdAt', descending: true)
      .limit(_pageSize)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Ticket.fromFirestore(d)).toList());
});

final _listViewedLoggedProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

class MyTicketsScreen extends ConsumerStatefulWidget {
  final bool showAppBar;

  const MyTicketsScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends ConsumerState<MyTicketsScreen> {
  final _controller = ScrollController();
  final List<Ticket> _extra = [];
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _forcing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore) return;
    if (!_controller.hasClients) return;
    final threshold = 200.0; // px from bottom
    final max = _controller.position.maxScrollExtent;
    final offset = _controller.offset;
    if (max - offset <= threshold) {
      // ignore: discarded_futures
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final uid = ref.read(authProvider).user?.id;
      if (uid == null) return;
      // Determine last createdAt from current list
      final current = [...?_currentBase, ..._extra];
      if (current.isEmpty) return;
      final last = current.last.createdAt;
      final query = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tickets')
          .orderBy('createdAt', descending: true)
          .startAfter([Timestamp.fromDate(last)])
          .limit(_pageSize);
      final snap = await query.get();
      final more = snap.docs.map((d) => Ticket.fromFirestore(d)).toList();
      if (more.isEmpty || more.length < _pageSize) {
        _hasMore = false;
      }
      setState(() {
        _extra.addAll(more);
      });
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  List<Ticket>? get _currentBase =>
      ref.read(ticketsProvider).maybeWhen(data: (v) => v, orElse: () => null);

  @override
  Widget build(BuildContext context) {
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
              ref
                  .read(analyticsServiceProvider)
                  .logTicketsListViewed(tickets.length);
            }
          });
          final combined = [...tickets, ..._extra];
          return RefreshIndicator(
            onRefresh: () async {
              // Recreate base stream to fetch fresh first page
              ref.invalidate(ticketsProvider);
              if (mounted) {
                setState(() {
                  _extra.clear();
                  _hasMore = true;
                });
              }
            },
            child: combined.isEmpty
                ? ListView(children: const [EmptyTicketPlaceholder()])
                : ListView.builder(
                    controller: _controller,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: combined.length + (_loadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_loadingMore && index == combined.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final t = combined[index];
                      return TicketCard(
                        ticket: t,
                        onTap: () async {
                          // Telemetry: selected + details opened
                          // ignore: unawaited_futures
                          ref
                              .read(analyticsServiceProvider)
                              .logTicketSelected(t.id);
                          // ignore: unawaited_futures
                          ref
                              .read(analyticsServiceProvider)
                              .logTicketDetailsOpened(
                                ticketId: t.id,
                                tips: t.tips.length,
                                status: t.status.name,
                                stake: t.stake,
                                totalOdd: t.totalOdd,
                                potentialWin: t.potentialWin,
                              );
                          await showDialog(
                            context: context,
                            builder: (_) =>
                                TicketDetailsDialog(ticket: t, tips: t.tips),
                          );
                        },
                      );
                    },
                  ),
          );
        },
        loading: () => const MyTicketsSkeleton(),
        error: (e, _) {
          // fire-and-forget error telemetry
          // ignore: unawaited_futures
          ref
              .read(analyticsServiceProvider)
              .logErrorShown(
                screen: 'my_tickets',
                code: e.runtimeType.toString(),
                message: e.toString(),
              );
          return ErrorWithRetry(
            message: e.toString(),
            retryLabel: loc.events_screen_refresh,
            onRetry: () async {
              ref.invalidate(ticketsProvider);
            },
          );
        },
      );
    }

    if (!widget.showAppBar) return content;
    if (Scaffold.maybeOf(context) != null) {
      return content;
    }
    return Scaffold(
      appBar: AppBar(title: Text(loc.my_tickets_title)),
      body: content,
      floatingActionButton: _buildForceFab(context),
    );
  }

  Widget? _buildForceFab(BuildContext context) {
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    if (uid != '2pEEqMzCsBfkrv4jWx3YP5yDb0F2') {
      return null;
    }

    return FloatingActionButton.extended(
      onPressed: _forcing
          ? null
          : () async {
              setState(() => _forcing = true);
              final result = await FinalizerService.forceFinalizer();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result == 'OK' ? 'Kiértékelés elindítva' : 'Hiba: $result',
                  ),
                ),
              );
              setState(() => _forcing = false);
            },
      icon: const Icon(Icons.bolt),
      label: Text(_forcing ? 'Fut…' : 'Kiértékelés'),
    );
  }
}

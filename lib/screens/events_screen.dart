import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

import '../models/odds_event.dart';
import '../models/tip_model.dart';
import '../providers/odds_api_provider.dart';
import '../providers/bet_slip_provider.dart'; // feltételezzük, hogy van ilyen
import 'package:go_router/go_router.dart';

class EventsScreen extends ConsumerStatefulWidget {
  final String sportKey;
  final bool showAppBar;

  const EventsScreen({
    super.key,
    required this.sportKey,
    this.showAppBar = true,
  });

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  @override
  void initState() {
    super.initState();
    // Kick‑off the fetch exactly once after first frame
    Future.microtask(
      () =>
          ref.read(oddsApiProvider.notifier).fetchOdds(sport: widget.sportKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final oddsState = ref.watch(oddsApiProvider);
    final loc = AppLocalizations.of(context)!;

    final hasTips = ref.watch(betSlipProvider).tips.isNotEmpty;

    final body = Builder(
      builder: (context) {
        if (oddsState is OddsApiLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (oddsState is OddsApiError) {
          return Center(
            child: Text(_localizeError(loc, oddsState.errorMessageKey)),
          );
        } else if (oddsState is OddsApiEmpty) {
          return Center(child: Text(loc.events_screen_no_events));
        } else if (oddsState is OddsApiData) {
          final events = oddsState.events;
          final quotaWarn = oddsState.quotaWarning;
          if (events.isEmpty) {
            return Center(child: Text(loc.events_screen_no_events));
          }
          return Column(
            children: [
              if (quotaWarn)
                Container(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loc.events_screen_quota_warning,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _EventCard(
                      key: ValueKey(event.id),
                      event: event,
                      loc: loc,
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );

    if (!widget.showAppBar) {
      return body;
    }
    if (Scaffold.maybeOf(context) != null) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.bets_title)),
      body: body,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (hasTips)
            FloatingActionButton(
              key: const Key('create_ticket_button'),
              heroTag: 'createTicket',
              tooltip: loc.go_to_create_ticket,
              child: const Icon(Icons.check),
              onPressed: () {
                GoRouter.of(context).push('/create-ticket');
              },
            ),
          if (hasTips) const SizedBox(height: 12),
          FloatingActionButton(
            key: const Key('refresh_button'),
            heroTag: 'refreshOdds',
            tooltip: loc.events_screen_refresh,
            onPressed: () {
              ref
                  .read(oddsApiProvider.notifier)
                  .fetchOdds(sport: widget.sportKey);
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  String _localizeError(AppLocalizations loc, String key) {
    switch (key) {
      case 'api_error_limit':
        return loc.api_error_limit;
      case 'api_error_key':
        return loc.api_error_key;
      case 'api_error_network':
        return loc.api_error_network;
      case 'api_error_unknown':
        return loc.api_error_unknown;
      default:
        return key;
    }
  }
}

class _EventCard extends ConsumerWidget {
  const _EventCard({super.key, required this.event, required this.loc});

  final OddsEvent event;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the first bookmaker and try to find a head‑to‑head market
    if (event.bookmakers.isEmpty) {
      return Card(
        child: ListTile(
          title: Text('${event.homeTeam} – ${event.awayTeam}'),
          subtitle: Text(loc.events_screen_no_market),
        ),
      );
    }

    final bookmaker = event.bookmakers.first;
    if (bookmaker.markets.isEmpty) {
      return Card(
        child: ListTile(
          title: Text('${event.homeTeam} – ${event.awayTeam}'),
          subtitle: Text(loc.events_screen_no_market),
        ),
      );
    }

    final market = bookmaker.markets.firstWhere(
      (m) => m.key == 'h2h',
      orElse: () => bookmaker.markets.first,
    );

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('${event.homeTeam} – ${event.awayTeam}'),
            subtitle: Text(
              loc.events_screen_start_time(event.commenceTime.toString()),
            ),
          ),
          Row(
            children: market.outcomes.map((outcome) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final tip = TipModel(
                        eventId: event.id,
                        eventName: '${event.homeTeam} – ${event.awayTeam}',
                        startTime: event.commenceTime,
                        sportKey: event.sportKey,
                        bookmaker: bookmaker.key,
                        marketKey: market.key,
                        outcome: outcome.name,
                        odds: outcome.price,
                      );

                      final added = ref
                          .read(betSlipProvider.notifier)
                          .addTip(tip);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 2),
                          content: Text(
                            added
                                ? loc.events_screen_tip_added
                                : loc.events_screen_tip_duplicate,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          outcome.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(outcome.price.toStringAsFixed(2)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

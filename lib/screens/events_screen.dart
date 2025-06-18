import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

import '../models/odds_event.dart';
import '../models/tip_model.dart';
import '../providers/odds_api_provider.dart';
import '../providers/bet_slip_provider.dart'; // feltételezzük, hogy van ilyen


class EventsScreen extends ConsumerStatefulWidget {
  final String sportKey;

  const EventsScreen({super.key, required this.sportKey});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  @override
  void initState() {
    super.initState();
    // Kick‑off the fetch exactly once after first frame
    Future.microtask(() =>
        ref.read(oddsApiProvider.notifier).fetchOdds(sport: widget.sportKey));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oddsState = ref.watch(oddsApiProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.events_title), // ARB kulcs
      ),
      body: Builder(
        builder: (context) {
          if (oddsState is OddsApiLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (oddsState is OddsApiError) {
            return Center(child: Text(_localizeError(loc, oddsState.errorMessageKey)));
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
                    color: Colors.yellow.shade700,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.black),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc.events_screen_quota_warning,
                            style: const TextStyle(color: Colors.black),
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
                      return _EventCard(event: event, loc: loc);
                    },
                  ),
                ),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: loc.events_screen_refresh,
        onPressed: () =>
            ref.read(oddsApiProvider.notifier).fetchOdds(sport: widget.sportKey),
        child: const Icon(Icons.refresh),
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
  const _EventCard({Key? key, required this.event, required this.loc}) : super(key: key);

  final OddsEvent event;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find the first head‑to‑head market
    final market = event.markets.firstWhere(
      (m) => m.key == 'h2h',
      orElse: () => event.markets.isNotEmpty ? event.markets.first : null,
    );

    if (market == null) {
      return Card(
        child: ListTile(
          title: Text('${event.homeTeam} – ${event.awayTeam}'),
          subtitle: Text(loc.events_screen_no_market),
        ),
      );
    }

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
                        outcomeName: outcome.name,
                        odds: outcome.price,
                      );

                      final added = ref.read(betSlipProvider.notifier).addTip(tip);

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
                        Text(outcome.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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

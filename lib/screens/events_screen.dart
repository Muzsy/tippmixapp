import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

import '../models/odds_event.dart';
import '../models/tip_model.dart';
import '../providers/odds_api_provider.dart';
import '../providers/bet_slip_provider.dart'; // feltételezzük, hogy van ilyen
import '../utils/localization_stub.dart';

class EventsScreen extends ConsumerWidget {
  final String sportKey;

  const EventsScreen({Key? key, required this.sportKey}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oddsState = ref.watch(oddsApiProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.events_title), // ARB kulcs
      ),
      body: Builder(
        builder: (context) {
          if (oddsState is OddsApiLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (oddsState is OddsApiError) {
            return Center(
              child: Text(oddsState.errorMessageKey.tr()), // ARB hiba
            );
          } else if (oddsState is OddsApiEmpty) {
            return Center(
              child: Text('events_screen_no_events'.tr()), // ARB kulcs
            );
          } else if (oddsState is OddsApiData) {
            final events = oddsState.events;
            final quotaWarn = oddsState.quotaWarning;
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
                          child: Text('events_screen_quota_warning'.tr(),
                              style: const TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, i) {
                      final event = events[i];
                      return EventCard(event: event);
                    },
                  ),
                ),
              ],
            );
          }
          // Default fallback
          return const Center(child: Text('events_screen_unknown_error'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(oddsApiProvider.notifier).fetchOdds(sport: sportKey);
        },
        child: const Icon(Icons.refresh),
        tooltip: 'events_screen_refresh'.tr(), // ARB kulcs
      ),
    );
  }
}

/// Egy eseménykártya (meccs) odds listával, odds pickerrel.
class EventCard extends ConsumerWidget {
  final OddsEvent event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Egyszerűsített: csak az első bookmaker, első piac jelenik meg
    final bookmaker = event.bookmakers.isNotEmpty ? event.bookmakers.first : null;
    if (bookmaker == null) {
      return Card(
        child: ListTile(
          title: Text('${event.homeTeam} – ${event.awayTeam}'),
          subtitle: Text('events_screen_no_odds'.tr()),
        ),
      );
    }

    final market = bookmaker.markets.isNotEmpty ? bookmaker.markets.first : null;
    if (market == null) {
      return Card(
        child: ListTile(
          title: Text('${event.homeTeam} – ${event.awayTeam}'),
          subtitle: Text('events_screen_no_market'.tr()),
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
              'events_screen_start_time'
                  .tr(namedArgs: {'time': event.commenceTime.toString()}),
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
                        bookmaker: bookmaker.title,
                        marketKey: market.key,
                        outcome: outcome.name,
                        odds: outcome.price,
                      );
                      final added = ref
                          .read(betSlipProvider.notifier)
                          .addTip(tip);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(added
                              ? 'events_screen_tip_added'.tr()
                              : 'events_screen_tip_duplicate'.tr()),
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

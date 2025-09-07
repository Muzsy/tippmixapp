import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

import '../providers/odds_api_provider.dart';
import '../providers/bet_slip_provider.dart';
import '../utils/events_filter.dart';
import '../features/filters/events_filter.dart';
import '../widgets/events_filter_bar.dart';
import '../models/tip_model.dart';
import 'package:go_router/go_router.dart';
import '../widgets/event_bet_card.dart';
import '../services/api_football_service.dart';
import 'package:tipsterino/routes/app_route.dart';

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
  EventsFilter _filter = const EventsFilter();

  @override
  void initState() {
    super.initState();
    // Kick‑off the fetch exactly once after first frame
    Future.microtask(
      () => ref
          .read(oddsApiProvider.notifier)
          .fetchOdds(sport: widget.sportKey, date: _filter.date),
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
          return Column(
            children: [
              EventsFilterBar(
                source: const [],
                value: _filter,
                onChanged: (f) {
                  final prevDate = _filter.date;
                  setState(() => _filter = f);
                  if (f.date != prevDate) {
                    ref
                        .read(oddsApiProvider.notifier)
                        .fetchOdds(sport: widget.sportKey, date: f.date);
                  }
                },
              ),
              Expanded(child: Center(child: Text(loc.events_screen_no_events))),
            ],
          );
        } else if (oddsState is OddsApiData) {
          final events = filterActiveEvents(oddsState.events);
          final quotaWarn = oddsState.quotaWarning;
          final filtered = EventsFilter.apply(events, _filter);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              EventsFilterBar(
                source: events,
                value: _filter,
                onChanged: (f) {
                  final prevDate = _filter.date;
                  setState(() => _filter = f);
                  if (f.date != prevDate) {
                    ref
                        .read(oddsApiProvider.notifier)
                        .fetchOdds(sport: widget.sportKey, date: f.date);
                  }
                },
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline, size: 32),
                            const SizedBox(height: 8),
                            Text(loc.events_screen_no_events),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final event = filtered[index];
                          // Kiváltjuk a belső kártyát az új, újrahasznosítható EventBetCard-dal
                          final bookmaker = event.bookmakers.isNotEmpty
                              ? event.bookmakers.first
                              : null;
                          final market =
                              (bookmaker != null &&
                                  bookmaker.markets.isNotEmpty)
                              ? bookmaker.markets.firstWhere(
                                  (m) => m.key == 'h2h',
                                  orElse: () => bookmaker.markets.first,
                                )
                              : null;
                          return EventBetCard(
                            key: ValueKey(event.id),
                            event: event,
                            onTapHome: (outcome) {
                              final tip = TipModel(
                                eventId: event.id,
                                eventName:
                                    '${event.homeTeam} – ${event.awayTeam}',
                                startTime: event.commenceTime,
                                sportKey: event.sportKey,
                                bookmakerId:
                                    ApiFootballService.defaultBookmakerId,
                                marketKey: market?.key ?? 'h2h',
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
                            onTapDraw: (outcome) {
                              final tip = TipModel(
                                eventId: event.id,
                                eventName:
                                    '${event.homeTeam} – ${event.awayTeam}',
                                startTime: event.commenceTime,
                                sportKey: event.sportKey,
                                bookmakerId:
                                    ApiFootballService.defaultBookmakerId,
                                marketKey: market?.key ?? 'h2h',
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
                            onTapAway: (outcome) {
                              final tip = TipModel(
                                eventId: event.id,
                                eventName:
                                    '${event.homeTeam} – ${event.awayTeam}',
                                startTime: event.commenceTime,
                                sportKey: event.sportKey,
                                bookmakerId:
                                    ApiFootballService.defaultBookmakerId,
                                marketKey: market?.key ?? 'h2h',
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
                            onMoreBets: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.more_bets)),
                              );
                            },
                            onStats: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.statistics)),
                              );
                            },
                            onAi: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.ai_recommendation)),
                              );
                            },
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

    return Scaffold(
      appBar: widget.showAppBar && Scaffold.maybeOf(context) == null
          ? AppBar(title: Text(AppLocalizations.of(context)!.bets_title))
          : null,
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
              onPressed: () => context.pushNamed(AppRoute.createTicket.name),
            ),
          if (hasTips) const SizedBox(height: 12),
          FloatingActionButton(
            key: const Key('refresh_button'),
            heroTag: 'refreshOdds',
            tooltip: loc.events_screen_refresh,
            onPressed: () {
              ref
                  .read(oddsApiProvider.notifier)
                  .fetchOdds(sport: widget.sportKey, date: _filter.date);
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

// A régi, belső _EventCard eltávolítva – helyette EventBetCard használata

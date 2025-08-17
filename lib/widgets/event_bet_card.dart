import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/models/odds_outcome.dart';
import 'package:tippmixapp/models/h2h_market.dart';
import 'package:tippmixapp/models/odds_market.dart';
import 'package:tippmixapp/services/api_football_service.dart';
import 'package:tippmixapp/widgets/action_pill.dart';
import 'package:tippmixapp/widgets/league_pill.dart';
import 'package:tippmixapp/widgets/team_badge.dart';

class EventBetCard extends StatelessWidget {
  final OddsEvent event;
  final ApiFootballService apiService;
  final void Function(OddsOutcome)? onTapHome;
  final void Function(OddsOutcome)? onTapDraw;
  final void Function(OddsOutcome)? onTapAway;
  final VoidCallback? onMoreBets;
  final VoidCallback? onStats;
  final VoidCallback? onAi;
  final DateTime? refreshedAt;

  EventBetCard({
    super.key,
    required this.event,
    ApiFootballService? apiService,
    this.onTapHome,
    this.onTapDraw,
    this.onTapAway,
    this.onMoreBets,
    this.onStats,
    this.onAi,
    this.refreshedAt,
  }) : apiService = apiService ?? ApiFootballService();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final ra = event.fetchedAt ?? refreshedAt ?? DateTime.now();

    return Card(
      key: ValueKey('bet-card-${event.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, event),
            const SizedBox(height: 8),

            // Csapat sor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      TeamBadge(
                        imageUrl: event.homeLogoUrl,
                        initials: _initials(event.homeTeam),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          event.homeTeam,
                          maxLines: 2,
                          softWrap: true,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          event.awayTeam,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          softWrap: true,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TeamBadge(
                        imageUrl: event.awayLogoUrl,
                        initials: _initials(event.awayTeam),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Kezdési idő + visszaszámláló
            _buildKickoffRow(context, event),
            const SizedBox(height: 12),

            Builder(
              builder: (context) {
                final existing = event.bookmakers
                    .expand((b) => b.markets)
                    .where((m) => m.key == 'h2h')
                    .toList();
                if (existing.isNotEmpty) {
                  return _buildH2HButtonsFrom(
                    H2HMarket(outcomes: existing.first.outcomes),
                  );
                }
                return FutureBuilder<OddsMarket?>(
                  key: ValueKey('markets-${event.id}'),
                  future: apiService.getH2HForFixture(
                    int.tryParse(event.id) ?? 0,
                    season: event.season,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _loadingMarkets();
                    }
                    if (snapshot.hasError) {
                      return _loadingMarkets();
                    }
                    final h2h = snapshot.data;
                    if (h2h != null) {
                      return _buildH2HButtonsFrom(h2h);
                    }
                    return _noMarkets(loc.events_screen_no_market);
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            _buildActions(context, loc),

            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                loc.updated_time_ago(_formatYMDHM(ra)),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ActionPill(
                icon: Icons.more_horiz,
                label: loc.appActionsMoreBets,
                onTap: onMoreBets,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionPill(
                icon: Icons.bar_chart,
                label: loc.appActionsStatistics,
                onTap: onStats,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionPill(
                icon: Icons.auto_awesome,
                label: loc.appActionsAiRecommend,
                onTap: onAi,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildH2HButtons(
    OddsOutcome? home,
    OddsOutcome? draw,
    OddsOutcome? away,
  ) {
    String fmt(double v) => v.toStringAsFixed(2);
    final hLabel = home != null ? '1 ${fmt(home.price)}' : '1 —';
    final dLabel = draw != null ? 'X ${fmt(draw.price)}' : 'X —';
    final aLabel = away != null ? '2 ${fmt(away.price)}' : '2 —';
    return Row(
      children: [
        Expanded(
          child: ActionPill(
            label: hLabel,
            onTap: home != null ? () => onTapHome?.call(home) : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ActionPill(
            label: dLabel,
            onTap: draw != null ? () => onTapDraw?.call(draw) : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ActionPill(
            label: aLabel,
            onTap: away != null ? () => onTapAway?.call(away) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildH2HButtonsFrom(OddsMarket h2h) {
    OddsOutcome? home;
    OddsOutcome? draw;
    OddsOutcome? away;
    for (final o in h2h.outcomes) {
      final name = o.name.toLowerCase();
      if (name == 'home' || name == '1') {
        home = o;
      } else if (name == 'draw' || name == 'x') {
        draw = o;
      } else if (name == 'away' || name == '2') {
        away = o;
      }
    }
    home ??= h2h.outcomes.isNotEmpty ? h2h.outcomes.first : null;
    away ??= h2h.outcomes.length > 1 ? h2h.outcomes.last : null;
    return _buildH2HButtons(home, draw, away);
  }

  Widget _noMarkets(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text),
  );

  Widget _loadingMarkets() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: SizedBox(
      height: 18,
      width: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );

  Widget _buildKickoffRow(BuildContext context, OddsEvent e) {
    final l = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Countdown(to: e.commenceTime),
        Text(
          l.starts_at(_formatYMDHM(e.commenceTime)),
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatYMDHM(DateTime dt) {
    final d = dt.toLocal();
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${d.year}/${two(d.month)}/${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  Widget _buildHeader(BuildContext context, OddsEvent e) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(e.countryName ?? '', overflow: TextOverflow.ellipsis),
        ),
        LeaguePill(
          country: null,
          league: e.leagueName,
          logoUrl: e.leagueLogoUrl,
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    final letters = parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
    return letters.toUpperCase();
  }
}

class _Countdown extends StatefulWidget {
  final DateTime to;
  const _Countdown({required this.to});
  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  late Timer _t;
  Duration _left = Duration.zero;
  @override
  void initState() {
    super.initState();
    _compute();
    _t = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _compute() {
    final now = DateTime.now();
    setState(() {
      _left = widget.to.difference(now);
      if (_left.isNegative) _left = Duration.zero;
    });
  }

  void _tick() => _compute();

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String two(int v) => v.toString().padLeft(2, '0');
    final h = two(_left.inHours);
    final m = two(_left.inMinutes % 60);
    final s = two(_left.inSeconds % 60);
    return Text('$h:$m:$s', style: Theme.of(context).textTheme.bodySmall);
  }
}

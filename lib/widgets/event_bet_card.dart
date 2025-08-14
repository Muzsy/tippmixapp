import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/models/odds_market.dart';
import 'package:tippmixapp/models/odds_outcome.dart';
import 'package:tippmixapp/widgets/action_pill.dart';
import 'package:tippmixapp/widgets/league_pill.dart';
import 'package:tippmixapp/widgets/team_badge.dart';

class EventBetCard extends StatelessWidget {
  final OddsEvent event;
  final OddsMarket? h2hMarket;
  final void Function(OddsOutcome)? onTapHome;
  final void Function(OddsOutcome)? onTapDraw;
  final void Function(OddsOutcome)? onTapAway;
  final VoidCallback? onMoreBets;
  final VoidCallback? onStats;
  final VoidCallback? onAi;
  final DateTime? refreshedAt;

  const EventBetCard({
    super.key,
    required this.event,
    required this.h2hMarket,
    this.onTapHome,
    this.onTapDraw,
    this.onTapAway,
    this.onMoreBets,
    this.onStats,
    this.onAi,
    this.refreshedAt,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final ra = event.fetchedAt ?? refreshedAt ?? DateTime.now();

    final OddsOutcome? home = h2hMarket?.outcomes.firstWhere(
      (o) => o.name.toLowerCase() == event.homeTeam.toLowerCase(),
      orElse: () => h2hMarket!.outcomes.first,
    );
    final OddsOutcome? away = h2hMarket?.outcomes.firstWhere(
      (o) => o.name.toLowerCase() == event.awayTeam.toLowerCase(),
      orElse: () => h2hMarket!.outcomes.last,
    );
    final OddsOutcome? draw = h2hMarket?.outcomes.firstWhere(
      (o) => o.name.toLowerCase() == 'draw' || o.name.toLowerCase() == 'x',
      orElse: () => h2hMarket!.outcomes.length == 3
          ? h2hMarket!.outcomes[1]
          : h2hMarket!.outcomes.first,
    );

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

            // H2H odds gombok
            if (h2hMarket != null)
              _buildH2HButtons(home, draw, away)
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(loc.events_screen_no_market),
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
    return Row(
      children: [
        Expanded(
          child: ActionPill(
            label: '1',
            onTap: home != null ? () => onTapHome?.call(home) : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ActionPill(
            label: 'X',
            onTap: draw != null ? () => onTapDraw?.call(draw) : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ActionPill(
            label: '2',
            onTap: away != null ? () => onTapAway?.call(away) : null,
          ),
        ),
      ],
    );
  }

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

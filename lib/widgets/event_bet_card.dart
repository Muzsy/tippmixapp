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
import 'package:tippmixapp/services/ticket_service.dart';

class EventBetCard extends StatefulWidget {
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
  State<EventBetCard> createState() => _EventBetCardState();
}

class _EventBetCardState extends State<EventBetCard> {
  String? _selected; // 'home', 'draw', 'away'
  Future<OddsMarket?>? _h2hFuture;

  @override
  void initState() {
    super.initState();
    TicketService.signals.addListener(_onSlipSignal);
  }

  void _onSlipSignal() {
    if (!mounted) return;
    setState(() {
      _selected = null;
    });
  }

  @override
  void dispose() {
    TicketService.signals.removeListener(_onSlipSignal);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final event = widget.event;
    final ra = event.fetchedAt ?? widget.refreshedAt ?? DateTime.now();

    return Card(
      key: ValueKey('bet-card-${event.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                          key: ValueKey('home-team-${event.id}'),
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
                          key: ValueKey('away-team-${event.id}'),
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
                    context,
                    H2HMarket(outcomes: existing.first.outcomes),
                  );
                }
                final fid =
                    int.tryParse(event.id) ??
                    int.tryParse(
                      RegExp(r'\d+').firstMatch(event.id)?.group(0) ?? '',
                    ) ??
                    0;
                _h2hFuture ??= widget.apiService.getH2HForFixture(
                  fid,
                  season: event.season ?? event.commenceTime.year,
                  homeName: event.homeTeam,
                  awayName: event.awayTeam,
                );
                return FutureBuilder<OddsMarket?>(
                  key: ValueKey('markets-${event.id}'),
                  future: _h2hFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _loadingMarkets();
                    }
                    if (snapshot.hasError) {
                      return _loadingMarkets();
                    }
                    final h2h = snapshot.data;
                    if (h2h != null) {
                      return _buildH2HButtonsFrom(context, h2h);
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
              alignment: Alignment.centerLeft,
              child: Text(
                loc.updated_time_ago(_formatYMDHM(ra)),
                key: ValueKey('updated-${event.id}'),
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
        const SizedBox(height: 12),
        // Alsó akciók – hierarchizált elrendezés (1 nagy + 2 kisebb)
        SizedBox(
          width: double.infinity,
          child: ActionPill(
            icon: Icons.more_horiz,
            label: loc.more_bets,
            labelStyle: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            onTap: widget.onMoreBets,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ActionPill(
                icon: Icons.bar_chart,
                label: loc.statistics,
                onTap: widget.onStats,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionPill(
                icon: Icons.smart_toy,
                label: loc.ai_recommendation,
                onTap: widget.onAi,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildH2HButtons(
    BuildContext context,
    OddsOutcome? home,
    OddsOutcome? draw,
    OddsOutcome? away,
  ) {
    final loc = AppLocalizations.of(context)!;
    return Row(
      key: const ValueKey('h2h-row'),
      children: [
        Expanded(
          child: home != null
              ? _oddsButton(
                  context,
                  home,
                  fixedLabel: loc.home_short,
                  key: const ValueKey('h2h-home'),
                  selected: _selected == 'home',
                  onTap: () {
                    widget.onTapHome?.call(home);
                    setState(() => _selected = 'home');
                  },
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: draw != null
              ? _oddsButton(
                  context,
                  draw,
                  fixedLabel: loc.draw_short,
                  key: const ValueKey('h2h-draw'),
                  selected: _selected == 'draw',
                  onTap: () {
                    widget.onTapDraw?.call(draw);
                    setState(() => _selected = 'draw');
                  },
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: away != null
              ? _oddsButton(
                  context,
                  away,
                  fixedLabel: loc.away_short,
                  key: const ValueKey('h2h-away'),
                  selected: _selected == 'away',
                  onTap: () {
                    widget.onTapAway?.call(away);
                    setState(() => _selected = 'away');
                  },
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildH2HButtonsFrom(BuildContext context, OddsMarket h2h) {
    OddsOutcome? home;
    OddsOutcome? draw;
    OddsOutcome? away;
    for (final o in h2h.outcomes) {
      final n = o.name.toLowerCase();
      if (n == 'home' || n == '1') {
        home = o;
      } else if (n == 'draw' || n == 'x') {
        draw = o;
      } else if (n == 'away' || n == '2') {
        away = o;
      }
    }
    if (home == null || draw == null || away == null) {
      // Ha pontosan 3 kimenet van, rendeljük őket pozíció szerint (Home, Draw, Away)
      if (h2h.outcomes.length == 3) {
        home ??= h2h.outcomes[0];
        draw ??= h2h.outcomes[1];
        away ??= h2h.outcomes[2];
      } else {
        // Visszaeső fallback az eredeti viselkedéshez
        home ??= h2h.outcomes.isNotEmpty ? h2h.outcomes.first : null;
        away ??= h2h.outcomes.length > 1 ? h2h.outcomes.last : null;
      }
    }
    return _buildH2HButtons(context, home, draw, away);
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
        Text(
          l.starts_at(_formatYMDHM(e.commenceTime)),
          key: ValueKey('kickoff-${e.id}'),
          textAlign: TextAlign.left,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: _Countdown(to: e.commenceTime),
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

Widget _oddsButton(
  BuildContext context,
  OddsOutcome o, {
  String? fixedLabel,
  required bool selected,
  required VoidCallback onTap,
  Key? key,
}) {
  final loc = AppLocalizations.of(context)!;
  String pretty(String v) {
    switch (v) {
      case '1':
      case 'Home':
        return loc.home_short;
      case 'X':
      case 'Draw':
        return loc.draw_short;
      case '2':
      case 'Away':
        return loc.away_short;
      default:
        return v;
    }
  }

  final border = selected
      ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
      : Border.all(color: Colors.transparent, width: 2);

  return InkWell(
    key: key,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: border,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (fixedLabel ?? pretty(o.name)),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 2),
          Text(
            o.price.toStringAsFixed(2),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

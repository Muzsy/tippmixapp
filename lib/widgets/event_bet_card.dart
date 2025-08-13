import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/models/odds_market.dart';
import 'package:tippmixapp/models/odds_outcome.dart';

class EventBetCard extends StatelessWidget {
  final OddsEvent event;
  final OddsMarket? h2hMarket;
  final void Function(OddsOutcome)? onTapHome;
  final void Function(OddsOutcome)? onTapDraw;
  final void Function(OddsOutcome)? onTapAway;
  final VoidCallback? onMoreBets;
  final VoidCallback? onStats;
  final VoidCallback? onAi;

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
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Felső sáv: sport címke balra, „liga” jobbra (ha lenne)
            Row(
              children: [
                const Icon(Icons.flag, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.countryName.isNotEmpty || event.leagueName.isNotEmpty
                        ? [
                              event.countryName,
                              event.leagueName
                            ].where((e) => e.isNotEmpty).join(' • ')
                        : event.sportTitle,
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Jobbra igazított liga – jelenleg nincs megbízható adat → kihagyjuk
              ],
            ),
            const SizedBox(height: 8),

            // Csapat sor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TeamTile(name: event.homeTeam),
                const SizedBox(width: 12),
                _TeamTile(name: event.awayTeam, alignEnd: true),
              ],
            ),
            const SizedBox(height: 8),

            // Kezdési idő + visszaszámláló
            Row(
              children: [
                Text(
                  loc.starts_at(event.commenceTime.toLocal().toString()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                _Countdown(to: event.commenceTime),
              ],
            ),
            const SizedBox(height: 12),

            // H2H odds gombok
            if (h2hMarket != null)
              Row(
                children: [
                  Expanded(
                    child: _OddButton(
                      label: '1',
                      odd: home?.price,
                      onPressed: home != null
                          ? () => onTapHome?.call(home)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _OddButton(
                      label: 'X',
                      odd: draw?.price,
                      onPressed: draw != null
                          ? () => onTapDraw?.call(draw)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _OddButton(
                      label: '2',
                      odd: away?.price,
                      onPressed: away != null
                          ? () => onTapAway?.call(away)
                          : null,
                    ),
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(loc.events_screen_no_market),
              ),

            const SizedBox(height: 12),

            // Akciógombok sor
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onMoreBets,
                    child: Text(loc.more_bets),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onStats,
                    child: Text(loc.statistics),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onAi,
                    child: Text(loc.ai_recommendation),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                // egyszerű megjelenítés (pl. „Frissítve: most”)
                loc.updated_time_ago(''),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamTile extends StatelessWidget {
  final String name;
  final bool alignEnd;
  const _TeamTile({required this.name, this.alignEnd = false});
  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '?'));
    final title = Expanded(
      child: Text(
        name,
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        style: Theme.of(context).textTheme.titleMedium,
        overflow: TextOverflow.ellipsis,
      ),
    );
    return Expanded(
      child: Row(
        mainAxisAlignment: alignEnd
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: alignEnd
            ? [title, const SizedBox(width: 8), avatar]
            : [avatar, const SizedBox(width: 8), title],
      ),
    );
  }
}

class _OddButton extends StatelessWidget {
  final String label;
  final double? odd;
  final VoidCallback? onPressed;
  const _OddButton({required this.label, required this.odd, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: odd != null ? onPressed : null,
      child: Column(
        children: [
          Text(label, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(
            odd?.toStringAsFixed(2) ?? '--',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
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

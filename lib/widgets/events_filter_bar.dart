import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import 'package:tippmixapp/features/filters/events_filter.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/widgets/action_pill.dart';

typedef EventsFilterChanged = void Function(EventsFilter filter);

class EventsFilterBar extends StatefulWidget {
  final List<OddsEvent> source;
  final EventsFilter value;
  final EventsFilterChanged onChanged;
  const EventsFilterBar({
    super.key,
    required this.source,
    required this.value,
    required this.onChanged,
  });
  @override
  State<EventsFilterBar> createState() => _EventsFilterBarState();
}

class _EventsFilterBarState extends State<EventsFilterBar> {
  late EventsFilter f = widget.value;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final countries = ['', ...EventsFilter.countriesOf(widget.source)];
    final leagues = [
      '',
      ...EventsFilter.leaguesOf(widget.source, country: f.country),
    ];

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _DatePill(
                  date: f.date,
                  onChanged: (d) {
                    // Dátum váltáskor mind az ország, mind a liga nullázása
                    setState(() => f = f.copyWith(date: d, country: null, league: null));
                    widget.onChanged(f);
                  },
                ),
                _Drop(loc.filtersCountry, countries, f.country, (v) {
                  // Ország váltásakor a liga nullázása
                  setState(() => f = f.copyWith(
                    country: v?.isEmpty == true ? null : v,
                    league: null,
                  ));
                  widget.onChanged(f);
                }),
                _Drop(loc.filtersLeague, leagues, f.league, (v) {
                  setState(
                    () => f = f.copyWith(league: v?.isEmpty == true ? null : v),
                  );
                  widget.onChanged(f);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;
  const _DatePill({required this.date, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final text = date == null ? loc.filtersToday : _fmt(date!);
    return ActionPill(
      icon: Icons.event,
      label: text,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          firstDate: now.subtract(const Duration(days: 90)),
          lastDate: now.add(const Duration(days: 180)),
          initialDate: date ?? now,
        );
        onChanged(picked);
      },
    );
  }

  String _fmt(DateTime d) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${d.year}/${two(d.month)}/${two(d.day)}';
  }
}

class _Drop extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _Drop(this.label, this.items, this.value, this.onChanged);
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isDense: true,
      isExpanded: true,
      value: value ?? (items.isNotEmpty ? items.first : null),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e.isEmpty ? AppLocalizations.of(context)!.filtersAny : e,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

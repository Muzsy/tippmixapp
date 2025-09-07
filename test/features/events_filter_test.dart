import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/filters/events_filter.dart';
import 'package:tipsterino/models/odds_event.dart';

void main() {
  test('apply filters by date and country/league', () {
    final now = DateTime.now();
    final e1 = OddsEvent(
      id: '1',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'A',
      awayTeam: 'B',
      countryName: 'Hungary',
      leagueName: 'NB I',
      commenceTime: now,
      bookmakers: const [],
    );
    final e2 = OddsEvent(
      id: '2',
      sportKey: 'soccer',
      sportTitle: 'Soccer',
      homeTeam: 'C',
      awayTeam: 'D',
      countryName: 'England',
      leagueName: 'Premier League',
      commenceTime: now.add(const Duration(days: 1)),
      bookmakers: const [],
    );
    final src = [e1, e2];
    final f1 = EventsFilter(
      date: DateTime(now.year, now.month, now.day),
      country: 'Hungary',
    );
    final r1 = EventsFilter.apply(src, f1);
    expect(r1.length, 1);
    expect(r1.first.id, '1');
  });
}

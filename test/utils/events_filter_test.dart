import 'package:flutter_test/flutter_test.dart';
import 'package:tippmixapp/utils/events_filter.dart';
import 'package:tippmixapp/models/odds_event.dart';
import 'package:tippmixapp/models/odds_bookmaker.dart';

OddsEvent makeEvent(String id, DateTime when) => OddsEvent(
  id: id,
  sportKey: 'soccer',
  sportTitle: 'Soccer',
  homeTeam: 'A',
  awayTeam: 'B',
  commenceTime: when,
  bookmakers: const <OddsBookmaker>[],
);

void main() {
  test('filterActiveEvents keeps only future events (with 2m grace)', () {
    final now = DateTime.now();
    final items = [
      makeEvent('past', now.subtract(const Duration(minutes: 1))),
      makeEvent('soon', now.add(const Duration(minutes: 1, seconds: 30))),
      makeEvent('future', now.add(const Duration(minutes: 5))),
    ];
    final res = filterActiveEvents(items);
    expect(res.map((e) => e.id).toList(), ['future']);
  });
}

import '../models/odds_event.dart';

/// Csak a még fogadható (jövőbeli kezdésű) eseményeket adja vissza.
List<OddsEvent> filterActiveEvents(
  List<OddsEvent> events, {
  Duration grace = const Duration(minutes: 2),
}) {
  final cutoff = DateTime.now().add(grace);
  return events.where((e) => e.commenceTime.isAfter(cutoff)).toList();
}

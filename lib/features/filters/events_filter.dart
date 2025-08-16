import 'package:tippmixapp/models/odds_event.dart';

class EventsFilter {
  final DateTime? date; // only YMD
  final String? country;
  final String? league;
  const EventsFilter({this.date, this.country, this.league});

  EventsFilter copyWith({DateTime? date, String? country, String? league}) =>
      EventsFilter(date: date ?? this.date, country: country ?? this.country, league: league ?? this.league);

  static List<OddsEvent> apply(List<OddsEvent> source, EventsFilter f) {
    final ymd = f.date != null ? DateTime(f.date!.year, f.date!.month, f.date!.day) : null;
    return source.where((e) {
      final okDate = ymd == null
          ? true
          : (() {
              final d = e.commenceTime.toLocal();
              final ed = DateTime(d.year, d.month, d.day);
              return ed == ymd;
            })();
      final okCountry = (f.country == null || f.country!.isEmpty) ? true : (e.countryName == f.country);
      final okLeague = (f.league == null || f.league!.isEmpty) ? true : (e.leagueName == f.league);
      return okDate && okCountry && okLeague;
    }).toList();
  }

  static List<String> countriesOf(List<OddsEvent> source) =>
      source.map((e) => e.countryName).whereType<String>().toSet().toList()..sort();
  static List<String> leaguesOf(List<OddsEvent> source, {String? country}) =>
      source
          .where((e) => country == null || country.isEmpty || e.countryName == country)
          .map((e) => e.leagueName)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
}

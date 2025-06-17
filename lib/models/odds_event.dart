import 'odds_bookmaker.dart';

/// Egy sportesemény teljes OddsAPI reprezentációja.
class OddsEvent {
  final String id;         // OddsAPI esemény ID
  final String sportKey;   // Sportág azonosítója
  final String sportTitle; // Sportág neve
  final String homeTeam;
  final String awayTeam;
  final DateTime commenceTime;
  final List<OddsBookmaker> bookmakers;

  OddsEvent({
    required this.id,
    required this.sportKey,
    required this.sportTitle,
    required this.homeTeam,
    required this.awayTeam,
    required this.commenceTime,
    required this.bookmakers,
  });

  factory OddsEvent.fromJson(Map<String, dynamic> json) {
    return OddsEvent(
      id: json['id'] as String,
      sportKey: json['sport_key'] as String,
      sportTitle: json['sport_title'] as String,
      homeTeam: json['home_team'] as String,
      awayTeam: json['away_team'] as String,
      commenceTime: DateTime.parse(json['commence_time']),
      bookmakers: (json['bookmakers'] as List)
          .map((b) => OddsBookmaker.fromJson(b))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sport_key': sportKey,
    'sport_title': sportTitle,
    'home_team': homeTeam,
    'away_team': awayTeam,
    'commence_time': commenceTime.toIso8601String(),
    'bookmakers': bookmakers.map((b) => b.toJson()).toList(),
  };
}

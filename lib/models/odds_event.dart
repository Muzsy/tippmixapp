import 'odds_bookmaker.dart';

/// Egy sportesemény teljes OddsAPI reprezentációja.
class OddsEvent {
  final String id; // OddsAPI esemény ID
  final String sportKey; // Sportág azonosítója
  final String sportTitle; // Sportág neve
  final String homeTeam;
  final String awayTeam;
  final String? countryName;
  final String? leagueName;
  final String? leagueLogoUrl;
  final String? homeLogoUrl;
  final String? awayLogoUrl;
  final DateTime commenceTime;
  final List<OddsBookmaker> bookmakers;

  OddsEvent({
    required this.id,
    required this.sportKey,
    required this.sportTitle,
    required this.homeTeam,
    required this.awayTeam,
    this.countryName,
    this.leagueName,
    this.leagueLogoUrl,
    this.homeLogoUrl,
    this.awayLogoUrl,
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
      countryName: json['country_name'] as String?,
      leagueName: json['league_name'] as String?,
      leagueLogoUrl: json['league_logo_url'] as String?,
      homeLogoUrl: json['home_logo_url'] as String?,
      awayLogoUrl: json['away_logo_url'] as String?,
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
    if (countryName != null) 'country_name': countryName,
    if (leagueName != null) 'league_name': leagueName,
    if (leagueLogoUrl != null) 'league_logo_url': leagueLogoUrl,
    if (homeLogoUrl != null) 'home_logo_url': homeLogoUrl,
    if (awayLogoUrl != null) 'away_logo_url': awayLogoUrl,
    'commence_time': commenceTime.toIso8601String(),
    'bookmakers': bookmakers.map((b) => b.toJson()).toList(),
  };
}

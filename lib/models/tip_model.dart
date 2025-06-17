/// Felhasználói tipp egy adott esemény kimenetelére, odds-al.
class TipModel {
  final String eventId;
  final String eventName;
  final DateTime startTime;
  final String sportKey;
  final String bookmaker;   // pl. "Bet365"
  final String marketKey;   // pl. "h2h"
  final String outcome;     // pl. "Arsenal"
  final double odds;        // pl. 2.15

  // + egyedi azonosító, user id, tét összege, stb. ha kell!

  TipModel({
    required this.eventId,
    required this.eventName,
    required this.startTime,
    required this.sportKey,
    required this.bookmaker,
    required this.marketKey,
    required this.outcome,
    required this.odds,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) => TipModel(
    eventId: json['eventId'] as String,
    eventName: json['eventName'] as String,
    startTime: DateTime.parse(json['startTime']),
    sportKey: json['sportKey'] as String,
    bookmaker: json['bookmaker'] as String,
    marketKey: json['marketKey'] as String,
    outcome: json['outcome'] as String,
    odds: (json['odds'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'eventName': eventName,
    'startTime': startTime.toIso8601String(),
    'sportKey': sportKey,
    'bookmaker': bookmaker,
    'marketKey': marketKey,
    'outcome': outcome,
    'odds': odds,
  };
}

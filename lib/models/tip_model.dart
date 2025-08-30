/// Felhasználói tipp egy adott esemény kimenetelére, odds-al.
enum TipStatus { won, lost, pending }

class TipModel {
  final String eventId;
  final String eventName;
  final DateTime startTime;
  final String sportKey;
  final int? bookmakerId; // pl. 8 for Bet365
  final String? bookmaker; // legacy string key
  final String marketKey; // pl. "h2h"
  final String outcome; // pl. "Arsenal"
  final double odds; // pl. 2.15
  final TipStatus status;

  // + egyedi azonosító, user id, tét összege, stb. ha kell!

  TipModel({
    required this.eventId,
    required this.eventName,
    required this.startTime,
    required this.sportKey,
    this.bookmakerId,
    this.bookmaker,
    required this.marketKey,
    required this.outcome,
    required this.odds,
    this.status = TipStatus.pending,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      try {
        final ts = (v is! String && v is! DateTime && (v as dynamic).toDate is Function)
            ? v.toDate()
            : null;
        if (ts is DateTime) return ts;
      } catch (_) {}
      if (v is String) {
        final d = DateTime.tryParse(v);
        if (d != null) return d;
      }
      return DateTime.now();
    }

    double parseDouble(dynamic v, {double fallback = 1.0}) {
      if (v == null) return fallback;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    String asString(dynamic v, {String fallback = ''}) =>
        v == null ? fallback : v.toString();

    String parseStatus(dynamic v) {
      final raw = (v ?? 'pending').toString().toLowerCase();
      if (raw == 'win' || raw == 'won') return 'won';
      if (raw == 'lose' || raw == 'lost') return 'lost';
      return 'pending';
    }

    return TipModel(
      eventId: asString(json['eventId'] ?? json['id']),
      eventName: asString(json['eventName'] ?? json['name']),
      startTime: parseDate(json['startTime'] ?? json['commenceTime']),
      sportKey: asString(json['sportKey']),
      bookmakerId: parseInt(json['bookmakerId']),
      bookmaker: json['bookmaker'] == null ? null : asString(json['bookmaker']),
      marketKey: asString(json['marketKey'] ?? 'h2h'),
      outcome: asString(json['outcome']),
      odds: parseDouble(json['odds']),
      status: TipStatus.values.firstWhere(
        (e) => e.name == parseStatus(json['status']),
        orElse: () => TipStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'eventName': eventName,
    'startTime': startTime.toIso8601String(),
    'sportKey': sportKey,
    if (bookmakerId != null) 'bookmakerId': bookmakerId,
    if (bookmaker != null) 'bookmaker': bookmaker,
    'marketKey': marketKey,
    'outcome': outcome,
    'odds': odds,
    'status': status.name,
  };
}

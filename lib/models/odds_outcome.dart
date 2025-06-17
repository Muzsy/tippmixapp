/// Egy lehetséges kimenetel és annak odds értéke egy piacon belül.
class OddsOutcome {
  final String name;   // Pl. "Arsenal", "Draw"
  final double price;  // Pl. 2.15

  OddsOutcome({
    required this.name,
    required this.price,
  });

  factory OddsOutcome.fromJson(Map<String, dynamic> json) {
    return OddsOutcome(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
  };
}

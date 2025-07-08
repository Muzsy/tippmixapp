import 'package:flutter/material.dart';

class CoinsBalanceHeader extends StatelessWidget {
  final int coins;
  const CoinsBalanceHeader({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('Coins: $coins', style: Theme.of(context).textTheme.headline6),
    );
  }
}

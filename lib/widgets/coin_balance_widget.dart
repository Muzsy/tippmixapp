import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

/// Displays the user's TippCoin balance and rank badge.
class CoinBalanceWidget extends StatelessWidget {
  final int coin;
  final String rank;

  const CoinBalanceWidget({super.key, required this.coin, required this.rank});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.monetization_on,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text('${loc.home_coin}: $coin',
              style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          Chip(label: Text('${loc.profile_rank}: $rank')),
        ],
      ),
    );
  }
}

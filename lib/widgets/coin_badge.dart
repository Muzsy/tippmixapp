import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tipsterino/l10n/app_localizations.dart';

/// Small badge displaying TippCoin balance with an icon.
class CoinBadge extends StatelessWidget {
  final int? balance;
  const CoinBadge({super.key, this.balance});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final number = balance == null
        ? '—'
        : NumberFormat.compact(locale: locale).format(balance);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.monetization_on),
        const SizedBox(width: 4),
        Text(
          '${loc.profile_coins}: $number',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

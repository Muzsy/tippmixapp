import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class PromoPanel extends StatelessWidget {
  const PromoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.celebration, size: 64),
          const SizedBox(height: 16),
          Text(
            loc.login_variant_b_promo_title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(loc.login_variant_b_promo_subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

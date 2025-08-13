import 'package:flutter/material.dart';

class LeaguePill extends StatelessWidget {
  final String? country;
  final String? league;
  final String? logoUrl;
  const LeaguePill({super.key, this.country, this.league, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (country != null && country!.isNotEmpty) parts.add(country!);
    if (league != null && league!.isNotEmpty) parts.add(league!);
    final text = parts.join(' • ');
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (logoUrl != null && logoUrl!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Image.network(
              logoUrl!,
              width: 16,
              height: 16,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}

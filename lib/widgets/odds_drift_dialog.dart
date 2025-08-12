import 'package:flutter/material.dart';
import '../models/odds_drift.dart';

Future<bool> showOddsDriftDialog(
  BuildContext context,
  OddsDriftResult result,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Odds megváltozott'),
            content: SizedBox(
              width: 360,
              child: ListView(
                shrinkWrap: true,
                children: result.changes
                    .map(
                      (c) => ListTile(
                        dense: true,
                        title: Text('${c.market} / ${c.selection}'),
                        subtitle: Text(
                          'Régi: ${c.oldOdds.toStringAsFixed(2)}  →  Új: ${c.newOdds.toStringAsFixed(2)}',
                        ),
                        trailing: Icon(
                          c.increased ? Icons.trending_up : Icons.trending_down,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Mégse'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Elfogad'),
              ),
            ],
          );
        },
      ) ??
      false;
}

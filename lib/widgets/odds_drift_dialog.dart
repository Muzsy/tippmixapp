import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../models/odds_drift.dart';

Future<bool> showOddsDriftDialog(
  BuildContext context,
  OddsDriftResult result,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Semantics(
              header: true,
              label: AppLocalizations.of(ctx)!.oddsChangedTitle,
              child: Text(AppLocalizations.of(ctx)!.oddsChangedTitle),
            ),
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
                          '${AppLocalizations.of(ctx)!.oddsOld}: ${c.oldOdds.toStringAsFixed(2)}  →  ${AppLocalizations.of(ctx)!.oddsNew}: ${c.newOdds.toStringAsFixed(2)}',
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
              Tooltip(
                message: AppLocalizations.of(ctx)!.cancel,
                child: Semantics(
                  button: true,
                  label: AppLocalizations.of(ctx)!.cancel,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(AppLocalizations.of(ctx)!.cancel),
                  ),
                ),
              ),
              Tooltip(
                message: AppLocalizations.of(ctx)!.accept,
                child: Semantics(
                  button: true,
                  label: AppLocalizations.of(ctx)!.accept,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(AppLocalizations.of(ctx)!.accept),
                  ),
                ),
              ),
            ],
          );
        },
      ) ??
      false;
}

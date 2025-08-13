# 🃏 Event Bet Card Action Pills i18n (EN)

Adds namespaced localization keys for the three action pills on `EventBetCard`.

## Summary

- Introduces `app.actions.moreBets`, `app.actions.statistics` and `app.actions.aiRecommend` in the `app_*.arb` files.
- `EventBetCard` uses these keys via `AppLocalizations` getters.
- Widget test ensures German locale shows the "Weitere Wetten" label.

## Testing

- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`

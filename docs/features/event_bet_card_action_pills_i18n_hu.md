# 🃏 Tippkártya akciógombok i18n (HU)

A Tippkártya három akciógombjához (További fogadások, Statisztika, AI ajánló) névterezett lokalizációs kulcsok kerültek be.

## Összefoglaló

- Új `app.actions.moreBets`, `app.actions.statistics` és `app.actions.aiRecommend` kulcsok az `app_*.arb` fájlokban.
- Az `EventBetCard` ezeket az `AppLocalizations` gettereken keresztül használja.
- Widget teszt ellenőrzi, hogy német lokalé alatt megjelenik a "Weitere Wetten" felirat.

## Tesztelés

- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`

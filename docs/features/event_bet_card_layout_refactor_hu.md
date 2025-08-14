# 🎴 Tippkártya layout refaktor (HU)

Az `EventBetCard` widget átrendezése, hogy a meccsinformációk és akciók letisztultabban, informatívabban jelenjenek meg.

## Összefoglaló

- Ország név balra, liga név és logó jobbra igazítva.
- Hazai és vendég csapatnevek két sorig törhetők a jelvények mellett.
- A kezdés sornál balra visszaszámláló, jobbra formázott időpont.
- A H2H gombok az egységes `ActionPill` stílust használják.
- A frissítés időbélyege jobbra lent jelenik meg, az esemény vagy tartalék idő alapján.
- A kártya az esemény ID-jával kulcsolt, stabil listamegjelenítéshez.

## Tesztelés

- `flutter analyze --no-fatal-infos lib test integration_test bin tool`
- `flutter test`

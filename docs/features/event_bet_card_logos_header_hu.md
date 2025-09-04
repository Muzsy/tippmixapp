# 🃏 Tippkártya logók és fejlécek (HU)

Ez a dokumentum leírja az opcionális ország/liga fejléc és csapat-/liga‑logók hozzáadását az esemény tippkártyához.

---

## Összefoglaló

- Az `OddsEvent` modell opcionális `countryName`, `leagueName`, `leagueLogoUrl`, `homeLogoUrl` és `awayLogoUrl` mezőkkel bővült.
- Az `ApiFootballService` tölti ki az új mezőket a fixtures válasz alapján.
- A `TeamBadge` és `LeaguePill` widgetek logókat jelenítenek meg, hibakor monogramra esnek vissza.
- Az `EventBetCard` fejléc jobb oldalra zárt `country • league` sztringet mutat, a csapatnevek elé logót tesz.

## Tesztelés

- Widget tesztek ellenőrzik a fejlécet és a TeamBadge fallbacket.
- A `flutter analyze` és a `flutter test --concurrency=4` parancsoknak zölden kell futniuk.
- Lefedettség külön futtatásban (`flutter test --coverage`) készül CI-ben vagy manuálisan.

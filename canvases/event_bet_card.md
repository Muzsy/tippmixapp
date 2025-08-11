# Tippkártya (EventBetCard) – fogadási esemény kártya

## 🎯 Funkció

A fogadási események listájában egy egységes **Tippkártya** (EventBetCard) widget jeleníti meg az alap H2H (Hazai–Döntetlen–Vendég) oddsokat, a mérkőzés metaadatait (sport/„liga” címke, csapatok), a **kezdési időt + visszaszámlálót**, valamint három akciógombot: **További fogadások**, **Statisztika**, **AI ajánló**. A kártya az **OddsAPI**-ból érkező `OddsEvent` adatokból épül, és az **EventsScreen** listanézetében kerül felhasználásra.

## 🧠 Fejlesztési részletek

**Kiinduló állapot (repo valós kódja alapján):**

* Van `lib/screens/events_screen.dart`, amely jelenleg egy egyszerű, belső `_EventCard` megoldást használ H2H gombokkal.
* Adatmodell: `lib/models/odds_event.dart`, `lib/models/odds_bookmaker.dart`, `lib/models/odds_market.dart`, `lib/models/odds_outcome.dart`.
* Odds lekérés: `lib/services/odds_api_service.dart` + `lib/providers/odds_api_provider.dart`.
* L10n: `lib/l10n/app_{hu,en,de}.arb` + `lib/l10n/l10n.yaml`.
* GoRouter útvonal: `/bets` az `EventsScreen`-re (lásd `lib/router.dart`).

**Változtatások:**

1. **Új, újrahasznosítható widget**: `lib/widgets/event_bet_card.dart`

   * Felépítés a mockup szerint: felső sáv (sport/"liga" címke, zászló ikon), csapatsor (hazai – vendég, logó-helyettesítővel), **kezdési idő + visszaszámláló** (Stateful mini-komponens), **H2H odds** 3 gomb, alatta **3 akciógomb** egy sorban.
   * A zászló és liga esetén nem található megbízható ország/liganév a meglévő modellben → **sportTitle** jelenik meg balra, jobb oldalt opcionális „liga” (ha később bekerül), addig elrejtve. Zászló helyett **ikon** (Material `Icons.flag`) használata, hogy ne igényeljen új assetet.
   * Gomb-callbackek az `EventBetCard` konstruktorán keresztül érkeznek (→ tesztelhető). Alapértelmezésben az `EventsScreen` SnackBar-t mutat a három akcióra.

2. **EventsScreen integráció**

   * A belső `_EventCard` kiváltása az új `EventBetCard`-dal; import: `lib/widgets/event_bet_card.dart`.
   * A H2H gombok továbbra is az `OddsOutcome` adataiból készülnek.

3. **Lokalizáció**

   * Új kulcsok: `more_bets`, `statistics`, `ai_recommendation`, `updated_time_ago`, `starts_at`, `countdown_to_kickoff`.
   * Kulcsok mindhárom ARB-ben (`hu`, `en`, `de`) + `flutter gen-l10n` futtatás.

4. **Teszt**

   * `test/widgets/event_bet_card_test.dart`: render teszt (szövegek/gombok), H2H gombok léte, akciógombok léte és onTap hívás ellenőrzése (mock callback), visszaszámláló kezdeti értékének megjelenése egy közeljövőbeli `commenceTime`-nál.

**Nem módosítunk tiltott fájlokat** (android/, ios/, `pubspec.yaml`), nincs hard-coded szín (Theme-ből olvasunk), navigáció **GoRouter**-kompatibilis (az `EventsScreen` kezeli; a kártya csak callbacket ad vissza).

## 🧪 Tesztállapot

* [ ] Widget teszt: `event_bet_card_test.dart` – gombok és fő elemek megjelennek, onTap-ek meghívódnak.
* [ ] `flutter analyze` hibamentes.
* [ ] `flutter test` zöld.

## 🌍 Lokalizáció

* Új kulcsok a `lib/l10n/app_hu.arb`, `app_en.arb`, `app_de.arb` fájlokban.
* `flutter gen-l10n` futtatás a YAML-ban.

## 📎 Kapcsolódások

* Odds adat: `OddsApiService` / `odds_api_provider`.
* Későbbi bővítés: a **További fogadások** megnyithatja a részletes piaclistát; **Statisztika** csapat-stats képernyőt; **AI ajánló** AI‑tippek képernyőt. Jelen lépésben SnackBar/ callback.

---

### Hivatkozás

* Canvas → `/codex/goals/canvases/event_bet_card.yaml`

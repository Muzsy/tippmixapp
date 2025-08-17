# Fogadási oldal – finomítási dokumentáció

## 🎯 Funkció

A fogadási oldal jelenleg funkcionálisan működik, de több kisebb UX és logikai finomítás szükséges:

1. **Szűrés resetelése:** ország- és ligaszűrés logika helyreállítása.
2. **Gombstílus egységesítés:** a szűrési felület gombjai illeszkedjenek a tippkártyák gombjaihoz.
3. **Tippkártya időblokkjának rendezése:** kezdési időpont balra, visszaszámláló jobbra.
4. **Frissítve szöveg igazítása:** a tippkártya alján balra igazítás szükséges.

## 🧠 Fejlesztési részletek

### 1. Szűrés resetelése

* **Hely:** `lib/widgets/filter_bar.dart`, `lib/providers/filter_provider.dart`
* **Módosítás:**

  * Új ország választásakor a `leagueFilter` automatikusan álljon vissza `"mind"` alapállapotra.
  * Új dátum választásakor mind az `countryFilter`, mind a `leagueFilter` álljon vissza `"mind"` értékre.
* **Indok:** Megakadályozza, hogy érvénytelen liga maradjon kiválasztva országváltás után.

### 2. Gombstílus egységesítés

* **Hely:** `lib/widgets/filter_button.dart`, `lib/widgets/event_bet_card.dart`
* **Módosítás:**

  * A filter gombok stílusát állítsuk azonosra a tippkártyák gombstílusával (`primaryColor`, `shape`, `padding`).
  * Használja a közös `AppButtonStyles` definíciót.

### 3. Tippkártya időblokkjának rendezése

* **Hely:** `lib/widgets/event_bet_card.dart`
* **Módosítás:**

  * Az időblokknál `Row` sorrendjét fordítani: bal oldalra `kickoffTime`, jobb oldalra `countdown`.

### 4. Frissítve szöveg igazítása

* **Hely:** `lib/widgets/event_bet_card.dart`
* **Módosítás:**

  * Az alsó `Row`-ban a `Text("Frissítve ...")` igazítása `Alignment.centerLeft`.

## 🧪 Tesztállapot

* **Widget tesztek:**

  * Országváltás után a liga resetelés működésének ellenőrzése.
  * Dátumváltás utáni reset teszt.
  * UI teszt: gombstílusok egyezése snapshot alapján.
  * Tippkártya időblokkjának sorrendellenőrzése.
  * „Frissítve” szöveg pozíciójának ellenőrzése.

## 🌍 Lokalizáció

* Nem szükséges új nyelvi kulcs.
* A meglévő `AppLocalizations` feliratok változatlanok.

## 📎 Kapcsolódások

* **Kapcsolódó fájlok:**

  * `lib/widgets/filter_bar.dart`
  * `lib/providers/filter_provider.dart`
  * `lib/widgets/filter_button.dart`
  * `lib/widgets/event_bet_card.dart`
* **Kapcsolódó canvasek:**

  * `canvases/ticket_management_detailed_logic.md`
  * `canvases/api_football_frontend_service_and_oddsapi_removal.md`
* **Codex szabály:** `Codex Canvas Yaml Guide.pdf`

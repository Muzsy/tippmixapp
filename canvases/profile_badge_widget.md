## 🎯 Funkció

A `profile_badge.dart` fájl célja, hogy a felhasználó által megszerzett badge-eket látványosan jelenítse meg a profilképernyőn. A komponens reszponzív grid elrendezést és animációkat használ a gamifikációs élmény fokozására.

## 🧠 Fejlesztési részletek

* A komponens bemenete:

  * `List<BadgeData>` vagy `List<String>` (badge kulcsok)
  * Firestore-ból lekért adatok alapján jelenik meg

* Megjelenítési logika:

  * Grid layout (pl. `GridView.count`) ikonokkal és lokalizált címekkel
  * Az ikon `iconName` mező alapján kerül leképezésre (pl. `getIconForBadge(iconName)`)
  * A megszerzés ideje (timestamp) opcionálisan megjeleníthető tooltipben vagy alatta

* Animáció:

  * Hero animáció használható új badge megszerzésekor
  * `Confetti` vagy `FadeIn` animáció UI-keretrendszer szerint opcionális

## 🧪 Tesztállapot

* Widget tesztelés:

  * Badge lista megjelenítése, ikonleképzés, cím fordítása
  * Üres állapot (pl. „Még nem szereztél badge-et”) megfelelő renderelése

## 🌍 Lokalizáció

* A `BadgeData.key` alapján kerül betöltésre a `badge_<key>_title` és `badge_<key>_description` az ARB fájlokból.
* Fallback biztosítandó, ha a fordítás hiányzik

## 📎 Kapcsolódások

* `badge_service.dart`: a megszerzett badge-eket szolgáltatja
* `badge_icon_utils.dart`: az `iconName` → `IconData` leképezést végzi
* `badge.dart`, `badge_config.dart`: badge struktúra
* ARB fájlok: badge lokalizációs szövegek
* Kötelező Codex szabályok: `codex_context.yaml`, `localization_logic.md`, `routing_integrity.md`
* Háttérdokumentumok: `localization_best_practice.md`, `tippmix_app_teljes_adatmodell.md`

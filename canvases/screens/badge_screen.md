# 🌟 Jelvények képernyő (BadgeScreen)

A BadgeScreen önálló, teljes képernyős felület, amely a felhasználó által megszerzett és még el nem ért badge‑eket jeleníti meg, ezzel erősítve a gamifikációt【157201158825201†L0-L6】.

## 🎯 Funkció

* A badge‑ek grid vagy lista elrendezésben jelennek meg, opcionális szűrőkkel („Összes”, „Megvan”, „Hiányzik”)【157201158825201†L10-L13】.
* Jelvényre kattintva modal jeleníthet meg részleteket (ikon, feltétel, leírás)【157201158825201†L13-L15】.
* A képernyő a főmenüben (`/badges` útvonal) érhető el, valamint a Profil képernyőről „További jelvények” gomb vezet ide【157201158825201†L10-L16】.

## 🧠 Felépítés

* A jelvények metaadatai a `badge_model.md` és `badge_config.md` modulokban definiáltak.
* A megszerzett jelvények a `badge_service.md` segítségével kerülnek kiértékelésre és tárolásra【676551470588128†L6-L24】.
* A `BadgeScreen` a `profile_badge_widget` grid komponensét refaktorálja önálló widgetbe (pl. `BadgeGridView`)【157201158825201†L10-L12】.

## 🧪 Tesztállapot

Widget tesztek ellenőrzik, hogy a badge rács minden állapotot helyesen renderel (megszerzett/nem megszerzett), valamint lokalizációs tesztek a címkék és filterek megjelenését【157201158825201†L19-L24】.

## 🌍 Lokalizáció

A badge képernyő kulcsai (`menuBadges`, `badgeScreenTitle`, `badgeFilterAll`, `badgeFilterOwned`, `badgeFilterMissing`) az ARB fájlokban szerepelnek【157201158825201†L29-L39】.

## 📎 Modul hivatkozások

- `profile_badge_widget.md` – eredeti grid komponens.
- `badge_service.md`, `badge_model.md`, `badge_config.md` – a jelvények kiosztását és metaadatait kezelik【676551470588128†L6-L24】【180772964092141†L8-L20】.
- `localization_logic.md`, `routing_integrity.md` – útvonal és lokalizációs szabályok.
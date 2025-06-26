## 🌟 BadgeScreen – Jelvények

### 🌟 Funkció

A BadgeScreen egy önálló, teljes képernyős felület, amely a felhasználó által megszerzett és még el nem ért badge-eket jeleníti meg. A képernyő célja a gamifikáció erősítése, a badge gyűjtés motiválása. A már meglévő `profile_badge_widget` komponenst újrahasznosítja, de önállóvá teszi azt navigáció szempontból.

---

### 🧠 Fejlesztési részletek

* A `BadgeScreen` route neve: `/badges`
* A badge-ek gridje a `profile_badge_widget`-ből lesz refaktorálva, önálló widgetbe emelve (pl. `BadgeGridView`)
* Opcionálisan filter/tab funkció: „Összes” / „Megvan” / „Hiányzik”
* Jelvényre kattintva modal nyitható a részletekkel (ikon, feltétel, leírás)
* Drawer menöbe új menüpont: `menuBadges`
* Profil képernyőről egy "További jelvények" gomb

---

### 🧪 Tesztállapot

* Widget teszt: BadgeGridView rendesen renderel-e minden állapotot (megszerzett/nem megszerzett)
* Lokalizációs teszt: `badgeScreenTitle`, `badgeFilterAll`, `badgeFilterOwned`, `badgeFilterMissing` kulcsokra
* Tesztadat: Dummy BadgeData lista

---

### 🌍 Lokalizáció

ARB kulcsok:

```json
{
  "menuBadges": "Jelvényeim",
  "badgeScreenTitle": "Megszerezhető jelvények",
  "badgeFilterAll": "Összes",
  "badgeFilterOwned": "Megvan",
  "badgeFilterMissing": "Hiányzik"
}
```

Minden nyelven frissítendő (hu/en/de), `loc()` wrapperrel használandó.

---

### 📌 Kapcsolódások

* `profile_badge_widget.dart` → UI átvétel
* `badge_service.dart` → megszerzett badge-ek lekérdezése
* `badge_model.dart` / `badge_config.dart` → összes badge metaadat
* `routing_integrity.md` → route + menü konzisztencia
* `localization_logic.md` → ARB + enum kulcsok kezelése
* Codex YAML: `fill_canvas_badge_screen.yaml` (következő lépés)
    
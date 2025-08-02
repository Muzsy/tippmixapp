# ⚙️ Beállítások képernyő (SettingsScreen)

Ez a vászon a TippmixApp beállításait összegző képernyőt írja le.  A felület célja, hogy a felhasználók testreszabhassák az alkalmazás működését és megjelenését, legyen szó témáról, nyelvről vagy egyéb preferenciákról【366344286210520†L1-L17】.

## 🎯 Funkció

- **Téma mód** – a felhasználó választhatja a rendszer, világos vagy sötét módot【366344286210520†L8-L11】.
- **Nyelv** – három támogatott nyelv (hu/en/de) közötti váltás【366344286210520†L10-L12】.
- **Kijelentkezés** – lehetőség a fiókból való kijelentkezésre (`FirebaseAuth.signOut()`)【366344286210520†L12-L13】.
- **Előkészített funkciókapcsolók** – push értesítések, AI‑ajánlások kapcsolása, kedvenc sportágak megadása (jövőbeni bővítés)【366344286210520†L14-L17】.

## 🧠 Felépítés

A képernyő szekcióalapú, minden beállítás külön komponensben jelenik meg【366344286210520†L4-L8】.  A `SettingsSection` enum segítségével modulárisan bővíthető.  Ajánlott a `SettingsController` vagy StateNotifier alapú állapotkezelés, hogy a módosítások azonnal visszajelzést adjanak【366344286210520†L18-L19】.

## 📄 Kapcsolódó YAML fájlok

- `codex/goals/fill_canvas_settings_screen.yaml` – a beállítások képernyő generálására szolgáló Codex állomány.
- `codex/goals/fill_canvas_profile_notification_prefs.yaml` – az értesítési preferenciák külön modulját definiálja.

## 🐞 Fixek és tanulságok

Eddig kevés hibajavítás érkezett a beállítások képernyőhöz.  A jövőbeli fejlesztéseknél figyelni kell az állapotkezelés konzisztenciájára (pl. Provider vs. Riverpod), és arra, hogy a push/AI kapcsolók csak akkor érhetők el, ha a megfelelő szolgáltatások implementálva vannak.

## 🧪 Tesztállapot

A vászon widget teszteket sorol fel, amelyek minden szekció váltását és mentését ellenőrzik【366344286210520†L20-L25】.  Lokalizációs váltás tesztek biztosítják, hogy a nyelv állítása dinamikusan frissül, és sanity teszt fut három nyelven【366344286210520†L22-L25】.

## 📎 Modul hivatkozások

- `AppThemeController`, `AppLocaleController` – téma és nyelv váltás.
- `auth_provider.md` – kijelentkezés kezelése.
- Jövőbeni modulok (push toggle, AI‑ajánlások, kedvenc sportok) a `modules/` mappában kerülnek kialakításra.

# 👤 ProfileScreen – Adatmodell bővítése, default avatar logika, nickname, privacy flag

---

## 🎯 Funkció

A felhasználói profil backend alapjai:
- Default (nemsemleges) avatar asset logika, assets könyvtárban történő elhelyezés _manuális!_
- Firestore user dokumentum bővítése:  
  - Globális privát kapcsoló (`isPrivate`)
  - Mezőnkénti publikus/privát beállítás (`fieldVisibility`)
  - Egyedi nickname követelmény.
- Ezek adják az alapot minden későbbi privacy, publikus/profil megjelenítési logikához.

---

**Bemenet:**
- `/docs/tippmix_app_teljes_adatmodell.md` – A teljes felhasználói adatmodell, minden mező, privacy flag, nickname, default avatar logika innen származik.

---

## 🧠 Fejlesztési részletek

- **Default avatar logika:**  
  - A projektben manuálisan kell elhelyezni egy minimum 1 db nemsemleges default avatar képet:  
    - **Ajánlott hely:** `assets/avatar/default_avatar.png`
  - Az új felhasználók profilképének inicializálásakor ezt az assetet használja alapértelmezettként a rendszer.
  - _A Codex ne próbálja létrehozni vagy commitolni az asset fájlt!_
- **Firestore adatmodell:**  
  - `isPrivate` (globális privát kapcsoló, boolean)
  - `fieldVisibility` (object, pl. `{city: true, friends: false, favoriteTeams: false, favoriteSports: true, country: true}`)
  - Nickname minden usernél egyedi (szerveren ellenőrizve).
- **Nickname:**  
  - Egyediség validáció implementálása (regisztráció/szerkesztés előtt).

---

## 🧪 Tesztállapot

- Adatbázis bővítés: új mezők (`isPrivate`, `fieldVisibility`, `nickname`) helyes mentése.
- Default avatar logika: asset elérési út ellenőrzése, avatar inicializálása csak asset megléte esetén.
- Nickname egyediség backend oldali validációja.

---

## 🌍 Lokalizáció

- Ehhez a lépéshez még nem szükséges, a későbbi UI fázisban kerül be.

---

## 📎 Kapcsolódások

- **Firestore:** user dokumentum bővítése.
- **Assets:** default avatar asset elvárt helye, _de a fájlt nem hozza létre Codex_.
- **Backend:** nickname egyediség validálása.

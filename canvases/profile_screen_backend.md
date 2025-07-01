# 👤 ProfileScreen – Adatmodell bővítése, default avatar, nickname, privacy flag

---

## 🎯 Funkció

A felhasználói profil funkció backend-oldali alapjai:
- Default (nemsemleges) avatar asset bevezetése, assets könyvtárban.
- Firestore user dokumentum bővítése:  
  - Globális privát kapcsoló (`isPrivate`)
  - Mezőnkénti publikus/privát beállítás (`fieldVisibility`)
  - Egyedi nickname követelmény bevezetése.
- Ezek adják az alapot minden későbbi privacy, publikus/profil megjelenítési logikához.

---

**Bemenet:**
- `/docs/tippmix_app_teljes_adatmodell.md` – A teljes felhasználói adatmodell, minden mező, privacy flag, nickname, default avatar logika innen származik.

---

## 🧠 Fejlesztési részletek

- **Default avatar:**  
  - Új felhasználó regisztrációjakor automatikusan nemsemleges avatar kép (assetből).
  - Asset könyvtár létrehozása, minimum 1 default kép (unisex).
- **Firestore adatmodell:**  
  - `isPrivate` (globális privát kapcsoló, boolean).
  - `fieldVisibility` (object, pl. `{city: true, friends: false, favoriteTeams: false, favoriteSports: true, country: true}`).
  - Nickname minden usernél egyedi (szerveren ellenőrizve).
- **Nickname:**  
  - Egyediség validáció implementálása (regisztráció/szerkesztés előtt).

---

## 🧪 Tesztállapot

- Adatbázis bővítés: új mezők (`isPrivate`, `fieldVisibility`, `nickname`) helyes mentése.
- Default avatar asset kiosztás új felhasználónál.
- Nickname egyediség backend oldali validációja.

---

## 🌍 Lokalizáció

- Ehhez a lépéshez még nem szükséges, a későbbi UI fázisban kerül be.

---

## 📎 Kapcsolódások

- **Firestore:** user dokumentum bővítése.
- **Assets:** default avatar asset(ek) létrehozása, elérési út dokumentálása.
- **Backend:** nickname egyediség validálása.

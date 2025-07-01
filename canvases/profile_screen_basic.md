# 👤 ProfileScreen (alap logika, publikus/privát kezelés)

---

## 🎯 Funkció

A felhasználó profiloldala, ahol látható az egyedi nickname, az avatar, valamint a fő statisztikai adatok (TippCoin, szint, badges, nyerési arány, streak, kedvenc sport/csapat).  
Minden mezőhöz kapcsolódik egy publikus/privát beállítás (toggle), kivéve a nickname-et és az avatar-t, ezek mindig publikusak.  
A felhasználó beállíthat egy globális privát módot is, amely esetén csak az avatar és a nickname látható mások számára.

---

**Bemenet:**
- `/docs/tippmix_app_teljes_adatmodell.md` – A teljes adatmodell, ezen belül a felhasználói profil mezői, logikája és minden publikus/privát szabály forrása.

---

## 🧠 Fejlesztési részletek

- **Default avatar:** új regisztrációkor automatikusan beállított, nemsemleges asset képből.
- **Nickname:** minden usernél egyedi, ezt nem lehet elrejteni.
- **Publikus/privát kapcsolók:** a város, ország, barátlista, kedvenc sport/csapat mezőknél.
- **Globális privát kapcsoló:** minden további adatot elrejt, csak avatar + nickname látható.
- **Firestore struktúra bővítés:**  
  - `isPrivate`: boolean (globális)
  - `fieldVisibility`: object (pl. `{city: true, country: false, friends: true, favoriteSports: false, favoriteTeams: false}`)
- **Profilnézet:** külön képernyő, amely figyelembe veszi a privát/public szabályokat (saját profilnál minden látható, másnál csak ami publikus).
- **Nickname validáció:** egyediség biztosítása (regisztráció, szerkesztés).

---

## 🧪 Tesztállapot

- Alapprofil megjelenítése (avatar, nickname, fő statok, badges).
- Publikus/privát toggle működésének tesztje minden mezőn.
- Globális privát kapcsoló funkció tesztje (csak avatar+nickname látszik).
- Nickname egyediség-ellenőrzés.

---

## 🌍 Lokalizáció

- Új kulcsok:  
  - `profile.is_private`: "Privát profil"
  - `profile.public`: "Publikus"
  - `profile.private`: "Privát"
  - `profile.city`: "Város"
  - `profile.country`: "Ország"
  - `profile.friends`: "Barátok"
  - `profile.favorite_sports`: "Kedvenc sportok"
  - `profile.favorite_teams`: "Kedvenc csapatok"
  - `profile.nickname`: "Becenév"
  - `profile.stats`: "Statisztikák"
  - `profile.badges`: "Kitüntetések"
  - `profile.level`: "Szint"
  - `profile.coins`: "TippCoin"

---

## 📎 Kapcsolódások

- **Firestore:** felhasználói adatok (profil, statok, publikus/privát állapotok).
- **Firebase Auth:** nickname egyediség validálása.
- **Asset könyvtár:** default avatar képek.
- **UI komponensek:** profil header (avatar+nickname), stat csempe, publikus/privát kapcsolók, globális privát toggle.
- **Későbbi fázisokban:** szerkesztő felület, avatar feltöltés, profilnézet logika bővítése.

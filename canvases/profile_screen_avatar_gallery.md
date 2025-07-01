# 👤 ProfileScreen – Avatar galéria, saját kép feltöltés, default avatar logika

---

## 🎯 Funkció

Lehetővé teszi a felhasználónak, hogy:
- Előre feltöltött (asset) avatar képek közül válasszon egy galériában.
- Saját profilképet töltsön fel (pl. fénykép), amelyet a rendszer a Firebase Storage-ban tárol.
- Új regisztrációkor automatikusan egy nemsemleges default avatar (asset) legyen beállítva.
- Profil szerkesztő felületen egyszerűen cserélje az avatar képét, vagy visszaállítsa a default képre.
- Az avatar csak crop/resize-olható (nem szerkeszthető szűrővel, effekttel).

---

**Bemenet:**
- `/docs/tippmix_app_teljes_adatmodell.md` – Adatmodellben az avatarUrl mező és default avatar logika.
- `assets/avatar/` – Kézi asset könyvtár előre feltöltött galéria avatarokhoz.

---

## 🧠 Fejlesztési részletek

- **Avatar galéria:**  
  - Asset könyvtár: `assets/avatar/`, benne több, előre elkészített női/férfi/unisex avatar PNG (pl. avatar_1.png, avatar_2.png ...).
  - Profil szerkesztő UI: galéria grid nézet, bármely avatar kiválasztható.
  - Választás után az avatarUrl mező az asset path-ra mutat (pl. `assets/avatar/avatar_3.png`).
- **Saját kép feltöltése:**  
  - Felhasználó a galéria alatt tölthet fel saját képet (galériából/fotózással).
  - Kép automatikus átméretezése/crop.
  - Kép feltöltés a Firebase Storage-ba, az avatarUrl mező az URL-re mutat.
  - Fájlok méret- és típuskorlátozása (pl. max 1 MB, csak PNG/JPG).
- **Default avatar logika:**  
  - Új user regisztrációkor automatikusan a default_avatar.png (vagy .jpg) legyen az avatar.
  - Profil szerkesztőben bármikor visszaállítható.
- **Asset kezelés:**  
  - Az avatar asseteket kézzel kell feltölteni a `assets/avatar/` könyvtárba, a Codex nem generálja!
- **Elérési út dokumentálás:**  
  - Minden asset elérési útját pontosan dokumentálni kell a fejlesztői README-ben.

---

## 🧪 Tesztállapot

- Avatar galéria helyes betöltése és választás működése.
- Saját kép feltöltése, átméretezés/crop, Storage mentés.
- Default avatar logika működése új usernél és visszaállításkor.
- Hibakezelés: asset nem található, sikertelen feltöltés.

---

## 🌍 Lokalizáció

- Új kulcsok:
  - `profile.avatar_gallery`: "Avatar galéria"
  - `profile.upload_photo`: "Saját kép feltöltése"
  - `profile.reset_avatar`: "Alap avatar visszaállítása"
  - `profile.choose_avatar`: "Válassz avatart"
  - `profile.crop_image`: "Kép kivágása"
  - `profile.avatar_error`: "Hiba történt az avatar beállításakor"

---

## 📎 Kapcsolódások

- **Asset könyvtár:** kézi avatar assetek (assets/avatar).
- **UI:** profil szerkesztő, avatar galéria, saját kép feltöltő UI, cropper.
- **Backend:** avatarUrl mentése (asset útvonal vagy Storage URL), Firebase Storage integráció.
- **Lokalizáció:** galéria és feltöltés UI szövegek.

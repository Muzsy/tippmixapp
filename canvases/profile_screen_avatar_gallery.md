# 👤 ProfileScreen – Avatar galéria, saját kép feltöltés, default avatar logika

---

## 🎯 Funkció

Lehetővé teszi a felhasználónak, hogy:
- Előre feltöltött (asset) avatar képek közül válasszon egy galériában.
- Saját profilképet töltsön fel (pl. fénykép), amelyet a rendszer a Firebase Storage-ban tárol.
- Új regisztrációkor automatikusan egy nemsemleges default avatar legyen beállítva, ha az assets/avatar/ könyvtárban ténylegesen megtalálható a default avatar asset.
- Profil szerkesztő felületen egyszerűen cserélje az avatar képét, vagy visszaállíthassa a default képre.
- **Minden avatar asset, így a default_avatar.png létrehozása, generálása vagy commitolása Codex/automatizmus által KIFEJEZETTEN TILTOTT. Ezeket csak manuálisan, fejlesztői kézzel lehet feltölteni a projekt asset könyvtárába!**

---

**Bemenet:**
- `/docs/tippmix_app_teljes_adatmodell.md` – Adatmodellben az avatarUrl mező és default avatar logika.
- `assets/avatar/` – Asset könyvtár előre feltöltött galéria avatarokhoz (csak kézi feltöltés, Codex/automatizmus NEM hozhat létre assetet!).

---

## 🧠 Fejlesztési részletek

- **Avatar galéria:**  
  - Az `assets/avatar/` könyvtárban elhelyezett PNG/JPG képekből (kézi feltöltéssel) grid nézetben avatar galéria jelenik meg a profil szerkesztő UI-ban.
  - Kiválasztás után az avatarUrl mező az asset path-ra mutat (pl. `assets/avatar/avatar_3.png`).
- **Saját kép feltöltése:**  
  - Felhasználó saját képet tölthet fel (galériából vagy fényképezéssel).
  - Kép automatikus crop/resize.
  - Kép feltöltés a Firebase Storage-ba, avatarUrl az elérési Storage URL-re mutat.
  - Fájlformátum és méret ellenőrzés (pl. max 1 MB, csak PNG/JPG).
- **Default avatar logika:**  
  - Új user regisztrációjakor csak akkor állítsd be a default avatart, ha az `assets/avatar/default_avatar.png` ténylegesen létezik.
  - Profil szerkesztőben is csak akkor kínáld fel a visszaállítás lehetőségét, ha ez az asset elérhető.
  - **A Codex vagy bármilyen automatizmus számára szigorúan TILTOTT a default_avatar.png (vagy bármely avatar asset) generálása, commitolása vagy feltöltése! Ez manuális fejlesztői feladat!**
- **Asset elérési út dokumentálás:**  
  - A fejlesztőnek a README-ben vagy a projekt leírásában dokumentálnia kell, hogy milyen nevű/útvonalú képeket kell feltölteni az avatar galériához.

---

## 🧪 Tesztállapot

- Avatar galéria csak akkor jelenik meg, ha van kézi asset a mappában.
- Default avatar logika csak akkor fut, ha a default asset létezik.
- Hibakezelés: asset nem található vagy storage feltöltés sikertelen.

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

- **Asset könyvtár:** kézi avatar assetek (assets/avatar/).
- **UI:** profil szerkesztő, avatar galéria, saját kép feltöltő UI, cropper.
- **Backend:** avatarUrl mentése (asset útvonal vagy Storage URL), Firebase Storage integráció.
- **Lokalizáció:** galéria és feltöltés UI szövegek.

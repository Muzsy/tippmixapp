# 📝 Regisztrációs varázsló képernyő

🎯 **Funkció**

Többlépéses folyamatot biztosít új felhasználók regisztrációjához. A varázsló három szakaszból áll:

1. **Belépési adatok** – email és jelszó megadása;
2. **Profil és adatkezelési hozzájárulás** – becenév, születési dátum, jogi nyilatkozatok elfogadása;
3. **Avatar kiválasztás** – fénykép feltöltése vagy kamerával való készítése【144900569284079†L7-L11】【547170822863401†L7-L10】【345137367284607†L7-L10】.

🧠 **Felépítés**

- **Varázsló keretrendszer**: mindhárom lépés önálló aloldalként jelenik meg, közöttük „Tovább” és „Vissza” gombokkal lehet navigálni. A wizard skeleton megteremtése az első lépés feladata【144900569284079†L34-L38】.
- **1. lépés – Bejelentkezési adatok**: a `Step1` oldalon email és jelszó mezők jelennek meg, validációval (pl. min. 6 karakteres jelszó). Fájlok: `register_step1_widget.dart`, `auth_controller.dart`【144900569284079†L13-L21】. A mezők kitöltésekor a „Tovább” gomb csak akkor aktív, ha minden validáció teljesül.
- **2. lépés – Profil és hozzájárulás**: a felhasználó megadja a becenevet, a születési dátumot és jelölőnégyzetekkel elfogadja az adatkezelési feltételeket【547170822863401†L25-L33】. A validációt követően a `profile_controller.dart` a beviteli adatokat előkészíti. Fájlok: `register_step2_widget.dart` és kapcsolódó modellek【547170822863401†L13-L21】.
- **3. lépés – Avatar kiválasztás**: a felhasználó választhat a galériából vagy használhatja a kamerát; a képet arányosan 1:1-ben vágja, majd feltölti a tárhelyre【345137367284607†L15-L40】. Fájlok: `register_step3_widget.dart`, `avatar_picker.dart`.
- **Jogi és UX előírások**: Minden UI-szöveg lokalizált formában jelenik meg; modulonként `AutoDisposeProvider` használata javasolt a memória kezeléséhez; bináris assetek használata kerülendő【144900569284079†L56-L58】.

📄 **Kapcsolódó YAML fájlok**

- `fill_canvas_register_wizard_step1.yaml`, `fill_canvas_register_wizard_step2.yaml`, `fill_canvas_register_wizard_step3.yaml` – a lépések részletes céljait és DoD‑jét rögzítik.

🐞 **Fixek és tanulságok**

A regisztrációs varázsló fejlesztése során kiemelt figyelmet kell fordítani a validációk folyamatos ellenőrzésére, a többnyelvű támogatásra és a lépések közötti adatátadásra. Fixeket nem archiváltunk, de a hibákat a modulfejlesztés során folyamatosan kezelni kell.

🧪 **Tesztállapot**

A teszteknek lefedniük kell:

- a lépések közötti navigációt,
- az email és jelszó validációját (kötelező mezők, jelszó hossza),
- a GDPR checkboxok kötelező kiválasztását,
- az avatar feltöltés sikerességét és hibakezelését【144900569284079†L34-L38】【547170822863401†L39-L44】【345137367284607†L15-L40】.
Mindhárom lépéshez unit és widget teszteket kell írni.

📎 **Modul hivatkozások**

- A varázsló a [AuthProvider modul](../modules/auth_provider.md) funkcióit használja a regisztrációhoz.
- A végleges avatar feltöltést és a felhasználói adatokat a profil képernyő jeleníti meg (lásd [Profile Screen](profile_screen.md)).

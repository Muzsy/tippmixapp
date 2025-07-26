# 📑 Copy Bet Flow

🎯 **Funkció**

A funkció lehetővé teszi, hogy a felhasználók egy másik játékos által feltöltött tippmix szelvényt lemásoljanak a saját fiókjukba, majd később módosíthassák és csak módosítás után küldjék be【958187763017543†L0-L23】.

🧠 **Felépítés**

- **Felhasználói folyamat**: a feeden megjelenő szelvény mellett egy „Copy” gomb jelenik meg; erre kattintva a szelvény adatai a `copied_bets/{userId}/{copyId}` Firestore kollekcióba kerülnek【958187763017543†L8-L21】. A felhasználó ekkor egy értesítést kap („A szelvény a Jegyeim között található”), ahol később szerkesztheti.
- **Adatszerkezet**: a rekordok olyan mezőket tartalmaznak, mint `status` (initial/cancelled), `createdAt`, a másolt szelvény tartalma és a felhasználó által végzett módosítások. A `createdAt` alapján listázva a legutóbbi szelvények jelennek meg.
- **Jogosultságok**: felhasználók nem másolhatják le saját szelvényüket, és csak akkor küldhetik el a másolatot, ha változtatás történt.

📄 **Kapcsolódó YAML fájlok**

- `fill_canvas_copy_bet_flow.yaml` – a Codex célokat és teszteseteket rögzíti【958187763017543†L0-L23】.

🐞 **Fixek és tanulságok**

A funkcionalitás új fejlesztés, ezért archivált fixeket nem tartalmaz, de fontos felhívni a figyelmet a jogosultságok helyes kezelésére.

🧪 **Tesztállapot**

A specifikáció javasolja integrációs tesztek készítését, amelyek ellenőrzik:

- a sikeres másolás folyamatát,
- a saját szelvény másolásának tiltását,
- hogy módosítás nélkül a „Küldés” gomb inaktív marad,
- a `copied_bets` kollekció Firestore szabályainak megfelelését【958187763017543†L0-L23】.

📎 **Modul hivatkozások**

- Interakcióban áll a [Feed szolgáltatással](feed_service.md) és a felhasználói felületen megjelenő [Szelvény létrehozás](../screens/create_ticket_screen.md) képernyővel.
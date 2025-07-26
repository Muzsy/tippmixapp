# 🔐 Security Rules – coin_logs, badges, rewards és notifications

🎯 **Funkció**

Ismerteti a Firestore `coin_logs` gyűjteményhez tartozó biztonsági szabályokat, illetve a kapcsolódó `badges`, `rewards` és `notifications` gyűjtemények szabályait. Ezek a szabályok biztosítják, hogy csak a megfelelő felhasználó hozhat létre rekordokat, és hogy lekérdezéskor csak a saját adatai legyenek elérhetőek【806090729617628†L10-L18】.

🧠 **Felépítés**

- **`match /coin_logs/{id}`**: csak akkor engedélyezett a `create`, ha az összeget (`amount`) pozitív szám, a típus `credit` vagy `debit`, a `userId` megegyezik az authentikált felhasználó ID‑jével, és nincsenek módosított mezők; az `update` és `delete` műveletek minden esetben tiltottak【806090729617628†L10-L18】.
- **Olvasás** (`get`, `list`): csak a saját `userId` alapján megengedett.
- **Egyéb gyűjtemények**: a `badges`, `rewards` és `notifications` gyűjteményeken hasonló elvek érvényesek: csak a `userId` szerinti rekordok lekérdezhetőek, új rekord létrehozásakor ellenőrzött feltételek teljesülnek, a módosítás vagy törlés tiltott【806090729617628†L15-L18】.

📄 **Kapcsolódó YAML fájlok**

- `fill_canvas_security_rules_coin_logs.yaml` – a Codex célokat rögzíti és a végleges szabályok tesztjeit definiálja【806090729617628†L96-L102】.

🐞 **Fixek és tanulságok**

Ezek a szabályok megelőzik a jogosulatlan hozzáférést a tippcoin naplóhoz. Nincs külön archivált hiba ehhez a modulhoz.

🧪 **Tesztállapot**

A tesztek (SR‑01–SR‑10) ellenőrzik többek között, hogy:

- valid adatokkal végzett `create` művelet engedélyezett,
- hibás adatok vagy mismatching `userId` esetén a `create` elutasításra kerül,
- `update`/`delete` tiltások érvényesülnek,
- olvasás csak a saját `userId` szerint lehetséges【806090729617628†L49-L62】.

📎 **Modul hivatkozások**

- [TippCoinLog modell](tippcoin_log_model.md) – a napló rekordok adatszerkezetét és szolgáltatásait ismerteti.
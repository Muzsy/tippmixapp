# 🧾 TippCoinLogModel modul

## 🎯 Funkció

A TippCoinLogModel modul célja, hogy pénzügyi tranzakciók naplóját (**coin_logs** Firestore kollekció) kezelje. A modul bevezet egy új `TippCoinLogModel` osztályt a tranzakciók (debit/credit) reprezentálására, valamint egy mini service-t (`TippCoinLogService`) a bejegyzések naplózására【411777154765550†L24-L37】.

## 🧠 Felépítés

- **Adatmodell** – a modell mezői: `id`, `userId`, `amount`, `type`, `timestamp`, opcionálisan `txId` és `meta`【411777154765550†L12-L20】.
- **Firestore útvonal** – a tranzakciók a `/coin_logs/{id}` útvonalon tárolódnak, a lekérdezés `where('userId', isEqualTo: uid)` és `orderBy('timestamp', descending: true)` feltételekkel történik【411777154765550†L24-L27】.
- **Implementációs lépések** – új `lib/models/tippcoin_log_model.dart` fájl gyári konstruktorokkal, `collection` getterrel és konverziós metódusokkal; új `lib/services/tippcoin_log_service.dart` wrapper a `logDebit` és `logCredit` műveletekhez【411777154765550†L30-L38】.
- **Null‑safety & coverage** – a modul null‑safety kompatibilis és magas tesztlefedettséget céloz.

## 📄 Kapcsolódó YAML fájlok

- `codex/goals/fill_canvas_tippcoin_log_model.yaml` – a Codex futtatási cél, mely a modellhez és a service‑hez tartozó lépéseket definiálja【411777154765550†L97-L103】.

## 🐞 Fixek és tanulságok

Ez a modul új funkció, nem tartalmaz korábbi hibajavításokat. A korábbi tranzakciókezelés hiánya miatt fontos volt a megfelelő validáció és tesztlefedettség.

## 🧪 Tesztállapot

A modellhez három unit‑teszt (fromJson/toJson, pozitív/negatív amount kezelése, enum validáció) és három integrációs teszt (logCredit, logDebit, auto‑ID egyediség) készült a `cloud_firestore_mocks` használatával【411777154765550†L44-L58】. A tesztek célja a 90 % fölötti coverage elérése.

## 📎 Modul hivatkozások

- `modules/coin_service.md` – meglévő debit/credit hívások, amelyekhez a TippCoinLogService kapcsolódik【411777154765550†L76-L78】.
- `modules/security_rules_coin_logs.md` – a coin_logs kollekcióhoz tartozó Firestore security rules.

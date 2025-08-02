## 💰 CoinService modul

### 🎯 Funkció

A `CoinService` v2 felelős a TippCoin tranzakciók teljes körű, biztonságos kezeléséért.  Cél, hogy minden tranzakció auditálható, megismételhetetlen, validált és jogosultságilag ellenőrzött legyen【805619211344124†L2-L8】.

### 🧠 Fejlesztési részletek

- A szolgáltatás a Dart oldalon (`/lib/services/coin_service.dart`) működik, backend oldali logikával kiegészítve (`cloud_functions/coin_trx.ts`)【805619211344124†L11-L13】.
- **transactionId**: minden tranzakciónak egyedi azonosítója van; Cloud Function ellenőrzi, hogy még nem futott le korábban【805619211344124†L13-L16】.
- **Reason + amount korlátozás**: csak előre definiált bónusztípusok és azokhoz rendelt összegek engedélyezettek (pl. `daily_bonus`, `referral_bonus`)【805619211344124†L16-L18】.
- **Admin‑only műveletek**: coin reset, manuális beavatkozás külön function‑ben【805619211344124†L16-L18】.
- Fő metódusok: `creditCoin(userId, amount, reason, transactionId)` és `debitCoin(userId, amount, reason, transactionId)`【805619211344124†L19-L23】.
- A Cloud Function végzi el a tranzakciós írást (`coin_logs`), a user balance frissítését (Firestore `users` kollekció) és az összes validációt【805619211344124†L24-L28】.

### 🧪 Tesztállapot

Unit tesztek lefedik a CoinService és a kapcsolódó Cloud Functions működését, beleértve az invalid amount, duplikált transactionId, ismeretlen reason eseteket, valamint a tranzakciós rollbacket【805619211344124†L30-L35】.

### 🌍 Lokalizáció

A hibaüzenetek (például „Tranzakció elutasítva: duplikált transactionId” vagy „Ismeretlen bónusztípus”) lokalizáltak; a `reason` mező emberi olvasatra fordítható【805619211344124†L36-L40】.

### 📎 Kapcsolódások

- `submitTicket()` (CreateTicketScreen) – coin levonás fogadáskor【805619211344124†L43-L44】.
- `AuthService.register()` – regisztrációs bónusz jóváírása【805619211344124†L44-L45】.
- `DailyBonusJob` – napi bónusz jóváírása【805619211344124†L45-L46】.
- További funkciók: `referral_bonus.ts`, `bonus_policy.md` – a valid reason definíciói【805619211344124†L45-L46】.
- Biztonsági szabályok: `firebase.rules` – a `coin_logs` create‑only védelem és típus‑ellenőrzés【805619211344124†L47-L48】.
- Dokumentáció: `tippmix_app_teljes_adatmodell.md`, `bonus_policy.md`, `betting_ticket_data_model.md`【805619211344124†L49-L54】.

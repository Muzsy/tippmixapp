## 🎯 Funkció

A `daily_bonus_job` modul célja, hogy minden nap 00:05 CET időpontban automatikusan +50 TippCoin jutalmat adjon azoknak a felhasználóknak, akik megfelelnek az aktivitási feltételeknek. A logika egy Cloud Functionként valósul meg, amely Firestore-on keresztül írja jóvá az összeget.

---

## 🧠 Fejlesztési részletek

* A futtatás időzítése Firebase Cloud Scheduler + Cloud Functions kombinációval történik (`cron(5 0 * * *)` → 00:05 CET).
* A logika egy TypeScript alapú `daily_bonus.ts` fájlban kerül elhelyezésre a `cloud_functions/` könyvtárban.
* A felhasználók bejárása Firestore `users` kollekción keresztül történik.
* A jóváírás CoinService-kompatibilis struktúrában történik: `users/{userId}/coin_logs` kollekcióba új tranzakció kerül mentésre.
* Az összeg (+50 TippCoin) fix, jelenleg nem konfigurálható.
* A tranzakciós napló tartalmazza: `amount`, `type: 'daily_bonus'`, `timestamp`, `description` mezőket.
* A lokalizált visszajelző szöveg a következő kulccsal jelenik meg: `bonus_daily_received` (minden .arb fájlban).

---

## 🧪 Tesztállapot

* [ ] Unit test a napi bónusz logikára (mock Firestore + időzített trigger szimuláció)
* [ ] Sanity check: nem ír kétszer ugyanazon a napon
* [ ] Jogosultságok ellenőrzése: csak aktív felhasználók kapják

---

## 🌍 Lokalizáció

A következő kulcsok kötelezően szerepelnek minden `app_*.arb` fájlban:

* `bonus_daily_received` → "Napi bónusz: +50 TippCoin!"
* `bonus_daily_received_description` → "Köszönjük, hogy aktív vagy!"

A fallback nyelv működését a meglévő lokalizációs rendszer (AppLocalizations) biztosítja.

---

## 📎 Kapcsolódások

* `cloud_functions/daily_bonus.ts` (új fájl)
* `lib/services/coin_service.dart` (jóváírás függvényhívás)
* `lib/models/coin_log_model.dart` (ha létezik, külön modell)
* Lokalizáció: `app_hu.arb`, `app_en.arb`, `app_de.arb`

**Codex szabályfájlok:**

* `codex_docs/codex_context.yaml`
* `codex_docs/service_dependencies.md`
* `codex_docs/localization_logic.md`
* `codex_docs/priority_rules.md`

**Háttérdokumentumok:**

* `docs/auth_best_practice.md`
* `docs/tippmix_app_teljes_adatmodell.md`
* `docs/localization_best_practice.md`

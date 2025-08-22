# CF – Step 3: Bonus Engine (config + claim flow + checksum)

🎯 **Funkció**

* Bonus Engine bevezetése a két PDF alapján (globális szabály doc + per‑user állapot), a pénzügyi SoT érintése nélkül.
* **Callable** `claim_daily_bonus` (v2): *idempotens*, *versenyálló* jóváírás `wallet+ledger` tranzakcióban.
* **onUserCreate** kiegészítése: opcionális **signup bonus** a szabályok szerint (once, enabled), ledgerrel.
* **Checksum**: a `CoinService` bővítése `checksum` mező írásával minden ledger soron.
* **Rules** frissítés: `users/{uid}/bonus_state` kliens‑write tiltás, `system_configs/bonus_rules` csak olvasható kliensnek.

🧠 **Fejlesztési részletek**

* Globális szabály: `system_configs/bonus_rules` (doc) – killSwitch, daily.amount, daily.cooldownHours, maxPerDay, signup.enabled/once/amount, version.
* Per‑user állapot: `users/{uid}/bonus_state` (doc) – `signupClaimed`, `lastDailyClaimAt`, `dailyCooldownUntil`, `lastAppliedVersion`, `lock{active,expiresAt}`.
* **Idempotencia**: `refId = bonus:daily:YYYY-MM-DD` (UTC), ledger `type='bonus'`, `source='daily_bonus'` (vagy `signup_bonus`).
* **Optimista lock**: tranzakció elején `bonus_state.lock.active=false` → `true`; végén feloldás.
* **Checksum**: `SHA1(${uid}:${type}:${refId}:${amount})`.

🧪 **Tesztállapot**

* Kétszeri daily claim azonos napon → második hívás `FAILED_PRECONDITION` (cooldown). Ledgerben *maximum 1* új sor.
* Párhuzamos 10 claim → legfeljebb 1 sikeres (lock), többiek hibával térnek vissza.
* Signup bonus: új user esetén egyszer ír csak.

🌍 **Lokalizáció**

* A bonus típusok (`source: daily_bonus|signup_bonus`) kulcsok, lokalizáció kliensen.

📎 **Kapcsolódások**

* Előfeltétel: Step1–2 már kész (Gen2, secrets, SoT, admin hardening).
* Doksik: Bonus Engine – Firestore tárolási terv (v1), Tippmix App – User‑centrikus Firestore architektúra.

# 🎯 Funkció

A `daily_bonus` Cloud Function átállítása a végleges **user‑centrikus SoT**‑ra (\`users/{uid}/wallet\` + \`users/{uid}/ledger/{entryId}\`), a **coin\_logs** használat **teljes kivezetésével** és **idempotens jóváírással**.

---

# 🧠 Fejlesztési részletek

* A mostani buildben a \`cloud\_functions/lib/daily\_bonus.js\` még tartalmaz \`coin\_logs\` hivatkozást. Ez az átmeneti V1 struktúra maradványa.
* Cél: a `daily_bonus` csak a **CoinService().credit(uid, amount, refId)** híváson keresztül könyveljen. A **refId** legyen determinisztikus a napra (pl. `daily_bonus_YYYYMMDD`), így a hívás **idempotens**.
* A Ledgerben a `refId` mező alapján ne jöhessen létre duplikáció, a Wallet művelet pedig tranzakcióban történik a CoinService‑ben.

---

# 🧪 Tesztállapot

1. Kétszeri futtatás **azonos napon** → **1** ledger bejegyzés; a wallet csak **egyszer** nő.
2. Következő napon újra fut → új `refId`, új ledger bejegyzés, helyes wallet növekmény.
3. A buildelt `lib/` **nem** tartalmaz többé `coin_logs` előfordulást.

---

# 🌍 Lokalizáció

A végfelhasználói UI-t nem érinti; a ledger mezők megjelenítését a kliens meglévő lokalizációs rétege intézi.

---

# 📎 Kapcsolódások

* **Bonus Engine (rules/állapot)** változatlan; a `daily_bonus` jogosultság‑ és állapot‑ellenőrzése továbbra is CF-en belül.
* **CI**: a korábbi CI vászon alapján a Rules deploy és a friss `lib/` biztosított.

---

## Módosuló fájl

* `cloud_functions/src/daily_bonus.ts`

> Megjegyzés: a buildelt \`lib\` tartalom **nem** kézi szerkesztésre való; a forrás TS frissítése után kell újra buildelni (`npm ci && npm run build`).

# Sprint – Firestore biztonsági javítás: szelvény beküldés & ranglista

## Kontextus

A **cloud\_firestore/permission‑denied** hiba továbbra is felbukkan, amikor

* új szelvényt próbálunk beküldeni (\`BetSlipService.submit()\` → \`CoinService.debitCoin()\` → **/wallets** dokumentum írása),
* vagy a ranglista lekérdezésnél (\`StatsService.streamUserStats()\` → **/users** kollekció teljes listázása).

A jelenlegi **firebase.rules** csak a saját user‑dokumentum olvasását engedi,
és hiányzik a **/wallets** kollekció kezelése, ezért a fenti műveletek
engedélykérését a Firestore elutasítja.

## Cél (Goal)

Engedélyezni kell:

1. bármely hitelesített felhasználónak a \*/users\* kollekció read műveleteit
   (csak olvasás!) – ez kell a ranglistához;
2. a bejelentkezett felhasználónak a saját \*/wallets/{uid}\* dokumentum create/read/update műveleteit – ez kell a
   TippCoin levonáshoz szelvény beküldésekor.

## Feladatok

* [ ] **firebase.rules** módosítása

  * [ ] \*/users/{userId}\* match →  \`allow read: if signedIn();\`
  * [ ] Új **/wallets/{userId}** match blokk beillesztése (create/read/update csak saját doksira).
* [ ] Teszt‑szkript (\`security\_rules.test.mjs\`) bővítése két új esettel:

  * hitelesített kliens listázhatja a \`users\` kollekciót (elvárt: `allow`).
  * hitelesített kliens írhat saját \`wallets/{uid}\` dokumentumba (elvárt: `allow`).
* [ ] CI futtatás zölden lefut (analyze, test, security‑rules‑test).
* [ ] `firebase deploy --only firestore:rules` lefut hiba nélkül.

## Acceptance Criteria / Done Definition

* [ ] A ranglista képernyő lekéri és rendereli a toplistát hiba nélkül.
* [ ] Új szelvény beküldésekor **nem** kapunk `permission‑denied` hibát,
  a szelvény mentése és a Coin levonás sikeres.
* [ ] `flutter analyze` hibamentes.
* [ ] Security‑rules teszt 100 % pass.

## Hivatkozások

* Canvas → `/codex/goals/sprint_security_patch_leaderboard_wallet.yaml`
* Log kivonat a hibára: fileciteturn8file0
* Codex Canvas & YAML Guide: fileciteturn8file2


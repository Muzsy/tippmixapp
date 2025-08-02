# Sprint P0 – Firestore szabály javítás

## Kontextus

A kliensoldalon **cloud\_firestore/permission‑denied** hibát kapunk, amikor

* szelvényt küldünk be (`BetSlipService.submitTicket → tickets` kollekció `create`),
* megnyitjuk **Szelvényeim** (`MyTicketsScreen → tickets` `read`),
* lekérjük a **ranglistát** (`StatsService → users + tickets` `read`),
* bármely képernyőn TippCoin tranzakció történik (`CoinService → wallets` `read/write`).

A jelenlegi `firebase.rules` csak **coin\_logs**, **users (csak tulaj)**, **badges**, **notifications** stb. gyűjteményekre tartalmaz szabályokat, a fenti kollekciókra nem, ezért a Firestore elutasít.

## Cél

Új biztonsági szabályok, amelyek:

1. Engedélyezik a **tickets** kollekció írását a tulajdonosnak, olvasását minden bejelentkezett felhasználónak (leaderboard‑hoz).
2. Engedélyezik a **wallets** kollekció olvasását/írását csak tulajdonosnak.
3. Az **users** kollekció *read* jogosultságát kiterjesztik minden bejelentkezett felhasználóra (nickname, coins stb. publikus), *write* továbbra is csak tulaj.
4. Nem engednek semmilyen törlést az érintett kollekciókban kliens felől.

## Feladatok

* [ ] `firebase.rules` módosítása: `/users`, új `/wallets`, új `/tickets` matchek.
* [ ] Minimalista shape‑validáció `tickets` `create` esetén (kötelező mezők, userId == auth.uid).
* [ ] (Opcionális) Rule‑unit‑teszt `firebase‐emulator` alatt – **low effort** ezért kihagyjuk MVP‑ben.
* [ ] `flutter analyze` hibamentes marad.

## Acceptance Criteria / Done Definition

* [ ] A fenti képernyőkön többé **nem** kapunk `permission‑denied` hibát bejelentkezett felhasználóként.
* [ ] Hibás adatformátumra továbbra is hibával tér vissza (shape check).
* [ ] Más felhasználó pénztárcáját/szelvényét a szabályok **nem** engedik módosítani.
* [ ] Minden meglévő teszt zöld.

## Hivatkozások

* Canvas → `/codex/goals/firestore_rules_fix.yaml`

# UID → userId mezőnév-fix és Wallet-kredit bekötés (Match Finalizer)

## Cél

A **match\_finalizer** futásakor a szelvények (tickets) jelenleg függőben maradnak, és a jóváírás a `users/{uid}` dokumentum „balance/coins” mezőire próbál írni. A kliens viszont már a **wallets** kollekciót használja (idempotens ledgerrel). A két világ emiatt szétcsúszott, továbbá a ticket dokumentumban **`userId`** mező található, míg a finalizer **`uid`** mezőt keres.

## Talált problémák (aktuális kód alapján)

1. **Mezőütközés:** a `cloud_functions/src/match_finalizer.ts` a felhasználói ref-et így képezi: `db.collection('users').doc(snap.get('uid'))`, miközben a ticket doksiban **`userId`** van, és a dokumentum path is `/tickets/{uid}/tickets/{ticketId}` formájú.
2. **Wallet kihagyása:** a finalizer a felhasználói egyenleget közvetlenül `users/{uid}` alatt frissítené, miközben a kliens már a **`wallets/{uid}`** ágat és a ledger-t használja (lásd: `lib/services/coin_service.dart::debitAndCreateTicket`).
3. **Idempotencia:** a kifizetéshez nincs ledger-alapú védelem a finalizerben (dupla feldolgozás esetén ismételt jóváírás történhetne).

## Megoldás

* **Mezőnév-fix:** a felhasználó azonosítót a ticketből **`userId`** mezőből vagy (fallback) a dokumentum path-ból (`snap.ref.parent?.parent?.id`) olvassuk ki.
* **Wallet kreditálás:** a kifizetés után **CoinService.credit(uid, amount, ticketId)** hívással jóváírjuk a nyereményt a `wallets/{uid}` alatt. A **CoinService** már idempotens ledger-t használ (`ledger/{ticketId}`), így a dupla feldolgozás nem okoz többszöri jóváírást.
* **Users balance írásának kivezetése:** a finalizer többé **nem** ír a `users/{uid}` „balance/coins” mezőire – forrásként kizárólag a **wallets** szolgál.

## Érintett fájlok

* `cloud_functions/src/match_finalizer.ts` – import bővítés, users-balance update törlése, userId/uid kezelés, wallet kreditálás beillesztése.

## Várható eredmény

* A finalizer a pending szelvények tipjeit kiértékeli, **payout**-ot számol, a **ticket státuszt** frissíti (won/lost/void) és – ha **payout > 0** – **wallet jóváírást** végez idempotensen.
* A **`userId` vs `uid`** eltérés megszűnik: a finalizer helyesen találja meg a felhasználót.

## Megjegyzések

* A Cloud Functions Admin SDK **nem** esik Firestore Security Rules alá, így a wallet írás engedélyezett.
* A jóváírás összege a `calcTicketPayout` eredményének **kerekített** (Math.round) értéke TippCoinban.
* Hivatkozás: **wallet.pdf** (üzleti elv). A pontos módosítási diffeket lásd a hozzá tartozó Codex YAML-ban.

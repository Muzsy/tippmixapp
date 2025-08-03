# Sprint – TippCoin egyenleg‑integritás & atomikus szelvény‑létrehozás

## Kontextus

* A felhasználó **negatív egyenleggel** is be tud szelvényt küldeni, mert
  `CoinService.debitCoin()` *nem* vizsgálja a rendelkezésre álló
  TippCoin‑t, csak levonja (akár mínuszba).
* A levonás a **`wallets/{uid}`** dokumentum `coins` mezőjét módosítja, míg
  a UI a **`users/{uid}`** `coins` mezőt jeleníti meg → a változás nem
  látható.
* A `BetSlipService.submitTicket()` előbb hívja a debit‑et, majd külön
  írja a `tickets/{ticketId}` doksit, így ha közben a debit dob, **inkonzisztens**
  állapot állhat elő (coin levonva ⇢ ticket hiányzik v. fordítva).

## Cél (Goal)

* **Megakadályozni**, hogy a felhasználó a rendelkezésére álló TippCoin‑nál
  nagyobb tétet tegyen.
* A coin‑levonás és a ticket‑létrehozás **egy tranzakcióban** történjen.
* A levonás azonnal tükröződjön a `users/{uid}.coins` mezőn is, hogy a UI‑ban
  látható legyen.

## Feladatok

* [ ] **CoinService** → új `debitAndCreateTicket()` metódus

  * Firestore tranzakcióban:

    1. lekéri `wallets/{uid}.coins`‑t;
    2. ha `< stake` → `FirebaseException(insufficient_coins)`;
    3. különben `coins - stake` érték mind **wallets**, mind **users** doksiban;
    4. létrehozza `tickets/{ticketId}`‑t ugyanebben a tranzakcióban.
* [ ] **BetSlipService.submitTicket** refaktor: a fenti metódust hívja,
  elhagyja a külön ticket‑írást.
* [ ] **UI** (SubmitTicketButton) – kezelje az `insufficient_coins` hibát
  `SnackBar`‑ral.
* [ ] **Teszt**: unit + widget

  * negatív egyenleg esetén hibát dob;
  * elegendő egyenlegnél sikeresen létrejön a ticket és csökken az egyenleg.
* [ ] CI: `flutter analyze` + `flutter test` zöld.

## Acceptance Criteria / Done Definition

* [ ] A felhasználó nem tud nagyobb tétet tenni, hibaüzenetet kap.
* [ ] Sikeres fogadás után **mindkét** kollekcióban (wallets, users) a
  `coins` mező csökken a tét összegével.
* [ ] Firestore‑ban nincs negatív `coins` érték.
* [ ] `flutter analyze` hibamentes, tesztek 100 % pass.

## Hivatkozások

* Canvas → `/codex/goals/ticket_coin_integrity.yaml`
* Forráskód: `lib/services/coin_service.dart`,
  `lib/services/bet_slip_service.dart`,
  `lib/screens/betslip/submit_ticket_button.dart`
* Codex Canvas & YAML Guide fileciteturn14file1

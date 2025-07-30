# Coin logs Cloud Function

Ez a funkció a kliens helyett végzi a TippCoin tranzakciók naplózását. HTTPS callable formában érhető el `log_coin` néven az `europe-central2` régióban.

## Használat kliens oldalon

A `TippCoinLogService` a `log_coin` felhőt hívja meg, ahol azonosított felhasználó esetén a következő adatokat várja:

- `amount` – a tranzakció összege
- `type` – a tranzakció típusa (`bet`, `deposit`, `withdraw`, `adjust`)
- `transactionId` – egyedi azonosító
- `meta` – opcionális metaadatok

A Cloud Function ellenőrzi a paramétereket, majd rögzíti a `coin_logs` kollekcióban. A felhasználók csak olvasási jogosultsággal rendelkeznek, írást kizárólag a function végezhet.

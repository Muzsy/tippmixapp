# Sprint – Wallet kollekció bevezetése (lazy‑create) & dokumentáció frissítés

## Kontextus

A korábbi javítás után a **wallets** kollekció még nem létezett, ezért a
coin‑egyenleget a `users/{uid}.coins` mezőből olvassuk és *lazy‑create* módszerrel
hozzuk létre a `wallets/{uid}` dokumentumot az első tranzakciónál.  Ehhez a
backend kódot már módosítottuk, de a **dokumentáció** (Data Model) még mindig
azt állítja, hogy az egyenleg a UserModel része.

Az inkonzisztens dokumentáció félrevezető; illetve hiányzik a WalletModel
formális definíciója.  A /docs könyvtárban jelenleg két érintett fájl van:

* `docs/backend/data_model_en.md`
* `docs/backend/data_model_hu.md`

Ezeket kell naprakészre hozni.

## Cél (Goal)

* A Data Model dokumentumok tükrözzék, hogy a TippCoin‑egyenleg **elsődlegesen**
  a `wallets` kollekcióba került, a `users.coins` mező **deprecated**.
* Tartalmazzanak egy új **WalletModel** leírást (mezők: coins, createdAt).
* Egyértelműen jelezzék, hogy a `wallets` doksi a kliens tranzakció első
  fogadásakor jön létre, de a hosszú távú terv szerint **Auth onCreate Cloud
  Function** fogja inicializálni.

## Feladatok

1. **CoinService**: finomítás – ha hiányzik a wallet doksi, a tranzakció
   `set()`-tel hozza létre (coins + createdAt), majd minden esetben frissíti.
2. **docs/backend/data\_model\_en.md** módosítása

   * UserModel: `coins` mezőre *Deprecated* badge + rövid magyarázat.
   * Új "💰 WalletModel" szakasz táblázattal.
3. **docs/backend/data\_model\_hu.md** módosítása (ugyanez magyarul).
4. **README**-k frissítése nem szükséges, mert az architektúra‑doksik már
   említik a walletet.
5. CI: `flutter analyze` + `flutter test` zöld, `markdownlint` (ha fut) is.

## Acceptance Criteria

* [ ] A CoinService tranzakciója mindig létrehozza/frissíti a wallet doksit.
* [ ] A Data Model EN & HU fájlok a walletet dokumentálják és a `users.coins`
  mezőnél *DEPRECATED* jelölést tartalmaznak.
* [ ] A pipeline minden tesztje zöld.

## Hivatkozások

* Canvas → `/codex/goals/wallet_lazy_init_docs.yaml`
* Érintett fájlok: `lib/services/coin_service.dart`,
  `docs/backend/data_model_en.md`, `docs/backend/data_model_hu.md`

# Cloud Functions – Finalizer hardening (batch + idempotencia + DLQ)

## Kontextus

A szelvény‑finalizer kritikus pénzmozgást indít (wallet/ledger jóváírás). Nagy terhelésnél és időszakos hibáknál a duplikált könyvelés és az elakadt üzenetek kockázata nő. A jelenlegi implementáció 200‑as limitig listáz „pending” szelvényeket, de nincs lapozás és a CoinService tranzakció idempotenciája csak részben véd (ledger doc azonos refId‑val felülíródik, viszont a wallet `increment` duplázódhat).

## 🎯 Funkció

1. **Biztonságos, lapozott feldolgozás** gyűjtőkollekción (collectionGroup) keresztül.
2. **Erős idempotencia**: a ledger‑bejegyzés megléte esetén a wallet növelése kihagyásra kerül (no‑op).
3. **DLQ**: tartós hiba esetén üzenet Dead‑Letter Queue‑ba kerül; átmeneti hibáknál újra soroljuk, kontrollált számlálóval.
4. **Strukturált naplózás**: `correlationId=ticketId`, batch‑mutatók (batch index, elemszám), kimenetek (`OK/RETRY/DLQ`).

## 🧠 Fejlesztési részletek

* **Batching & lapozás**: `orderBy('__name__') + startAfter(lastDoc)`; `BATCH_SIZE` és `MAX_BATCHES` env‑vel hangolható.
* **Önmagát újrasoroló futás**: ha további tételek várhatók, a függvény a végén **új üzenetet** publikál a `result-check` topikba (attempt=0), így tovább lép a következő lapra.
* **DLQ logika**: ha futás közben hiba történik, a `message.attributes.attempt` alapján döntünk: `attempt >= 2` → DLQ (`match_finalizer-dlq`), különben requeue (`attempt+1`). Ilyenkor **nem dobunk kivételt**, így az aktuális futás ack‑olódik.
* **Idempotencia a CoinService‑ben**: a tranzakció **előtt** ellenőrizzük a `users/{uid}/ledger/{refId}` létezését; ha megvan → **no‑op**, különben wallet `increment` + ledger rögzítés egy tranzakcióban.

## 🧪 Tesztállapot

* CF unit/integ tesztek változatlanok maradnak. A hardening a meglévő útvonalakat nem módosítja, csak védelmi réteget ad. (Később külön PR‑ben hozzáadható mesterséges ütköztetés‑teszt.)

## 🌍 Lokalizáció

* Nincs felhasználói szöveg‑változás, i18n érintetlen.

## 📎 Kapcsolódások

* CoinService (wallet/ledger), ApiFootballResultProvider, Pub/Sub `result-check` és `match_finalizer-dlq` topikok.

---

**Megjegyzés**: A részletes difffek és futtatandó lépések a YAML‑ban: `/codex/goals/canvases/fill_canvas_finalizer_hardening.yaml`. A Codex Canvas Yaml Guide alapján készült.

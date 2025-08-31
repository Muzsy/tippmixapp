# 🎯 Összefoglaló

A feladatok célja, hogy a **TippmixApp match\_finalizer Cloud Function** futtatása **skálázhatóan és megbízhatóan működjön**, akkor is, ha több ezer felhasználó fogad több ezer eseményre. A megoldás lényege, hogy a terhelés a lezáruló **meccsek számával** arányos legyen, ne a felhasználók vagy tippek számával, és biztosítva legyen az **idempotens működés**, a **Pub/Sub visszaterhelés kezelése** és a **Firestore írási limitek betartása**.

Az alábbi részletes feladatlista lépésről lépésre végigvezet a beállításokon, a futtatási stratégián és a skálázás biztosításán.

---

# ✅ Feladatlista

## 1. Üzenetkezelés stratégiája

* [ ] **Döntsd el az üzenet kulcsát:** minden finalize üzenet kizárólag egyetlen `fixtureId`-ot tartalmazzon, ne szelvény ID-kat.
* [ ] **Állítsd be az upstream rendszert**, hogy minden lezáruló meccs után 1 üzenetet tegyen a `result-check` topicra:

  ```json
  {"type":"finalize","fixtureId":"123456"}
  ```
* [ ] Ellenőrizd, hogy a `match_finalizer` kódja a `findFixtureIdByMeta` fallback-et csak akkor használja, ha nincs fixtureId.

## 2. Firestore olvasás/írás optimalizálása

* [ ] Ellenőrizd, hogy a `tips` gyűjtemény indexelve van `fixtureId` + `status` szerint.
* [ ] Valósítsd meg a **collection group query**-t, amely `fixtureId` + `status == pending` szerint szűr.
* [ ] Készíts **lapozást**: egyszerre max. 300–500 dokumentumot olvass, `startAfter()` kurzorral folytatva.
* [ ] Az írást **BulkWriter** vagy max. 400-as batchek segítségével végezd.
* [ ] Azonos felhasználóhoz tartozó tippeket lehetőleg egy batchbe írd.

## 3. Cloud Functions Gen2 beállítások

* [ ] Deploy paraméterek:

  * régió: `europe-central2`
  * runtime: `nodejs20`
  * max-instances: 30 (kezdésnek)
  * min-instances: 1–2
  * concurrency: 10–20
  * memória: 1–2 GiB
* [ ] Állítsd be az env változókat: `RESULT_TOPIC`, `DLQ_TOPIC`, `API_FOOTBALL_KEY`.
* [ ] Használj idempotens tranzakciókat a `CoinService`-ben (ledger + refId).

## 4. Scheduler beállítása (sweep / diag-check)

* [ ] Hozz létre egy **Cloud Scheduler jobot**, ami 5 percenként fut:

  ```bash
  gcloud scheduler jobs create pubsub finalizer-kick \
    --project=tippmix-prod \
    --location=europe-central2 \
    --schedule="*/5 * * * *" \
    --topic="result-check" \
    --message-body='{"type":"diag-check","ts":"auto"}'
  ```
* [ ] Ellenőrizd, hogy a `diag-check` üzeneteket a `match_finalizer` logolja, és szükség esetén indít ellenőrzést.

## 5. DLQ kezelés

* [ ] Ellenőrizd, hogy van-e `result-check-dlq` topic.
* [ ] Konfiguráld a `match_finalizer`-t, hogy hibás üzeneteket DLQ-ba küldjön.
* [ ] Készíts dokumentált folyamatot: hogyan kell DLQ-ból üzenetet manuálisan visszatenni a fő topicra.

## 6. Retries és backoff

* [ ] Engedélyezd a Pub/Sub retry mechanizmust.
* [ ] Ellenőrizd, hogy az üzenet payload tartalmaz `attempt` mezőt.
* [ ] Biztosítsd, hogy az `attempt` növekszik újrapróbánál, és a kód backoff stratégiát alkalmaz.

## 7. Megfigyelés és monitoring

* [ ] Állíts be log alapú metrikákat:

  * kiértékelt tippek száma
  * lezárt szelvények száma
  * coin tranzakciók száma
  * hiba arány
* [ ] Állíts be riasztást, ha a DLQ-ban nő az üzenetek száma.
* [ ] Exportáld a metrikákat BigQuery-be és készíts egyszerű dashboardot.

## 8. Hotspot és költségvédelem

* [ ] Vizsgáld meg, hogy a `users/<uid>/wallet` dokumentumokra nem írsz-e túl sokszor rövid idő alatt.
* [ ] Használj ledger alapú tárolást + periodikus összesítést a balance kiszámításához.
* [ ] Cache-eld az API-Football lekérdezéseket 60–120 másodpercre, hogy ne duplikáld a kéréseket.

## 9. Opcionális nightly sweep (későbbre)

* [ ] Tervezd be, hogy napi egyszer (pl. éjjel 2-kor) egy Dataflow/Batch job végigmegy minden `finished` meccsen.
* [ ] Ez a fallback biztosítja, hogy semmi ne maradjon pending státuszban tartósan.

---

# 📎 Eredmény

Ha a fenti lépéseket végrehajtod:

* A `match_finalizer` futása a meccsek számával skálázódik, nem a felhasználók számával.
* Firestore írási és API-hívási limitek betartása biztosított.
* Megbízható, retry- és DLQ-barát futás lesz, amely bármikor kézzel is újraindítható.
* A rendszer alkalmas több ezer user × több ezer fogadás skálán is stabilan működni.

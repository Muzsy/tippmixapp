# Prompt — CloudEvent-biztos Pub/Sub handler javítása

## CÉL

A Pub/Sub Gen2 függvény (entry-point: `match_finalizer`) legyen CloudEvent-kompatibilis, defenzív és részletesen logoló.
Kerüljük el a tipikus hibákat:

* rossz eseménytípus (BackgroundFunction helyett CloudEvent),
* hiányzó/null message,
* base64/JSON parse kivétel,
* csendes dobás miatti végtelen retry.

---

## FELADATOK

### 1) KÓD FELTÁRÁS

* Keresd meg a “match\_finalizer” entry-pointot vagy a Pub/Sub handler(eke)t a `cloud_functions` mappában (TypeScript elsődleges).
* Ha van meglévő handler, mutasd a fájl útvonalát és a releváns kivonatát.
* Ha nincs, hozz létre egy új TypeScript modult:

  ```
  cloud_functions/src/match_finalizer.ts
  ```

  és exportáld benne a `match_finalizer` CloudEvent függvényt.

### 2) JAVÍTÁS / IMPLEMENTÁCIÓ

* Használd a CloudEvent szignatúrát:

  ```ts
  import type { CloudEvent } from '@google-cloud/functions-framework';
  import type { MessagePublishedData } from '@google/events/cloud/pubsub/v1/MessagePublishedData';

  export async function match_finalizer(cloudevent: CloudEvent<MessagePublishedData>) { ... }
  ```
* Kötelező defenzív mezők:

  ```ts
  const msg = cloudevent?.data?.message;
  const messageId = msg?.messageId ?? 'unknown';
  const attributes = msg?.attributes ?? {};
  const dataB64 = msg?.data ?? '';
  ```
* Base64 → JSON parse biztonságosan (ne dobjon kivételt):

  ```ts
  function tryParseBase64Json(b64: string): any {
    try {
      if (!b64) return null;
      const raw = Buffer.from(b64, 'base64').toString('utf8');
      try { return JSON.parse(raw); } catch { return { _raw: raw }; }
    } catch { return null; }
  }
  ```
* Kezdő log minden hívásnál:

  ```ts
  console.info('[match_finalizer] recv', {
    messageId, attributes,
    hasData: Boolean(dataB64),
    ceType: cloudevent?.type,
    ceSource: cloudevent?.source,
    ceSubject: cloudevent?.subject
  });
  ```
* Payload kinyerés:

  ```ts
  const payload = tryParseBase64Json(dataB64);
  ```
* Ha érvénytelen/hiányzó payload → `WARN` és `return`.
* Üzleti logika `try/catch` keretben:

  ```ts
  try {
    // TODO: processMatchResult(payload);
    console.info('[match_finalizer] done', { messageId });
  } catch (err) {
    console.error('[match_finalizer] error', { messageId, error: String(err) });
    throw err; // vagy return, ha nem kell retry
  }
  ```

### 3) TÍPUSOK/BUILD

* Ellenőrizd a TS build-beállításokat (`tsconfig.json`).
* Szükség esetén `package.json` kiegészítése:

  ```json
  "scripts": {
    "build": "tsc -p ."
  }
  ```

### 4) LOG STÍLUS

* Ne logolj teljes payloadot, csak rövid kivonatot.
* Mindig tedd bele a `messageId`-t és `attributes`-t.

### 5) OUTPUT

* Mutasd a minimális diffet (csak érintett fájlok).
* Írj rövid összegzést: mit találtál, mit javítottál, miért CloudEvent-biztos.
* Ha új fájlt hoztál létre, jelezd (`create cloud_functions/src/match_finalizer.ts`).

---

## VALIDÁLÁS (kézi, fejlesztő végzi)

```bash
PROJECT=tippmix-dev REGION=europe-central2 FUNC=match_finalizer TOPIC=result-check ./scripts/mf_quick.sh
```

Siker kritériumok:

* Logban: `[match_finalizer] recv { messageId, attributes, … }`
* Érvényes payloadnál: `[match_finalizer] done`
* Hibás/hiányzó payloadnál: WARN és return; nincs kontrollálatlan kivétel.

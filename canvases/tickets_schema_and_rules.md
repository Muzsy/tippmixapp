# Szelvénykezelés – Firestore `tickets` séma & biztonsági szabályok (read‑only kliens, szerver oldali írás)

## Kontextus

Az API‑Football átállás után a szelvénykezelés (ticket létrehozás → kiértékelés → jóváírás) Cloud Functions‑ön fut, Admin SDK‑val. A Firestore jelenleg üres (nincs `tickets`/`matches`). Célunk egy olyan **provider‑független** adatmodell és biztonsági szabályrendszer, amelyben a kliens **csak olvas**, az írást a Functions végzi (az Admin SDK **megkerüli** a rules‑t, így biztosítható az atomikus levonás/jóváírás).

## Cél (Goal)

Definiáljuk a `tickets` kollekció sémáját és indexeit, hozzunk létre **kliens‑read‑only** szabályokat a `tickets` (és opcionális `tickets_drafts`) kollekcióra, dokumentáljuk és tesztelhető, izolált szabályfájlként adjuk át (a meglévő `firestore.rules` felülírása nélkül).

## Feladatok

* [x] **Séma doksi**: `docs/backend/firestore_tickets_schema.md` – mezők, típusok, példák, státuszgraf
* [x] **Biztonsági szabály‑overlay**: `security/tickets.rules` – csak saját ticket **olvasható**, **írás tiltott** (kivéve opcionális `tickets_drafts` kliens‑draftok)
* [x] **Indexek**: `firestore.indexes.json` – `tickets` by `(userId, createdAt desc)` és `(status, createdAt desc)`
* [x] **Smoke ellenőrzés**: `flutter analyze` + Functions build/test érintetlenül zöld (nem nyúlunk aktív rule‑fájlhoz)

## Acceptance Criteria / Done Definition

* [x] A repo tartalmazza a `docs/backend/firestore_tickets_schema.md` fájlt részletes meződefiníciókkal és mintákkal
* [x] Létezik egy **izolált** szabályfájl: `security/tickets.rules` a `tickets`/**`tickets_drafts`** kollekciókra
* [x] `firestore.indexes.json` tartalmazza a fenti két kompozit indexet
* [x] A meglévő `firestore.rules` **nem** módosul ebben a lépésben; működő funkciók nem sérülnek
* [x] `flutter analyze` és a Cloud Functions build/test zöld

## Hivatkozások

* Canvas → `/codex/goals/fill_canvas_tickets_schema_and_rules.yaml`
* Átállási terv: `Api Football Migration Plan.pdf`
* Codex szabályok: `Codex Canvas Yaml Guide.pdf`

---

### 🎯 Funkció

Provider‑független `tickets` adatmodell és **read‑only kliens** Firestore szabályok bevezetése, külön overlay fájlban.

### 🧠 Fejlesztési részletek

**Séma (tickets/{ticketId})**

* `userId: string` – a ticket tulaja (kötelező)
* `createdAt: Timestamp` – létrehozás ideje (szerver idő)
* `status: string` – `pending|won|lost|void`
* `stake: number` – tippcoin tét
* `payout: number` – záráskor számolt kifizetés (oddsSnapshot alapján)
* `tips: Tip[]` – minimum 1 elem

  * `fixtureId: string` (API‑Football fixture ID)
  * `leagueId: string`
  * `teamHomeId: string`, `teamAwayId: string`
  * `market: string` (egységesített kód: `1X2|OU|BTTS|AH` …)
  * `selection: string` (pl. `HOME|DRAW|AWAY` vagy `OVER_2_5`)
  * `oddsSnapshot: number` (kötelező)
  * `kickoff: Timestamp`
* `processedAt?: Timestamp` – finalizer zárásakor

**Opció (tickets\_drafts/{draftId})** – ha klienssel engedünk „piszkozatot”

* Kliens írhat/olvashat **csak saját** draftot; a Functions konvertálja végleges ticket‑té.

**Biztonsági szabályok (overlay)**

* `tickets`: **read** csak a tulajnak; **write**: **tilos** (Admin SDK ír serveren)
* `tickets_drafts`: saját draft **read/write** engedett; méret/mező validáció a kliensen és a Functions‑ben

**Indexek**

* `(collectionGroup: tickets)` – `userId ASC, createdAt DESC`
* `(tickets)` – `status ASC, createdAt DESC`

### 🧪 Tesztállapot

* Ebben a lépésben nem integráljuk a rules‑t; csak overlay fájlt adunk és a projekt buildje zöld marad.
* Következő lépésben (külön vászon) lehet Firebase Emulators‑szal rules‑tesztet írni.

### 🌍 Lokalizáció

* Nincs új UI‑string; i18n nem érintett.

### 📎 Kapcsolódások

* Backend finalizer (Cloud Functions) – Admin SDK, rules‑t megkerüli → a write tiltás nem blokkolja a szervert
* Frontend szelvénylista – a `tickets` **csak saját** olvasása támogatott
* Következő vászon: rules integráció + emulator tesztek (opcionális), illetve `ticket_create_flow` (server‑oldali create)

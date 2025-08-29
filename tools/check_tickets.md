# tools/check_tickets.mjs – működési leírás és használat

## Cél
A felhasználói szelvények (tickets) gyors ellenőrzése Firestore‑ból:
- hány pending szelvény van (globálisan vagy adott felhasználóra),
- legutóbbi szelvények státusza, payout értékkel,
- watch módban csak a változások megjelenítése.

## Előfeltételek
- GCP ADC (Application Default Credentials) beállítva azon a gépen, ahol futtatod:
  - `gcloud auth application-default login`
- Hozzáférés a projekt Firestore olvasásához.

Megjegyzés: Ha a globális (`collectionGroup`) lekérdezések engedély/Index okból hibát adnak, használd a `--uid` szűkítést.

## Használat
```
node tools/check_tickets.mjs --project <PROJECT_ID> [--uid <UID>] [--watch] [--event <EVENT_ID>] [--since <ISO|1h|24h|2d>] [--limit <N>]
```

### Paraméterek
- `--project`: kötelező. GCP projekt azonosító (pl. `tippmix-dev`).
- `--uid`: opcionális. Ha megadod, csak az adott felhasználó `users/{uid}/tickets` útvonalán dolgozik (stabilabb, indexmentes olvasás).
- `--watch`: opcionális. Folyamatos figyelés; csak változás (status/payout) esetén ír ki sort.
- `--event`: opcionális. Csak azokat a szelvényeket listázza, amelyek bármely `tips[].eventId` mezője egyezik a megadott értékkel.
- `--since`: opcionális. Időszűrő `updatedAt` alapján. ISO időpont vagy relatív forma: `1h`, `24h`, `2d`.
- `--limit`: opcionális. Visszaadott rekordok száma (alapértelmezetten 50).

### Példák
- Egy felhasználó aktuális állapota (ajánlott):
  - `node tools/check_tickets.mjs --project tippmix-dev --uid <UID>`
- Eseményre szűrve, az elmúlt 24 órából:
  - `node tools/check_tickets.mjs --project tippmix-dev --event 1344493 --since 24h`
- Folyamatos figyelés egy userre:
  - `node tools/check_tickets.mjs --project tippmix-dev --uid <UID> --watch`
- Globális legutóbbiak (ha jogosult és van index):
  - `node tools/check_tickets.mjs --project tippmix-dev --limit 100`

## Kimenet
- "Pending tickets …: N" – összesítés (szűrők figyelembevételével).
- "Latest tickets:" – a legutóbbi N szelvény (rendezve az `updatedAt` alapján).
- "Summary: won=… lost=… pending=… totalPayout=…" – rövid összesítő sáv.
- Watch módban: csak változások (status/payout) jelennek meg, például:
  - `* users/<uid>/tickets/<id>: pending -> won, payout=23.6`

## Hibatűrés és tippek
- `FAILED_PRECONDITION` vagy jogosultság hiba globális módban:
  - Használd a `--uid <UID>` paramétert (user‑szintű kollekció, nem igényel kompozit indexet).
- ADC hiányzik / rossz kulcs:
  - Futtasd: `gcloud auth application-default login`
  - Ha a környezetben `GOOGLE_APPLICATION_CREDENTIALS` hibás fájlra mutat, futtasd így: `env -u GOOGLE_APPLICATION_CREDENTIALS node tools/check_tickets.mjs …`
- Rate limit/429 az API‑kban a végső szelvényzárást nem érinti; a watcher csak olvas.

## CI/automatizálás
- Smoke ellenőrzés (userre szűkítve):
```
node tools/check_tickets.mjs --project $PROJECT_ID --uid $UID --since 24h --limit 50
```
- Globális ellenőrzés csak akkor javasolt, ha a szolgáltatásfióknak van jogosultsága collectionGroup olvasásra és rendelkezésre állnak az indexek.

## Kapcsolódó folyamatok
- Szelvények kiértékelése: Cloud Functions `match_finalizer` (Gen2, Pub/Sub Eventarc). Sikeres futás után a watcher‑ben a `pending` szám nullára csökken a lezárt (won/lost/void) szelvények mellett.


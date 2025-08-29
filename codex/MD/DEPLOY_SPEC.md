Codex-prompt — Valódi eszközös E2E teszt: regisztráció → szelvény → kiértékelés

Környezet

Helyi Git repo a forrásigazság.

OS: Linux (Mint). Node 20, Flutter telepítve.

Egy Android telefon USB-n csatlakoztatva (ADB engedélyezve).

Firebase DEV projekt használata (ne a PROD).

API-Football kulcs és a “match_finalizer” Cloud Function DEV-ben működik (Pub/Sub result-check topic).

Feladat (összefoglaló)
Készíts és futtass valódi eszközön egy E2E tesztet, amely:

Regisztrál egy új tesztfelhasználót (e-mail/jelszó vagy Google Sign-In fallback – a repo tényleges auth-flow-ja szerint).

Felad egy szelvényt a mobil UI-n keresztül (a meglévő képernyők és flow szerint).

Elindítja/előidézi a kiértékelést (várakozás a háttérfolyamatra vagy diag trigger; lásd lent).

Ellenőrzi Firestore-ban és az app UI-ban a ticket státuszát (won/lost) és a wallet/ledger változást (idempotencia).

Összegyűjti a Cloud Logging kivonatot a releváns kulcsüzenetekkel (pl. diag-check, messageId / payout logok), és riportál.

Előfeltárás (ne írj még tesztet, amíg nincs meg a kép)

Derítsd ki a repo-ban:

Auth belépési pontot és a regisztráció lépéseit (e-mail/jelszó vagy Google).

A „szelvény feladás” folyamat UI lépéseit (képernyők, gombok, mezők).

A kiértékelés módját DEV-ben: scheduler/PubSub vagy diag-trigger.

A Firestore gyűjtemények tényleges neveit (pl. tickets, wallets, ledger) és a státuszmező(ke)t.

Írj egy rövid összefoglalót a megtalált útvonalakról/azonosítókról (fájlok, classok, route nevek), hogy lásd, mire kell kattintani a tesztben.

Tesztstratégia

Eszköz kiválasztása: listázd az eszközt, majd futtasd arra:

flutter devices
# Példa futtatás (a tényleges DEVICE_ID-t autodetekcióval válaszd ki):
flutter test -d <DEVICE_ID> integration_test/e2e_ticket_flow_test.dart --dart-define=FLAVOR=dev


Tesztadat:

Használj új, egyedi teszt e-mailt: test+<timestamp>@example.com (vagy a repo által támogatott domain).

Állíts be dev Firebase projekt paramétereket (--dart-define), és csak DEV környezetben dolgozz.

Kiértékelés előidézése (a repo lehetőségei szerint, egyet válassz):

Ha van diag publish script: küldj {"type":"diag-check"} üzenetet a result-check topicra (gcloud vagy meglévő script).

Ha a kiértékelés Scheduler/PubSub által időzített, biztosíts egy „force poll” vagy „finalize now” hívást (ha van admin/debug UI vagy HTTP diag function).

Ha van API-Football mock/teszt fixture a repo-ban, olyan meccset válassz, amelynek már ismert a végeredménye → így determinisztikus a PASS/FAIL.

Tesztmegvalósítás (csak a repo valóságára támaszkodj)

Ha van már integration_test/ mappa és alap setup, abban hozz létre új tesztet: integration_test/e2e_ticket_flow_test.dart.

Navigáció: belépés/ regisztráció → home → „Új szelvény” → kiválasztások → tét megadása → Beküldés.

Várakozás a kiértékelésre: polling/exponential backoff a Firestore-on (csak olvasás), vagy UI frissítés megvárása (a repo mintái szerint).

Ellenőrzés: ticket státusz (won/lost), wallet növekmény / ledger bejegyzés (idempotens: többszöri olvasásnál nincs duplikált bejegyzés).

Ha nincs integration_test setup, a repo konvenciói szerint hozd létre a minimális keretet (de csak a tényleges struktúrához igazodva: ne találj ki nem létező pathokat).

Parancsok (mintaként; igazítsd a repo változóneveihez)

# Eszköz ellenőrzése
adb devices
flutter devices

# Build & analyze (repo konvenció szerint)
flutter clean
flutter pub get
flutter analyze

# Dev definíciók (példa — a tényleges neveket a repo-ból olvasd ki)
export API_FOOTBALL_ENV=dev
export FIREBASE_PROJECT_ID=tippmix-dev

# E2E teszt futtatás valódi eszközön
flutter test -d <DEVICE_ID> integration_test/e2e_ticket_flow_test.dart --dart-define=FLAVOR=dev

# (Opció) diag-trigger a kiértékeléshez – csak ha a repo kínál erre eszközt:
gcloud pubsub topics publish projects/$FIREBASE_PROJECT_ID/topics/result-check --message='{"type":"diag-check","ts":"NOW"}'

# (Opció) Log kivonat Cloud Run/Functions-ból (region igazítása a repo alapján)
gcloud logging read 'resource.type="cloud_run_revision" AND textPayload:"match_finalizer"' --limit=50 --freshness=15m --format=json > /tmp/match_finalizer_logs.json


Riport (kötelező kimenet)

Rövid összefoglaló: sikeres-e a teljes flow (regisztráció → szelvény → kiértékelés → wallet).

Tesztlog: kulcs UI lépések és időzítések; mennyi idő alatt jött meg a kiértékelés.

Cloud Logging kivonat: pár releváns log-sor (messageId, payout, finalize).

Firestore ellenőrzés: a használt document ID-k és státuszok listája (ticket, wallet, ledger).

Idempotencia: bizonyíték, hogy a ledger nem duplikált (pl. összes számláló/kumulált mező).

Cleanup: a létrehozott teszt user és adatok törlése (Auth + Firestore), ha a repo erre kínál szkriptet vagy admin útvonalat.

Elfogadási feltételek (DoD)

A teszt valódi eszközön lefut, nem emulátoron.

Új user sikeresen regisztrálódik (vagy bejelentkezik, ha a flow így kívánja).

Sikeres szelvény-beküldés UI-ból.

A kiértékelés determinálhatóan lefut (diag-triggerrel vagy ismert eredményű fixture-rel), és a ticket státusz frissül.

A wallet/ledger helyes (összeg és idempotencia), nem jön létre duplikált könyvelés.

A riport tartalmazza a fenti pontokat és a logkivonatot.

Korlátok / biztonság

Csak DEV projektet érints. PROD-ba ne írj/tesztelj.

Ne módosítsd a Functions kódot, ha nem szükséges; ez teszt-végrehajtás.

Ha a repo-ban bármi eltér (útvonal, képernyőnév, topic-név), ahhoz igazodj, és előbb jelezd rövid felderítési összefoglalóban.
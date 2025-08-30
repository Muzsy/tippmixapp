# Képernyő-spec – **Szelvényeim (MyTickets)**

> A dokumentum a `docs/templates/screen_spec_template.md` sablon alapján készült, a projektben található jelentések és audit információi szerint.

---

## 🧭 Meta

* **Képernyő neve / azonosító**: `MyTicketsScreen`
* **Fő route**: `AppRoute.myTickets`
* **Felelős(ök)**: *TBD*
* **Állapot**: `IN PROGRESS`
* **Prioritás**: `P1` (Sprint 1 fókusz)
* **Kockázat**: `MEDIUM`
* **Utolsó frissítés**: 2025‑08‑30 (audit + szinkron a kóddal)

---

## 🎯 Funkció (Scope & cél)

* **Felhasználói cél**: A bejelentkezett felhasználó korábban létrehozott szelvényeinek áttekintése, állapotuk megtekintése, részletek megnyitása; üres állapotban irány a szelvénykészítéshez.
* **Üzleti cél**: Retenció növelése (visszatérés a korábbi szelvényekhez), konverzió terelése az „Új szelvény” flow-ba; alap a későbbi közösségi/gamifikációs funkciókhoz.
* **Kötelező funkciók** (aktuális állapot → terv):

  * [x] Firestore stream a bejelentkezett user `tickets` kollekciójára (descending `createdAt`).
    - Jelenleg: `ticketsProvider` Firestore stream + `fromJson(d.data())`.
  * [x] Listaelemek: TicketCard + státusz chip.
    - Jelenleg: `TicketCard` + `TicketStatusChip` működik.
  * [x] Tétel‑tap → részletek megnyitása (dialog vagy külön képernyő).
    - Jelenleg: `TicketDetailsDialog` minimális tartalommal.
  * [x] Üres állapot dedikált CTA‑val „Szelvény készítése”.
    - Megvalósítva: `EmptyTicketPlaceholder` CTA gombbal (GoRouter → `AppRoute.bets`).
  * [x] Hibaállapot egységes komponenssel és Retry művelettel.
    - Megvalósítva: `ErrorWithRetry` + `Retry` → `ref.refresh(ticketsProvider.future)`; loading: `MyTicketsSkeleton`.
  * [x] Telemetria: `tickets_list_viewed`, `ticket_selected`, `ticket_details_opened`.
    - Megvalósítva: `AnalyticsService` (`logTicketsListViewed`, `logTicketSelected`, `logTicketDetailsOpened`, `logErrorShown`).
* **Nem‑célok** (jelen verzióban): más felhasználók szelvényeinek böngészése; szelvények szerkesztése/utólagos módosítása; valós pénzes tranzakciók; közösségi megosztás (későbbi iteráció).

---

## 🖼️ UI & UX (Kinézet, állapotok)

* **Fő layouthierarchia**: AppBar → Body: `ListView`/`SliverList` TicketCard‑okkal → opcionális `FloatingActionButton`/CTA (navigáció az „Új szelvény” flow‑ba).
* **Komponensek** (tervezett/használt):

  * `lib/widgets/ticket_card.dart` – összefoglaló kártya: bal oldalt tét, össz‑odds, tippek száma és létrehozás dátuma; jobb oldalt státusz chip és várható nyeremény.
  * `lib/widgets/ticket_status_chip.dart` – státusz vizuális jelzése.
  * `lib/widgets/ticket_details_dialog.dart` – részletező: rövidített szelvényazonosító (első 4 + utolsó 4), létrehozás dátuma; függő státusznál legkorábbi tipp kezdési ideje; tippek listája strukturáltan (esemény cím, outcome + market, trailing: xODDS), státusz chip a fejlécben.
  * `lib/widgets/empty_ticket_placeholder.dart` – üres állapot, elsődleges CTA „Szelvény készítése” (GoRouter → `AppRoute.bets`).
  * Navigáció: `lib/widgets/app_drawer.dart`, `lib/widgets/my_bottom_navigation_bar.dart`.
* **Állapotok**:

  * [x] **Loading** — skeleton lista: `MyTicketsSkeleton`.
  * [x] **Empty** — szöveg + elsődleges gomb „Szelvény készítése”.
  * [x] **Error** — egységes hiba‑komponens: `ErrorWithRetry` („Refresh” gomb).
  * [x] **Data** — lista szelvénykártyákkal, részletező megnyitással.
* **Interakciók**: tap a kártyán → részletező (dialog/screen); pull‑to‑refresh; overflow (⋮) menü előkészítés a jövőbeli akciókhoz (megosztás/másolat/törlés – üzleti döntéstől függően).
* **Accessibility (A11y)**:

  1. Minden kártya és chip rendelkezzen beszédes semanticsLabel‑lel (státusszal).
  2. Tap target ≥ 48×48 dp; fókusz‑állapot jelölése.
  3. Kontraszt a státusz chipeknél min. WCAG AA; TalkBack/VoiceOver felolvassa a szelvény azonosítót és fő metrikákat.

---

## 🔗 Navigáció & kapcsolódások

* **Belépési pontok**: Bottom‑nav „Szelvényeim”; Drawer menü.
* **Kilépési pontok**: Részletező (dialog → `TicketDetailsScreen`, ha külön route lesz); „Szelvény készítése” flow.
* **Deep link / paraméterek**: `ticketId` (részletező képernyőhöz tervezett).
* **Kapcsolódó feature‑ek**: Gamifikáció (nyertes szelvények hatása); Értesítések (státusz‑változás); Feed (nyertes szelvények mint aktivitás‑elem).

---

## 🗃️ Adatmodell & források

* **Modellek**: `Ticket` (kulcsmezők: `id` \[= Firestore `doc.id`], `status` \[enum: `TicketStatus`], `stake`, `totalOdd`, `potentialWin`, `createdAt`, `updatedAt`, `tips:[...]` – tipp bontások: esemény/market/választás/odds/státusz).
* **Adatforrás**: Firestore path: `users/{uid}/tickets`; alap rendezés: `createdAt` desc; lapozás: első oldal `limit=20` stream, majd `startAfter(createdAt)` lekérések görgetéskor.
* **Szerializáció**: jelenleg `fromJson(d.data())` többféle kulcsnév‑fallbackkel; a `Ticket.id` forrása jellemzően a dokumentumban tárolt `id` mező (app által írt), a `doc.id` nincs kötelezően hozzárendelve.
  - **Ajánlott**: `Ticket.fromFirestore(DocumentSnapshot)` + `doc.id` → `Ticket.id`; dátum: `Timestamp` ↔ `DateTime` konverzió.
* **Idempotencia / konzisztencia**: egységesített mezőnév‑séma; `id` mindig `doc.id`; read‑only mezők felülírásának tiltása rules‑ban.
* **Migrációs jegyzet**: régi mezőnevek (`created_at`/`ticketId`) fallbackként még támogatottak, de a standard séma bevezetése után fokozatosan kivezetendők.

---

## 🔐 Biztonság (Firestore Rules, auth)

* **Olvasási/írási feltételek**: hitelesített user **csak** a saját `users/{uid}/tickets` dokumentumaihoz férhet hozzá; idegen user adatainak olvasása tiltva.
* **Edge case**: unauthenticated → redirect/login; hiányzó index → hiba‑üzenet + telemetry; törölt user → üres lista/hiba‑kezelés.
* **Audit/Log**: hibaágak Sentry breadcrumb; képernyő megnyitás/hiba eventek.

---

## 📊 Telemetria & mérőszámok

* **Eventek**: `tickets_list_viewed`, `ticket_selected`, `ticket_details_opened`, `ticket_action_copy/share/delete` (ha aktiválva), `error_shown`.
  - Implementált: `tickets_list_viewed` (lista megnyitáskor egyszer), `ticket_selected` (kártya tap), `ticket_details_opened` (részletező megnyitás), `error_shown` (hibaállapot megjelenítésekor), `tickets_empty_cta_clicked` (üres állapot CTA gomb megnyomása).
  - Paraméterek: ticketId (normalizált, max 64), status (enum: pending/won/lost/voided), count/tips (clamp), stake/totalOdd/potentialWin (clamp+round), screen (normalizált), message (rövidített, max 120 char).
* **Funnel**: lista megnyitás → tétel megnyitás → (akció/konverzió) vagy „Szelvény készítése” CTA kattintás.

---

## 🚀 Teljesítmény & skálázás

* **Lista stratégia**: alapértelmezett limit + lapozás/infinite scroll nagy elemszámnál; stream throttling, minimal summary a listában (részletek a részletezőben). Skeleton betöltés alatt.
* **Cache**: rövid életű mem‑cache/riverpod cache; szükség esetén query‑cache stratégia.

---

## 🧪 Tesztelés (követelmények)

* **Unit**: `Ticket` szerializáció (`fromFirestore`) – TERV; `TicketService.watchUserTickets()` – N/A (jelenleg képernyő szintű stream).
* **Widget**: létező: bejelentkezett/ki‑jelentkezett állapot, lista megjelenés, pull‑to‑refresh; dialógus megnyitása tap‑re; üres állapot CTA jelenléte; hibaállapot üzenet + Retry gomb; loading skeleton jelenléte.
  - TERV: CTA navigáció GoRouter-rel integrációs tesztben.
* **Integration**: navigáció drawer/bottom‑nav; deep link `ticketId` (ha bevezetjük a külön screen‑t).
  - Elkészült: CTA navigáció `MyTickets → Bets` (fájl: `integration_test/my_tickets_empty_cta_navigation_test.dart`).
* **Rules tesztek**: pozitív/negatív utak (saját vs. idegen user; tiltott mező felülírása).
* **Elfogadási kritériumok**:

  * [ ] AC1 — Minden listaelem rendelkezik nem üres `id`‑val, amely megegyezik a Firestore `doc.id`‑vel. (Jelenleg: `id` mező a dokumentumból, `doc.id` nem kötelező.)
  * [x] AC2 — A részletező a fő kulcsmezőket és a tippek részleteit megjeleníti (stake, totalOdd, potentialWin, status, createdAt, tips...).
  * [x] AC3 — Üres állapotban elsődleges gombbal elérhető a „Szelvény készítése” képernyő.
  * [ ] AC4 — Hiba esetén egységes hiba‑UI és Retry; betöltéskor skeleton/shimmer látszik. (Részben kész: Retry gomb megvan; skeleton és egységes komponens hiányzik.)
  * [ ] AC5 — Rules tesztek: idegen user adatai nem olvashatók. (Nincs teszt lefedettség.)

---

## 🌍 Lokalizáció

* **Kulcsok**: `myTickets`, `my_tickets_title`, `empty_ticket_message`, `ticket_status_*`, `ticket_details_title`, `ticket_id`, `go_to_create_ticket`, (bővítendő: `stake`, `totalOdd`, `potentialWin`, `createdAt`, `updatedAt`, tippek mezők).
* **Nyelvi edge case**: hosszú szelvény‑azonosító; többes szám kezelése (tippek száma); dátum‑idő formátum lokalizált.

---

## 📄 Állapotlista (Checklist)

* [x] UI váz (lista + komponensek alapjai)
* [x] Adat stream / betöltés (alap működik)
* [x] Üres állapot + CTA
* [x] Hibaállapot + Retry (egységes komponensre váltás, skeleton kész)
* [x] Részletező (bővítve; külön képernyő opcionális)
* [x] Navigációs pontok (drawer/bottom‑nav)
* [x] Telemetria eventek (rögzítés és ellenőrzés)
* [x] Widget tesztek az állapotokra és interakciókra
* [ ] Golden tesztek 3 nyelven (hu/en/de)
* [ ] Rules ellenőrizve (neg/poz út)
* [ ] Kódreview kész

**Elemzés**:

* ✅ 2025‑08‑29: Alap lista/üres állapot, dialog, route‑ok, i18n kulcsok, alap tesztek.
* ⏳ 2025‑08‑30: Részletező bővítése (KÉSZ), üres állapot CTA (KÉSZ), hiba/loader egységesítése (KÉSZ), szerializáció pontosítása (`doc.id`) (KÉSZ), telemetria (KÉSZ).
* ❌ 2025‑08‑30: Teljes rules tesztcsomag, telemetria finomhangolás.

---

## 🛠️ Megvalósítási terv (DoD → feladatlista)

- Lapozás/infinite scroll: elkészült – finomhangolás: tie‑breaker `id` bevezetése a lekérdezésben, ha szükséges.
- Golden tesztek: MyTickets képernyő aranyképei 3 nyelven (hu/en/de), a `golden_toolkit` szerint; CI integráció ellenőrzése.
- A11y finomítás: semanticsLabel a kártyára/chipekre; kontraszt audit (AA) – sötét témában is.
- Rules ellenőrzés: MyTickets olvasási utak pozitív/negatív eseteinek bővítése (Firestore Emulator; JS rules‑teszt mintára).
- (Opció) Részletező külön képernyő: ha deep‑link szükséges, előbb canvas + Codex YAML, majd route és tesztek.

---

## 🧭 Kockázatok & döntések

* **Ismert kockázatok**: inkonzisztens mezőnevek a régi dokumentumokban; `id` hiány a modellben; nagy elemszámnál teljesítmény; részletező hiányos mező‑készlete.
* **Megszületett döntések (ADR‑szerűen)**:

  * D1: `Ticket.fromFirestore` bevezetése; `doc.id` → `Ticket.id` kötelező. Alternatíva: `fromJson(json, id: doc.id)`, de első opció preferált.
  * D2: Üres állapotban elsődleges CTA „Szelvény készítése”.
  * D3: Hiba/Loading állapotok egységes komponensekkel (skeleton + retry), Sentry breadcrumb a hibaágban.

---

## ❓ Nyitott kérdések

* Q1: Lesz‑e külön `TicketDetailsScreen`, vagy marad a dialog? (Deep link igény → screen felé billenti a döntést.)
* Q2: Milyen akciók engedélyezettek a kártyán? (megosztás/másolat/törlés) – üzleti jóváhagyás szükséges.
* Q3: Lapozás vs. infinite scroll – melyik UX‑et preferáljuk nagy elemszámnál?

---

## 📝 Változásnapló (Changelog)

* 2025‑08‑30: Első verzió + audit szerinti frissítés (aktuális kódállapot szinkronizálva; megvalósítási terv hozzáadva).

---

## 🔧 Codex integráció

* **Kapcsolt canvas**: *ez a dokumentum*
* **Kapcsolt Codex YAML**: *(későbbi iterációban)*
* **Futtatási jegyzet**: `flutter analyze && flutter test`

---

### Megjegyzés

A specifikáció kizárólag a feltöltött dokumentumokban szereplő információkra támaszkodik; kód‑/fájlépítés közvetlen feltételezése nélkül.

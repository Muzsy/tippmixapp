# UI – Tippkártya (Bet Card) layout refaktor

## Kontextus

A jelenlegi tippkártya a felső sorban az **ország + liga** szöveget jobbra igazítja; a csapatnevek hosszúnál levágódnak; a **Kezdés** formátuma eltér az elvárttól; a **H2H** gombok stílusa nem egyezik a kártya alján lévő három akciógombéval; a **Frissítve** felirat időbélyeg nélkül jelenik meg; valamint előfordul, hogy néhány kártyán a **H2H** piac helyett „Nincs elérhető piac” látszik.

## Cél

Egységes, esztétikus és informatív bet card:

* Ország balra, liga jobbra **ligalogóval**.
* Csapatnevek teljes kiírása, szükség esetén **két sorban** (logók maradnak).
* Kezdés formátum: `Kezdés: YYYY/MM/DD HH:MM` (jobbra), a visszaszámláló balra marad.
* A **H2H** három gomb (1 – X – 2) **azonos stílusú**, mint a legalsó három akciógomb.
* „Frissítve:” után megjelenik a **tippek lekérésének időpontja**.
* Stabil megjelenítés: minden kártyán feljöjjenek a piacok (kulcsok és listakey-ek rendben).

> **Megjegyzés i18n-ről:** a „Kezdés:” és „Frissítve:” feliratok lokalizált kulcsokból jönjenek. Ha hiányoznak, külön i18n‑canvasban adjuk hozzá őket (HU/EN/DE). A három alsó gomb feliratai már lokalizáltak; csak a stílus egységesítése történik itt.

## Feladatok

* [ ] **Top sor**: `Row(mainAxisAlignment: spaceBetween)`

  * Bal: ország szöveg (`event.country`).
  * Jobb: `Row( children: [ leagueLogo(18x18, radius=4), 8px gap, liga neve ] )`.
  * A ligalogó `CachedNetworkImage`/meglévő loaderrel; fallback: kerek sarokkal ellátott semleges helykitöltő.
* [ ] **Csapatnevek**: a home/away szövegdoboz **`Flexible` + `maxLines: 2` + `softWrap: true`**. Ne legyen egyvonalas elvágás.
* [ ] **Kezdés**: formázó függvény `formatKickoff(DateTime dt)` → `yyyy/MM/dd HH:mm` (helyi időre konvertálva).

  * Elrendezés: balra a visszaszámláló (változatlan), jobbra a „Kezdés: …”.
* [ ] **Gombstílus egységesítése**:

  * Hozz létre a kártyán belül egy privát építőt: `_pillButton({required Widget child, required VoidCallback onTap})` → `OutlinedButton`/meglévő stílus paramétereivel (StadiumBorder, 14–16 px padding, 1 px kontúr, lekerekített nagy sugarú forma; tipográfia a Theme‑ből).
  * A **H2H (1/X/2)** gombok is ezt használják; így **mind a hat** gomb azonos kinézetű.
* [ ] **Frissítve** időbélyeg: a kártya kapjon új kötelező paramétert `DateTime refreshedAt` (vagy a provider állapota továbbadva). A felirat: `Frissítve: YYYY/MM/DD HH:MM`.
* [ ] **Stabil lista‑render**: a kártya gyökerére `Key('bet-card-${event.fixtureId}')`. Ha van kártyán belüli `FutureBuilder/StreamBuilder`, annak a *jövője* a fixtureId‑re legyen kötve, ne az indexre.
* [ ] **Lint/analyze**: importok rendezése, `const` ahol lehet, a vizuális változtatás ne törje a meglévő viselkedést.

## Érintett fájlok (repo‑szinkron)

* `lib/widgets/event_bet_card.dart` (elrendezés, gombstílus, időformázás, kulcsok)
* `lib/screens/events_screen.dart` (ha szükséges: `refreshedAt` továbbítása a providerből)
* (Opcionális) `lib/services/api_football_service.dart` vagy odss réteg **nem** módosul itt – a piacbetöltés javítása külön canvas.

## Acceptance Criteria / Done Definition

* [ ] Ország balra; liga jobbra logóval, a szövegek nem csúsznak össze kis kijelzőn sem.
* [ ] Csapatnevek 2 sorig törnek, tipográfia nem torzul; a logók változatlanok.
* [ ] „Kezdés: YYYY/MM/DD HH\:MM” jobbra jelenik meg; bal oldali visszaszámláló érintetlen.
* [ ] A három **H2H** gomb **pontosan** úgy néz ki, mint az alsó három akciógomb (azonos kontúr, lekerekítés, betűméret, spacing).
* [ ] „Frissítve: YYYY/MM/DD HH\:MM” látszik; idő a provider utolsó sikeres lekéréséből jön.
* [ ] `flutter analyze` hibamentes; meglévő tesztek zöldek (`flutter test`).

## Tesztelés (javasolt)

* Widget golden: rövid és hosszú csapatnevekkel (két soros törés ellenőrzése).
* Espresso/Widget: mind a 6 gomb látszik és elérhető (`finder.byKey`/`byType(OutlinedButton)`).
* Időformátum: `formatKickoff` egységteszt 3 időpontra (éjfél előtt/után, zónaeltérés).

## Hivatkozások

* Kapcsolódó canvas: **H2H piac betöltés – lefedettség javítása** (külön)
* Kapcsolódó canvas: **Bet card i18n kiegészítések (HU/EN/DE)** (külön)
* Codex: `/codex/goals/fill_canvas_event_bet_card_layout_refactor.yaml` (e vászon YAML‑ja)

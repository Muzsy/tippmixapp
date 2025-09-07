# Fórum modul – Készültségi összefoglaló és végrehajtási feladatlista (MVP zárás)

> **Cél**: A fórum modul MVP-jének befejezése. A Codex feladata a feladatok végrehajtása és a checklist **pipálása**. A modul akkor tekinthető késznek, ha **minden** pont pipa.

---

## 🎯 Funkció

A fórum modul biztosítson közösségi beszélgetést: szálak (thread), hozzászólások (post), szavazás (upvote), jelentés (report), moderációs alapok, listanézet szűrés/sorrend, szál nézet lapozással, új szál + első poszt létrehozás, lezárt szálak kezelése, kliens-oldali védelem a Firestore szabályokkal összhangban.

---

## 🧠 Fejlesztési részletek

Az alábbi feladatok prioritás szerint rendezve. Minden feladatnál a **kész** állapot **ellenőrzési kritériumokkal** szerepel. A Codex a végrehajtás után **pipálja** ki a checklistet.

### P0 – Blokkoló (MVP-hez kötelező)

* [x] **Valódi Auth UID bekötése minden create/update művelethez**
  **Leírás**: Minden thread/post/vote/report író művelet a bejelentkezett felhasználó `uid`-ját használja.
  **Kritérium**: Nincs több hardcode/fallback userId; egységesen auth-ból jön. Create során a JSON kulcsok megfelelnek a Firestore szabályoknak (csak engedett mezők).
  **Ellenőrzés**: Emulatoron CRUD sikeres; nincs `permission-denied` a szabályok miatt.

* [ ] **UI akciók drótozása a vezérlőkhöz a szál nézetben**
  **Leírás**: Válasz/Új komment, Szerkesztés, Törlés (saját poszt), Upvote, Jelentés gombok a megfelelő controller metódusokat hívják, optimista frissítéssel és hiba-kezeléssel.
  **Kritérium**: Minden ikon működik; saját poszton elérhető az Edit/Delete; upvote duplakatt nem dupláz.
  **Ellenőrzés**: Widget teszt + kézi próba emulatoron.

* [ ] **Új szál létrehozás flow teljes**
  **Leírás**: Validáció (cím kötelező, első poszt kötelező, típus választás), siker esetén navigáció az új szálra.
  **Kritérium**: Hibás inputra disable/hibaüzenet; siker után thread nézet megnyílik és látszik az első poszt.
  **Ellenőrzés**: Integration test happy-path.

* [ ] **Forum lista FAB → Új szál képernyő**
  **Leírás**: A FAB megnyitja az új szál képernyőt.
  **Kritérium**: Kattintásra navigáció működik.
  **Ellenőrzés**: Widget/integration test.

* [ ] **Firestore rules és kliens JSON teljes összhangja**
  **Leírás**: A kliens oldali `toJson()` és create/update mezők pontosan fedik a szabályok által engedett kulcsokat és tulajdonosi ellenőrzéseket.
  **Kritérium**: Rules unit teszt zöld; manuális próba írás/olvasás során nincs reject.
  **Ellenőrzés**: Rules teszt futtatása emulatoron.

* [ ] **Lezárt szálak (locked) UI-kezelése**
  **Leírás**: Locked thread esetén a composer letilt; jelzés a UI-ban.
  **Kritérium**: Locked=true esetén nincs post létrehozás gomb; információs jelzés.
  **Ellenőrzés**: Kézi próba emulatoron (thread.locked toggléval).

### P1 – Fontos

* [ ] **Infinite scroll / lapozás bekötése**
  **Leírás**: Lista és szál nézet végén automatikus `loadMore`; footer loading indikátor.
  **Kritérium**: Hosszú listáknál sima lapozás; nincs duplikáció.
  **Ellenőrzés**: Widget/integration; manuálisan 100+ elem.

* [ ] **Szűrés/sorrend teljes körű implementálása**
  **Leírás**: Minden filter (pl. All/Matches/General/Pinned) és sort (Latest/Newest/Activity) kombináció támogatott a lekérdezésben.
  **Kritérium**: Dropdownt váltva a lista megfelel az elvárásnak.
  **Ellenőrzés**: Unit teszt a query builderre.

* [ ] **Szükséges Firestore indexek megléte**
  **Leírás**: A lekérdezésekhez szükséges összetett indexek hozzáadva.
  **Kritérium**: Futás közben nincs index hiány üzenet; `firestore.indexes.json` naprakész.
  **Ellenőrzés**: Emulator log + deploy dry-run.

* [ ] **Thread aggregát mezők karbantartása (lastActivityAt, postCount, pinned)**
  **Leírás**: Poszt létrehozás/törlés frissíti a thread aggregátjait tranzakcióban (vagy CF-ben).
  **Kritérium**: Lista rendezése „Latest activity” szerint helyes; postCount pontos.
  **Ellenőrzés**: Unit teszt + kézi.

### P2 – Minőség / Moderáció

* [ ] **Report áramlás és visszajelzés**
  **Leírás**: Report ikonhoz form (oka, megjegyzés), siker után snackbar/toast.
  **Kritérium**: Report dokumentum létrejön; felhasználó visszajelzést kap.
  **Ellenőrzés**: Emulator + unit.

* [ ] **Upvote állapot és számláló**
  **Leírás**: Saját vote állapot jelzése; aggregált számláló render; optimista update.
  **Kritérium**: UI szinkronban az adattal; több kattintás nem növeli végtelenre.
  **Ellenőrzés**: Widget teszt.

* [ ] **Szerkesztés/Törlés saját posztokra**
  **Leírás**: Edit dialog (validáció), delete megerősítés.
  **Kritérium**: Csak owner fér hozzá; rules szerint fut.
  **Ellenőrzés**: Rules + widget teszt.

### P3 – Tesztelés / DevEx

* [ ] **Integration test (happy-path)**
  **Leírás**: Login → új thread → első post → listában megjelenik → megnyit → új komment → upvote → report.
  **Kritérium**: Teszt zöld; headless fut CI-ben.
  **Ellenőrzés**: `flutter test` + CI log.

* [ ] **Rules tesztek path-igazítása és bővítése**
  **Leírás**: A rules teszt a projektben használt valós `firestore.rules`-t tölti; létrehozás/módosítás/tiltás esetei lefedve.
  **Kritérium**: Minden pozitív/negatív eset fedve; zöld futás.
  **Ellenőrzés**: `@firebase/rules-unit-testing` (Node) vagy Dart driver.

* [ ] **Lokalizáció bővítés (HU/EN/DE)**
  **Leírás**: Minden új UI-üzenet, hiba, form label, snackbar kulcsosítva.
  **Kritérium**: `arb` fájlok kiegészítve, `flutter gen-l10n` zöld.
  **Ellenőrzés**: Build + manuális nyelvváltás.

---

## 🧪 Tesztállapot

* Emulator + unit/widget tesztek futnak.
* Hiányzik: e2e happy-path, teljes rules teszt, query builder unit tesztek, lapozás widget tesztek.
* Kritikus: a szabályok és a kliens JSON mezők **szinkronja** regressziót okozhat – dedikált tesztek szükségesek.

---

## 🌍 Lokalizáció

* Cél nyelvek: **HU/EN/DE**.
* Teendők: új kulcsok hozzáadása az összes akcióhoz, hibaüzenethez, form validációhoz; fordítások kitöltése; l10n build ellenőrzése.

---

## 📎 Kapcsolódások

* **Firebase/Firestore**: kollekciók (threads, posts, votes, reports), összetett indexek, security rules.
* **Auth**: kötelező a write műveletekhez, owner-ellenőrzés.
* **CI**: futtassa a rules + widget + integration teszteket emulatorral.
* **Moderáció**: későbbi admin panel felé kompatibilis report struktúra.

---

## Készültségi mérőszámok (Definition of Done)

1. Minden **P0–P3** checklist pipa.
2. `flutter test` zöld lokálisan és CI-ben.
3. Emulatoron kézi próba: thread létrehozás → hozzászólás → upvote → report → locked thread tilalom.
4. L10n build hiba nélkül.
5. Index hiány üzenet nincs futás közben.

---

### Codex műveleti jegyzetek

* Keresés a kódban: keress „forum”, „thread”, „post”, „vote”, „report”, „locked”, „FAB”, „composer”, „filter”, „sort”, „loadMore” kulcsszavakra.
* Ütközésmentesítés: minden nagyobb módosítás saját branch-en.
* Tesztfuttatás: Firestore Emulator kötelező; rules teszt külön futtatva.
* Pipálás: sikeres futtatás és manuális próba után jelöld pipa alá a kész teendőt.

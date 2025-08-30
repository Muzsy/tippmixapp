# Képernyő-alapú dokumentációs rendszer – TippmixApp

---

## 🎯 Cél

Ez a rendszer arra szolgál, hogy **képernyőnként** (screen-based) strukturáltan és egységesen dokumentáljuk az alkalmazás minden részét. A cél az, hogy:

* **Átláthatóvá** tegyük a képernyők funkcióit, kinézetét, adatmodelljeit és tesztelési elvárásait.
* **Következetes** formátumban vezessük a specifikációkat (egységes sablon alapján).
* **Verziókövethető** legyen a dokumentáció, a kód mellett (docs-as-code).
* **Könnyű belépést** biztosítson új fejlesztőknek, tesztelőknek és dokumentációt olvasóknak.
* **Automatizációt** támogasson (Codex vásznak + YAML célok szoros integrációja).

---

## 🧩 Tulajdonságok

* **Screen-first** megközelítés: minden képernyő önálló mappát kap a dokumentációban.
* **Sablon-alapú**: minden képernyő-spec a `screen_spec_template.md` alapján készül.
* **Docs-as-code**: minden dokumentum a Git repóban él, verziókövetéssel.
* **Best practice követés**:

  * Diátaxis elvek: külön a tutorial, reference, how-to, explanation tartalmak.
  * ADR-ek (Architecture Decision Record) külön, de képernyőkből hivatkozva.
  * Elfogadási kritériumok és teszt-tervek külön fájlokban.
* **Integráció a fejlesztési folyamattal**:

  * Pull Request csak akkor mehet be, ha a kapcsolódó képernyő-dokumentáció is frissül.
  * Canvases + Codex YAML összekapcsolva a dokumentációs rendszerrel.
* **Nyelvi támogatás**: i18n kulcsok képernyőnként dokumentálva.

---

## 🏗️ Felépítés

```
docs/
  screens/
    <screen_name>/
      screen_spec.md        # fő specifikáció (a sablon alapján)
      ui/
        wireframes/         # vizuális mockupok, állapotképek
        components.md       # UI komponens-fa, accessibility
        copy.md             # képernyő szövegek, microcopy
      data/
        model.md            # adatmodell, Firestore path, migráció
        telemetry.md        # eventek, mérőszámok, funnel
      qa/
        acceptance.md       # elfogadási kritériumok
        test-plan.md        # tesztelési terv
      risks_decisions.md   # kockázatok, döntések, nyitott kérdések
      changelog.md          # képernyő szintű változások

i18n/
  screens/
    <screen_name>.keys.md   # képernyő kulcsok, példaszövegekkel

adr/
  0001-ticket-id-source.md  # ADR-ek
  0002-my-tickets-pagination.md
  index.md

canvases/
  <Screen>_Screen_Spec.md   # vizuális vászon

codex/
  goals/
    canvases/
      fill_canvas_<screen>.yaml
    screens/
      <screen>_impl.yaml

docs/
  templates/
    screen_spec_template.md # kanonikus sablon
    acceptance_template.md
    test_plan_template.md
```

---

## 📋 Fő elemek magyarázata

* **`screen_spec.md`**: a képernyő teljes leírása (célok, funkciók, kinézet, adatmodell, tesztek, lokalizáció).
* **UI mappa**: vizuális elemek és szövegek dokumentálása.
* **Data mappa**: adatmodell és telemetria dokumentálása.
* **QA mappa**: elfogadási kritériumok és teszttervek külön.
* **Risks\_decisions**: képernyőszintű döntések és kockázatok, ADR-ekre hivatkozással.
* **Changelog**: képernyő változásainak rövid, verziózott listája.
* **ADR**: hosszú távú architekturális döntések (külön mappa).
* **i18n**: kulcsok és nyelvi sajátosságok dokumentálása képernyőnként.
* **Canvases + Codex YAML**: a Codex agent által használt segédfájlok.

---

## 🔄 Működési szabályok

* **PR szabály**: képernyő változás csak akkor mergelhető, ha a kapcsolódó `screen_spec.md` és az `acceptance.md` frissítve van.
* **Linkelés**: minden képernyő-spec tetején kapcsolódások blokk (kód-fájlok, ADR, vászon, YAML).
* **Karbantartás**: release után frissítés a `changelog.md`-ban.

---

## ✅ Előnyök

* Új fejlesztő gyorsan eligazodik (minden képernyő teljesen le van írva).
* Könnyű review: minden változtatás látszik a kód és a doksi diffben.
* Tesztelés támogatása: acceptance + test-plan mindig kéznél.
* Üzleti és technikai csapat is ugyanabból a dokumentumbázisból dolgozik.

---

## 🔮 Nyitott pontok

* Automatizált skeleton-generátor készítése új képernyőkhöz.
* ADR-index és képernyő-spec integráció automatizálása.
* Telemetria és i18n fájlok összekötése a build pipeline-nal.

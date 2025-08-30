# Útmutató – Új képernyő dokumentáció létrehozása

Ez az útmutató bemutatja, hogyan kell a képernyő-alapú dokumentációs rendszerben **új képernyőt** létrehozni és kitölteni.

---

## 1️⃣ Előkészületek

* Győződj meg róla, hogy rendelkezel a sablonokkal:

  * `docs/templates/screen_spec_template.md`
  * `docs/templates/acceptance_template.md`
  * `docs/templates/test_plan_template.md`
* Ismerd meg a képernyő pontos nevét és route-ját (pl. `MyTicketsScreen`, route: `AppRoute.myTickets`).

---

## 2️⃣ Mappa létrehozása

A `docs/screens/` alatt hozz létre egy új mappát a képernyő azonosítójával:

```
docs/screens/<screen_name>/
```

👉 Példa: `docs/screens/my_tickets/`

---

## 3️⃣ Fájlstruktúra létrehozása

Másold be a sablonok alapján a következő fájlokat:

```
screen_spec.md        # fő specifikáció, sablon alapján kitöltve
ui/
  components.md       # komponens-fa
  copy.md             # képernyő szövegek
  wireframes/         # ide kerülnek a képek

data/
  model.md            # adatmodell leírása
  telemetry.md        # eventek, mérőszámok

qa/
  acceptance.md       # elfogadási kritériumok
  test-plan.md        # tesztterv

risks_decisions.md   # kockázatok, döntések, nyitott kérdések
changelog.md          # változásnapló
```

---

## 4️⃣ Screen spec kitöltése

Nyisd meg a `screen_spec.md`-t, és töltsd ki a `docs/templates/screen_spec_template.md` alapján:

* 🎯 Funkció
* 🖼️ UI & UX
* 🔗 Navigáció
* 🗃️ Adatmodell
* 🔐 Biztonság
* 🧪 Tesztelés
* 🌍 Lokalizáció
* 📎 Kapcsolódások
* ✅ Checklist
* ❓ Nyitott kérdések
* 📝 Változásnapló

👉 A `screen_spec.md` tetején mindig legyen **Meta blokk** (név, route, állapot, prioritás).

---

## 5️⃣ Acceptance és tesztterv

* `acceptance.md`: írd bele az elfogadási kritériumokat (AC1, AC2…).
* `test-plan.md`: sorold fel a teszteket (unit, widget, integration, rules).

---

## 6️⃣ UI és data kiegészítők

* `ui/components.md`: rajzold le a widget-hierarchiát.
* `ui/copy.md`: listázd ki az i18n kulcsokat és példaszövegeket.
* `data/model.md`: írd le az adatmezőket, Firestore útvonalakat.
* `data/telemetry.md`: részletezd az eventeket, funnel-t.

---

## 7️⃣ ADR és kapcsolatok

Ha a képernyőhöz új architekturális döntés kell (pl. `Ticket.id` → `doc.id`):

* hozz létre új ADR fájlt a `docs/adr/` alatt (pl. `0003-new-decision.md`).
* hivatkozd be a `screen_spec.md` „Risks & Decisions” részébe.

---

## 8️⃣ Canvases és Codex YAML

* Hozz létre egy vásznat a `/canvases` mappában: `<Screen>_Screen_Spec.md`.
* Generálj hozzá YAML-t a `codex/goals/canvases/` mappában: `fill_canvas_<screen>.yaml`.
* Ha implementációs célokra is kell YAML, tedd a `codex/goals/screens/` mappába.

---

## 9️⃣ Pull Request szabály

* Új képernyő **csak akkor mergelhető**, ha a `screen_spec.md`, `acceptance.md`, `test-plan.md` legalább első verziója elkészült.
* A PR descriptionben hivatkozz a kapcsolódó vászonra és ADR-re.

---

## 🔟 Utógondozás

* Release után frissítsd a `changelog.md`-t rövid bejegyzéssel.
* Karbantartsd a dokumentumokat: ha változik a kód, a képernyő dokumentációját is frissíteni kell.

---

## ✅ Eredmény

Az új képernyő teljes körűen dokumentált, könnyen kereshető és hivatkozható a fejlesztés, tesztelés és üzleti döntések során.

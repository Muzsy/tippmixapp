# Odds Drift Prompt – i18n (ARB) & hozzáférhetőség (a11y) bevitel

## Kontextus

Az odds drift prompt frontend komponense elkészült (`odds_drift_dialog.dart`, `TicketService.confirmAndCreateTicket`). A projektben a lokalizációs és a hozzáférhetőségi irányelvek szerint minden új UI‑szöveget ARB fájlokban kell kezelni, és legalább alap szintű a11y ellenőrzést kell végezni (gombok, címkék, fókusz).

## Cél (Goal)

A dialog összes feliratát **ARB alapra** tenni (angol+magyar), automatikus l10n generálással, és hozzáadni **widget teszteket** a lokalizációra és a hozzáférhetőségre (semantics label, fókuszálhatóság). Külső csomagokat nem vezetünk be.

## Feladatok

* [ ] Új/karbantartott ARB bejegyzések: `oddsChanged`, `old`, `new`, `accept`, `cancel`, valamint rövid leírók a hint/semantics célra
* [ ] `odds_drift_dialog.dart` átírása `AppLocalizations` használatra, egységes `Semantics` és `tooltip` attribútumokkal
* [ ] `flutter gen-l10n` futtatás (build step); szükség esetén `l10n.yaml` minimális kiegészítése
* [ ] Widget tesztek: lokalizáció (HU/EN render) és a11y (semantics tree tartalmazza a gombok címkéit)
* [ ] `flutter analyze` és `flutter test` zöld

## Acceptance Criteria / Done Definition

* [ ] Minden, a dialoghoz tartozó UI‑szöveg ARB‑ből jön (EN+HU), fordítások jelennek meg tesztben
* [ ] A dialog gombjai és címe rendelkeznek **Semantics** címkével
* [ ] L10n generálás hibamentes (`AppLocalizations` elérhető és használt)
* [ ] Elemzés és teszt zöld

## Hivatkozások

* Canvas → `/codex/goals/fill_canvas_odds_drift_i18n_and_accessibility.yaml`
* Előzmények: `odds_drift_prompt_frontend.md`
* Codex szabályok: `Codex Canvas Yaml Guide.pdf`, `localization_logic.md` (ha jelen van a repo‑ban)

---

### 🎯 Funkció

Lokalizált és hozzáférhető odds drift prompt: ARB alapú feliratok + a11y ellenőrzés (semantics).

### 🧠 Fejlesztési részletek

* **ARB kulcsok (EN/HU)**

  * `oddsChangedTitle`: "Odds changed" / "Odds megváltozott"
  * `oddsOld`: "Old" / "Régi"
  * `oddsNew`: "New" / "Új"
  * `accept`: "Accept" / "Elfogad"
  * `cancel`: "Cancel" / "Mégse"
  * (Opcionális) `oddsChangedBody(count)`: számozott üzenet – pl. "{count} selection changed"
* **Dialog módosítás**

  * `AppLocalizations.of(context)` használata minden felirathoz
  * `Semantics(label: ...)` a gombokon és a cím körül
  * `Tooltip` a gombokon (segítő szöveg megegyezik a lokális felirattal)
* **Konfiguráció**

  * `lib/l10n/intl_en.arb`, `lib/l10n/intl_hu.arb` – ha nem léteznek, hozzuk létre
  * `flutter gen-l10n` futtatása; `l10n.yaml` csak akkor kerül be, ha hiányzik (alap beállítással)

### 🧪 Tesztállapot

* **Widget teszt**: build HU és EN locale‑lal, ellenőrizni a dialog title/gombfeliratokat
* **A11y teszt**: `tester.ensureSemantics` + ellenőrizni, hogy a semantics tree tartalmazza a gombok címkéit

### 🌍 Lokalizáció

* Új ARB kulcsok és fordítások EN/HU; a jövőbeni nyelvekhez a kulcsok stabilak

### 📎 Kapcsolódások

* `lib/widgets/odds_drift_dialog.dart` – patch: l10n + semantics
* `lib/l10n/*` – ARB fájlok és opcionális `l10n.yaml`
* `test/widgets/odds_drift_dialog_localization_test.dart` – új teszt

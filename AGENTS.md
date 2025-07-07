# 🧠 AGENTS.md – TippmixApp Codex szerepleírás

Ez a fájl a Codex működését szabályozó, **globálisan betöltendő** háttérleírás.
A benne foglalt szabályok minden vászon (.md) + lépéslista (.yaml) az egyetlen elfogadott workflow

---

## 📦 Projekt‐összefoglaló

* **TippmixApp** – közösségi sportfogadási szimulátor (Flutter + Firebase)
* Virtuális **TippCoin** pénznem (CoinService + Cloud Functions)
* OddsAPI integráció a valós idejű odds‑okhoz
* Enum‑alapú **AppLocalizations** rendszer + runtime nyelvváltás
* **Codex‑alapú** fejlesztés: vászon (.md) + lépéslista (.yaml) az egyetlen elfogadott workflow

---

## 🧾 Kötelezően figyelembe veendő szabályfájlok

Az alábbi fájlok **automatikusan betöltődnek** minden Codex‑futás során; a kimenet akkor érvényes, ha *mindegyik* szabályrendszernek megfelel.

### 🔒 Codex szabályzat (`codex_docs/`)

| Fájl                         | Leírás                                                          |
| ---------------------------- | --------------------------------------------------------------- |
| `codex_context.yaml`         | Fájlszintű működés, naming‑konvenciók, általános tiltások       |
| `routing_integrity.md`       | GoRouter navigáció – kötelező `context.goNamed()` használat     |
| `localization_logic.md`      | Lokalizációs architektúra, `loc()` wrapper                      |
| `service_dependencies.md`    | Engedélyezett service‑gráf, függőségi táblázat                  |
| `priority_rules.md`          | P0–P3 feladat‑prioritási szabályok                              |
| `codex_prompt_builder.yaml`  | Prompt felépítési irányelvek                                    |
| `codex_dry_run_checklist.md` | Kötelező pre‑commit ellenőrzési lista                           |
| `codex_theme_rules.md`       | **Színséma‑logika, FlexColorScheme, hard‑coded színek TILOS**   |
| `testing_guidelines.md`      | Tesztesetek minimális követelményei (unit, widget, integrációs) |

### 📚 Háttérdokumentáció (`docs/`)

| Fájl                                   | Téma                                                             |
| -------------------------------------- | ---------------------------------------------------------------- |
| `theme_management.md`                  | **Hivatalos színséma kezelési dokumentáció**                     |
| `BrandColors_hasznalat.md`             | Brand színek használata `ThemeExtension`‑ön keresztül            |
| `ThemeService_hasznalat.md`            | ThemeService API és perzisztencia‑logika                         |
| `golden_and_accessibility_workflow.md` | Golden + a11y pipeline (jelenleg *inaktív*, lásd döntési doksit) |
| `auth_best_practice.md`                | Firebase Auth irányelvek                                         |
| `localization_best_practice.md`        | ARB struktúra, nyelvi kulcsok                                    |
| `tippmix_app_teljes_adatmodell.md`     | Teljes adatmodell és entitás‑kapcsolatok                         |
| `betting_ticket_data_model.md`         | TicketModel, TipModel részletes leírás                           |
| `coin_logs_cloud_function.md`          | Coin tranzakciók Cloud Function naplózása                        |
| `security_rules_ci.md`                 | Firestore biztonsági szabályok és CI ellenőrzés                  |

> **Megjegyzés:** a golden/a11y pipeline ideiglenesen szünetel, amíg legalább egy fő UI‑képernyő el nem éri az MVP státuszt (lásd `Golden_a11y QA Sprintek átmeneti szüneteltetése.pdf`).
> A szabályzatok viszont már most is érvényben vannak, és a pipeline aktiválásakor azonnal betartandók.

---

## ⚠️ Globális tilalmak

A Codex **soha nem** módosíthatja / commitolhatja:

* `pubspec.yaml`
* `firebase.json`
* `l10n.yaml`
* `.env`
* **Bináris fájlok** (PNG, JPG, PDF, ZIP, stb.) – ezek manuális fejlesztői commitot igényelnek

**Tilos továbbá:**

1. Új enum, service, screen vagy route létrehozása **vászon (.md) + YAML** nélkül
2. Hard‑coded string a lokalizációban
3. Hard‑coded szín (hex, rgb, `Colors.*`, stb.) bármely widgetben vagy `ThemeData`‑ban
4. `context.go()` vagy `Navigator.push()` használata `GoRouter` helyett
5. CI pipeline mellőzése – minden PR csak zöld CI‑vel mergelhető

---

## ✅ Definition of Done (DoD)

* **Új képernyő** → min. *1 widget test* (`test/widgets/`)
* **Új service** → *unit test* a `test/services/` mappában
* **Lokalizáció** → `hu`, `en`, `de` frissítés, `AppLocalizationsKey` enum bővítés
* **Színséma** → Nincs hard‑coded szín, linter (`avoid-hard-coded-colors`) warningmentes
* **CI pipeline** → `flutter analyze` + `flutter test --coverage` **minden lépése zöld**

---

## Codex defaults

```yaml
target_branch: main
```

> Ha a Codex eltérne a fenti branch‑től, explicit utasítás (canvas) szükséges.

---

Ez a fájl **kötelező érvényű** a teljes TippmixApp projektre.
Bármely generált kód, amely a fenti szabályok bármelyikét megszegi, **érvénytelen** és azonnali javításra, illetve PR‑visszavonásra szorul.

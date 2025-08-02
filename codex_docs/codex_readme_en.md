# 🧑‍💻 Codex Dokumentációs Központ / Documentation Hub

> **Cél / Purpose**
> A Codex AI‑ügynökök által futásidőben betöltött **kontekstus‑, szabály‑ és ellenőrző listák** központi tárháza.
> The central repository for all **context, rule and checklist** files loaded by the Codex AI agents at runtime.

⚠️ **Fontos / Important**
*Az ügynökök kizárólag az **angol** fájlokat használják* (suffix: `_en.md`). A magyar verziók (`_hu.md`) az emberi fejlesztőknek szólnak.
*Agents consume **English** files only (`_en.md`). Hungarian counterparts (`_hu.md`) are for human developers.*

---

## Hogyan használd / How to use this folder

1. **Böngészd át a Tartalomjegyzéket / Table of Contents** – válaszd ki a neked megfelelő nyelvet.
   Skim the TOC below and open the file in the language you prefer.
2. **Metaadat‑fejléc / Metadata header** minden fájl tetején:

   ```yaml
   version: "YYYY-MM-DD"
   last_updated_by: <GitHub‑felhasználó / user>
   depends_on: [<egyéb_fájlok / other_files>]
   ```

3. **Szerkesztéskor / When editing**: növeld a `version` értéket, add meg a neved a `last_updated_by` mezőben, és törekedj atomikus commitra.
   Bump `version`, fill `last_updated_by`, and keep commits atomic.
4. **Lintelés / Linting**: push előtt futtasd a `./scripts/lint_docs.sh` szkriptet (markdownlint + fájlnév‑regex).
   Run `./scripts/lint_docs.sh` locally before pushing (markdownlint + filename regex).

### Mappa‑szabályok / Folder rules

| ✅ Ajánlott / Do                                                             | 🚫 Kerülendő / Do NOT                                                                |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| Két külön fájl nyelvenként (`*_en.md`, `*_hu.md`)                           | PDF‑ek commitolása – előbb konvertáld Markdownra / Commit PDFs – convert to MD first |
| `snake_case` fájlnevek / file names                                         | Üzleti és technikai tartalom keverése / Mix business & tech in one doc               |
| Magyarázd az *okokat* is, ne csak a *mit* / Explain *why* as well as *what* | Kötelező ellenőrző listák törlése / Delete mandatory checklists                      |

---

## Tartalomjegyzék / Table of Contents

| 🇬🇧 File (EN)                                             | 🇭🇺 Fájl (HU)                                             | Purpose / Rendeltetés                                         |
| ---------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------- |
| **[`codex_readme_en.md`](codex_readme_en.md)**             | **[`codex_readme_hu.md`](codex_readme_hu.md)**             | Codex‑integráció áttekintése / Codex integration overview     |
| [`codex_context.yaml`](codex_context.yaml)                 | —                                                          | Globális futásidő‑konfiguráció / Global runtime configuration |
| [`codex_prompt_builder.yaml`](codex_prompt_builder.yaml)   | —                                                          | Prompt sablonok / Prompt templates                            |
| [`priority_rules_en.md`](priority_rules_en.md)             | [`priority_rules_hu.md`](priority_rules_hu.md)             | P0–P3 súlyossági mátrix / Severity matrix                     |
| [`routing_integrity_en.md`](routing_integrity_en.md)       | [`routing_integrity_hu.md`](routing_integrity_hu.md)       | Kötelező GoRouter minták / Mandatory GoRouter patterns        |
| [`localization_logic_en.md`](localization_logic_en.md)     | [`localization_logic_hu.md`](localization_logic_hu.md)     | i18n folyamat / i18n flow                                     |
| [`service_dependencies_en.md`](service_dependencies_en.md) | [`service_dependencies_hu.md`](service_dependencies_hu.md) | Service‑gráf és DI határok / Service graph & DI boundaries    |
| [`theme_rules_en.md`](theme_rules_en.md)                   | [`theme_rules_hu.md`](theme_rules_hu.md)                   | FlexColorScheme korlátok / Theme rules                        |
| [`testing_guidelines_en.md`](testing_guidelines_en.md)     | [`testing_guidelines_hu.md`](testing_guidelines_hu.md)     | Tesztminimumok / Test minimums                                |
| [`precommit_checklist_en.md`](precommit_checklist_en.md)   | [`precommit_checklist_hu.md`](precommit_checklist_hu.md)   | Pre‑commit ellenőrző lista / Pre‑commit checklist             |

> **Félkövérrel / Bold** jelölt sorok kötelező olvasmány minden új fejlesztőnek / are mandatory reading for every new contributor.

---

## Változásnapló / Changelog

| Dátum / Date | Szerző / Author | Megjegyzés / Notes                                                               |
| ------------ | --------------- | -------------------------------------------------------------------------------- |
| 2025‑07‑29   | @docs‑bot       | Első README létrehozva, bilingvális struktúra / Initial bilingual README created |

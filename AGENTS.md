# 🧠 Agents.md – TippmixApp Codex szerepleírás

Ez a fájl a Codex működését szabályozó, mindig automatikusan betöltendő globális háttérleírás.

---

## 📦 Projekt: TippmixApp – mobil sportfogadási szimulátor

- Virtuális TippCoin pénznem (CoinService + Firestore)
- Firebase alapú backend (auth, Firestore, Cloud Functions)
- OddsAPI integráció valós idejű sporteseményekhez
- Enum-alapú AppLocalizations rendszer + runtime nyelvváltás
- Codex-alapú fejlesztés: vásznak és yaml fájlok alapján történik minden kódgenerálás

---

## 🧾 Kötelezően figyelembe veendő szabályfájlok

Minden Codex-feldolgozás során az alábbi fájlokat **automatikusan figyelembe kell venni**:

### 🔒 Codex szabályzat (`codex_docs/`)

- `codex_context.yaml` – fájlszintű működés, tilalmak, naming konvenciók
- `routing_integrity.md` – GoRouter navigáció, `context.goNamed()` kötelező
- `localization_logic.md` – lokalizáció AppLocalizationsKey + loc() wrapper szerint
- `service_dependencies.md` – engedélyezett service-függőségek táblázata
- `priority_rules.md` – P0–P3 fejlesztési sorrend
- `codex_prompt_builder.yaml` – prompt felépítési szabályok
- `codex_dry_run_checklist.md` – futtatás előtti kötelező ellenőrzési lista

### 📚 Háttérdokumentáció (`docs/`)

- `auth_best_practice.md` – Firebase Auth használati ajánlások
- `localization_best_practice.md` – AppLocalizations és ARB fájlstruktúra
- `tippmix_app_teljes_adatmodell.md` – minden modell, típus és kapcsolódás
- `betting_ticket_data_model.md` – TicketModel, TipModel részletes adatstruktúra
- `canvases_odds_api_integration.md` – OddsAPI és odds_cache_wrapper működés

---

## ⚠️ Globális tilalmak

A Codex **soha nem** módosíthatja az alábbi fájlokat:
- `pubspec.yaml`
- `firebase.json`
- `l10n.yaml`
- `.env`

Tilos:
- Új enum, service, screen vagy route létrehozása canvas nélkül
- Lokalizáció hardcoded stringgel
- `context.go()` vagy `Navigator.push()` használata

---

## ✅ Kötelező DoD (Definition of Done)

- Új képernyőhöz: minimum 1 db widget test
- Új service-hez: unit test a `test/services/` mappában
- Lokalizáció minden nyelvre: `hu`, `en`, `de`
- Enum kulcs regisztráció + `.arb` frissítés lokalizáció esetén
- CI pipeline futtatása: `flutter test --coverage` zöld

---

## Codex defaults
target_branch: theme_refactor_start

Ez a fájl automatikusan érvényes minden Codex-generálásra.  
Ha bármely szabály vagy dokumentum nem kerül figyelembevételre, a generált kód **érvénytelen**.

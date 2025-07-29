# 📘 readme\_codex.md – TippmixApp Codex dokumentációs belépő

Ez a dokumentum a TippmixApp Codex-integrációs rendszerének bevezetője. Összefoglalja a Codex működésének alapját, a vásznak és YAML fájlok szerepét, és a projekt-specifikus szabályfájlokat.

---

## 🧠 Mi az a Codex?

A Codex egy fejlesztéstámogató AI rendszer, amely fájlszintű, determinisztikus módosításokat hajt végre ember által írt specifikációk alapján. A TippmixApp projektben ez vásznakból (canvases) és hozzájuk tartozó YAML utasításfájlokból áll.

---

## 📦 Alapkönyvtárak

* `canvases/` – ember által írt modulleírások (pl. `coin_service.md`)
* `codex/goals/` – YAML utasításfájlok (pl. `fill_canvas_coin_service.yaml`)
* `lib/`, `cloud_functions/` – tényleges implementációs célfájlok
* `docs/` – háttéranyagok: adatmodell, auth, odds API, stb.
* `codex_docs/` – szabályfájlok: `codex_context.yaml`, `localization_logic.md`, stb.

---

## 📄 Folyamat

1. ✍️ Vászon készítése: pl. `canvases/settings_screen.md`
2. 🔧 YAML létrehozása: `fill_canvas_settings_screen.yaml` (steps + outputs)
3. 📤 Codex futtatás: a prompt a canvas + yaml alapján épül
4. ✅ Eredmény validálása: CI, tesztek, manuális átnézés

---

## 📚 Kötelező szabályfájlok

| Fájl                         | Leírás                                           |
| ---------------------------- | ------------------------------------------------ |
| `codex_context.yaml`         | Projektstruktúra, Codex-keretek                  |
| `localization_logic.md`      | Lokalizáció logika és enum-alapú kulcskezelés    |
| `routing_integrity.md`       | Named route navigáció és GoRouter                |
| `service_dependencies.md`    | Minden service engedélyezett kapcsolatát rögzíti |
| `priority_rules.md`          | P0–P3 szintű prioritás szerint dolgozik a Codex  |
| `codex_prompt_builder.yaml`  | Hogyan épül fel egy prompt                       |
| `codex_dry_run_checklist.md` | Futtatás előtti ellenőrzési kötelezettségek      |
| `codex_overview.md`          | Teljes szabályrendszer áttekintése               |

---

## 🚦 Futási kritériumok

* Minden fájl szerepel a canvasban és a YAML `outputs:` mezőjében
* Nincs nem dokumentált fájl / class / funkció használat
* Csak típusbiztos, CI-kompatibilis Dart/TS kód keletkezhet

---

## 🧪 Tesztelési elvárások

* Widget test minden képernyőhöz
* Unit test minden új service-hez
* Lokalizáció teszt: `hu`, `en`, `de`

---

## ⚠️ Tiltások

* `pubspec.yaml`, `firebase.json`, `l10n.yaml` fájlok módosítása tilos
* `Navigator.push` hívás tilos, csak `context.goNamed()`
* Hardcoded stringek helyett mindig `loc(context).kulcs`

---

Ez a fájl az első belépési pont minden Codex-munkafolyamat előtt. A projekt minden tagja számára kötelező hivatkozási alap.

# Szelvény leadás utáni flow – ürítés + routing\_integrity megfelelés

🎯 **Funkció**

* Sikeres „Fogadás leadása” után a **szelvény ürüljön** (Riverpod `betSlipProvider.clearSlip()`), majd az app **visszanavigáljon** a Fogadások képernyőre **név alapú GoRouter** hívással.
* A FAB (Szelvény készítése) továbbra is csak akkor jelenjen meg, ha van tipp; ürítés után eltűnik.
* A Snackbar üzenet maradjon a meglévő kulcs: **`ticket_submit_success` = „Szelvény sikeresen elküldve”**.

🧠 **Fejlesztési részletek**

* **Érintett fájlok** (a most feltöltött `tippmixapp.zip` alapján):

  * `lib/screens/create_ticket_screen.dart` – `_submitTicket()` sikerág: szelvényürítés + név alapú GoRouter navigáció.
  * `lib/screens/events_screen.dart` – FAB navigáció: nyers path helyett `pushNamed`.
* **routing\_integrity** (lásd: `/codex_docs/routing_integrity.md`):

  * **Tilos**: `Navigator.pop/push`, nyers path stringek.
  * **Előírás**: `context.goNamed(...)` / `context.pushNamed(...)`, központi route enum (pl. `AppRoute`).
* **Importok**: minden érintett fájlban legyen

  * `import 'package:go_router/go_router.dart';`
  * `import 'package:tippmixapp/routes/app_route.dart';`
* **Állapotkezelés**: az ürítést a UI hívja sikeres beküldés után: `ref.read(betSlipProvider.notifier).clearSlip();`

🧪 **Tesztállapot**

* Manuális ellenőrzés:

  1. Tipp(ek) kiválasztása → FAB megjelenik.
  2. „Szelvény készítése” → tét megadása → „Fogadás leadása”.
  3. Snackbar: „Szelvény sikeresen elküldve”.
  4. Automatikus visszanavigálás a Fogadások képernyőre.
  5. FAB **nem** látszik (mert `betSlipProvider` üres).
* Automatizálható widget teszt ötlet:

  * Mock `BetSlipService.submitTicket` sikerre, majd assert: hívódott `clearSlip()`, `goNamed(AppRoute.bets)`, és Snackbar megjelent.

🌍 **Lokalizáció**

* Nem változik; a meglévő `ticket_submit_success` marad.

📎 **Kapcsolódások**

* Codex YAML: `/codex/goals/canvases/fill_canvas_submit_flow_clear_and_routing_integrity.yaml` (pontszerű diffekkel)
* Irányelv: `/codex_docs/routing_integrity.md`

---

**Készre jelentés feltételei**

* [ ] `create_ticket_screen.dart` sikerág: `clearSlip()` + `goNamed(AppRoute.bets)` + Snackbar.
* [ ] `events_screen.dart` FAB: `pushNamed(AppRoute.createTicket)` (nincs nyers path).
* [ ] `flutter analyze` és tesztek zöldek.

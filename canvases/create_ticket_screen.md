## 🎯 Funkció

A `CreateTicketScreen` felelős a felhasználói fogadószelvény véglegesítéséért és beküldéséért a Firestore-ba. A képernyőn megadható a tét (TippCoin), megjelennek az aktuálisan kiválasztott tippek, és lehetőség van a fogadás elküldésére. A cél a szelvény érvényesítése és mentése a bejelentkezett felhasználóhoz rendelve.

## 🧠 Fejlesztési részletek

* A képernyő `ConsumerStatefulWidget`, Riverpod segítségével figyeli az állapotokat.
* A `submitTicket()` hívás a `BetSlipService` statikus metódusára épül.
* A felhasználói azonosítót jelenleg `FirebaseAuth.instance.currentUser?.uid` hivatkozással kéri le.
* Ez a megoldás nem konzisztens a projekt többi részében alkalmazott `authProvider` állapotfigyeléssel.
* A Codex audit alapján javasolt módosítás:

  * `final user = ref.watch(authProvider);`
  * ha `user == null`, állítsunk be UI hibaüzenetet, ne engedjük a mentést
  * egyébként a `user.uid` értéket adjuk át `submitTicket()`-nek

## 🧪 Tesztállapot

* A képernyő jelenleg nem rendelkezik widget teszttel
* Az autentikációs ágat (nem bejelentkezett felhasználó) nem teszteljük
* Javasolt widget test: helyes tét validáció, auth hiány kezelése, sikeres mentés

## 🌍 Lokalizáció

* A hibaüzenetek `AppLocalizations` használatával jelennek meg (pl. `loc.errorNotLoggedIn`)
* ARB fájlban szerepel az `errorNotLoggedIn` kulcs mindhárom nyelven

## 📎 Kapcsolódások

* `lib/screens/create_ticket_screen.dart`
* `lib/providers/auth_provider.dart`
* `lib/services/bet_slip_service.dart`
* Codex szabályzat: `auth_best_practice.md`, `service_dependencies.md`, `codex_context.yaml`

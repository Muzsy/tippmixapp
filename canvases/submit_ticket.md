## 🌟 submitTicket() szelvénybeküldés funkció

### 🌟 Funkció

A `submitTicket()` metódus a fogadási szelvények beküldését kezeli. Feladata:

* A kiválasztott tippek („`tips`”) érvényességének ellenőrzése
* A felhasználó azonosításának megerősítése (`FirebaseAuth.currentUser`)
* A CoinService segítségével a TippCoin egyenleg csökkentése
* A szelvény feltöltése a Firestore `tickets/` kollekcióba

### 🧠 Fejlesztési részletek

* Fájl: `lib/services/bet_slip_service.dart`
* Metódus: `Future<void> submitTicket({required List<TipModel> tips})`
* Kötelező az autentikált user megléte, ellenőrizni kell `FirebaseAuth.instance.currentUser`
* TippCoin levonás: `CoinService.debitCoin()` híváson keresztül
* Szelvény mentés: `FirebaseFirestore.instance.collection('tickets').add({...})`
* A beküldés után további logika (badge, feed) async alapon kapcsolható

### 🧪 Tesztállapot

* Jelenleg nincs külön unit teszt a metódusra
* A hibák Flutter logban (pl. unauthenticated) jelennek meg
* Ajánlott: mockolt CoinService és Firestore instance tesztelése

### 🌍 Lokalizáció

* A szolgáltatás nem tartalmaz UI-t vagy szöveget
* Hibakezelés esetén csak technikai kivételt dob (pl. FirebaseFunctionsException)
* Igény esetén beköthető lokalizált SnackBar vagy AlertDialog a hívó oldalon

### 📌 Kapcsolódások

* `lib/services/coin_service.dart` → Coin levonási logika
* `lib/models/tip_model.dart` → A fogadott tippek modellje
* `lib/screens/create_ticket_screen.dart` → UI gomb hívja
* Firestore szabály: `match /tickets/{id} { allow write: if request.auth != null && request.auth.uid == resource.data.userId }`
* Codex szabály: `service_dependencies.md`, `auth_best_practice.md`, `firebase.rules`

---

Ez a metódus a tétlevonás és szelvénymentés kulcspontja, érdemes Codex YAML-lel auditálni és tesztelni a hibakezelés stabilitását.

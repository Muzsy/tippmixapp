## 🔐 AuthProvider + AuthService modul

### 🌟 Funkció

Az autentikációért felelős modul, amely a Firebase Authentication email/jelszó alapú bejelentkezését és regisztrációját kezeli. A `login()`, `register()`, `logout()` metódusok
Riverpod állapotot is frissítenek.

### 🧠 Fejlesztési részletek

* Fájlok:

  * `lib/services/auth_service.dart`: FirebaseAuth hívások (signInWithEmail, registerWithEmail, signOut)
  * `lib/providers/auth_provider.dart`: StateNotifier + auth state stream kezelés
* A login() / register() metódusban a hibakezelés csak `rethrow`, ami a hívó oldalon nem biztosít védelmet
* `User` saját modellbe átfordítva van
* Az auth state figyelése stream-alapon történik (authStateChanges)

### 🧪 Tesztállapot

* Nincs külön unit teszt a `login()` és `register()` metódusokra
* Hibakezelés tesztje nem történik
* Riverpod állapotfrissítés tesztje csak az authStateChanges() streammel lehetséges jelenleg

### 🌍 Lokalizáció

* A hívó UI oldalon nincs lokalizált hibaüzenet
* Jelenleg a hívás hibája logban jelenik meg (`Unhandled Exception: auth/unknown`)
* Ajánlott a hibakódok UI-komponensből való lokalizált feldolgozása (pl. SnackBar, AlertDialog)

### 📌 Kapcsolódások

* `lib/screens/login_register_screen.dart` → hívja a login() / register() metódusokat
* `auth_best_practice.md` → FirebaseAuth + biztonságos hibakezelési javaslatok
* `user_model.dart` → AuthService-ből visszatérő belső User reprezentáció
* `firebase_auth` plugin

---

A jelenlegi modul működik, de **a hibakezelés hiánya miatt nem Codex-konform**. Javasolt fallback-stratégia bevezetése és a login-flow lokalizált visszajelzéssel való bővítése.

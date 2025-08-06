# 🔐 Bejelentkezési és regisztrációs stratégia (HU)

Ez a dokumentum bemutatja a **TippmixApp** hitelesítési rendszerét: Firebase Auth, UI folyamat, és Codex szabályok.

---

## 🔧 Használt technológiák

- **Firebase Authentication** (email + jelszó)
- **Riverpod** – állapotfigyeléshez
- **GoRouter** – auth alapú navigáció

## 🧭 Bejelentkezési folyamat

```
[Alkalmazás indul]
   ↓
[AuthStateListener] → be van lépve?
   ↓                     ↓
[Belépés/Regisztráció] [Főképernyő]
```

## 🧪 Komponensek

- `LoginScreen` – űrlap email/jelszóval, validációval
- `RegisterScreen` – Firebase user létrehozás + TippCoin beállítás
- `AuthController` – belépés, regisztráció, kijelentkezés logika
- `auth_provider.dart` – `authStateChanges` stream expozíció
- `GoRouter` – `redirect:` használat auth állapot alapján
- `AuthGate` – védi a privát útvonalakat, Home-on placeholderként kezeli a gridhez

## 🎯 Codex szabályok

- Használj `authStateChanges()`-t – ne `currentUser`-t
- Regisztráció után ments `UserModel`-t a Firestore-ba
- TippCoin mezőt kötelező beállítani (pl. 1000)
- Email megerősítés támogatása javasolt

## 🚧 Ismert problémák

- Nincs jelszó erősség ellenőrzés az űrlapon
- Email megerősítés nincs implementálva (tervezett)

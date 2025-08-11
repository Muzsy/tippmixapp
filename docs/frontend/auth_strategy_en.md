# 🔐 Authentication Strategy (EN)

This document outlines the authentication system in **TippmixApp**, including Firebase Auth usage, UI flow, and DoD requirements.

---

## 🔧 Technology Used

- **Firebase Authentication** (email + password)
- **Riverpod** for session state management
- **GoRouter** redirects based on auth state

## 🧭 Login Flow

```
[Launch App]
   ↓
[AuthStateListener] → isLoggedIn?
   ↓                     ↓
[Login/Register]     [HomeScreen]
```

## 🧪 Components

- `LoginScreen` – form with email/password, validation
- `RegisterScreen` – creates Firebase user, sets initial TippCoin
- `AuthController` – handles signIn, register, signOut
- `auth_provider.dart` – exposes `authStateChanges` stream
- `GoRouter` redirects based on auth state (`redirect:` logic)
- `AuthGate` – guards private routes and leaves verified users on `/` so the Home grid becomes default

## 🎯 Codex Rules

- Always use `authStateChanges()` – not `currentUser`
- After registration, write `UserModel` to Firestore
- Registration must set default TippCoin (e.g. 1000)
- Add email verification support if needed

## 🚧 Known Issues

- No client-side password validation rules
- No email verification flow (planned)

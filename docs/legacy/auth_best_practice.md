# 🟢 User autentikáció, vendég mód és funkcióvédelem – TippmixApp MVP (2025)

---

## 🎯 Funkció

- Modern user autentikáció megvalósítása: harmadik féltől származó login (Google, Apple), saját email+jelszó csak másodlagosan.
- Vendég felhasználók támogatása: minden oldal szabadon böngészhető, de aktív funkciókhoz (fogadás, hozzászólás, TippCoin, badge, értékelés) *kötelező* a bejelentkezés.
- Felhasználóbarát, bevonó UX: előbb mutatunk, utána kérünk regisztrációt.

---

## 🧠 Fejlesztési részletek

- **Auth state központi kezelése:**
  - Auth observer (FirebaseAuth/Provider/Riverpod/Bloc...)
  - App induláskor login state alapján döntés: vendég vagy regisztrált user flow
- **Vendég módban**:
  - Böngészés, toplisták, események, profilok, statisztikák elérhetőek
  - Minden aktív gombnál/auth-only funkciónál: login-check, popup vagy login-prompt
  - Aktív gomboknál lock ikon vagy elhalványítás
- **Regisztrált user**:
  - Aktív funkciók teljes elérés
  - Session kezelése secure storage-ban
- **Backend/API**:
  - Token alapú védelem minden aktív funkción
  - API-ban auth middleware
- **UI/UX**:
  - Vendég státusz vizuálisan megjelenítve (pl. „Vendég” badge, szürke aktív gombok)
  - Próbálkozás aktív funkcióval: azonnali regisztráció/login prompt, motivációs szöveg

---

## 🟣 Routing & GoRouter Best Practice (2025)

- **GoRouter használata** (Flutter hivatalos, deklaratív routing):
  - Átlátható route kezelés auth-jogosultsággal
  - Beépített `redirect` callback auth-védelemhez (pl. csak bejelentkezett user láthatja a fogadás oldalt)
- **Soft wall UX**: fő oldalak mindig elérhetőek (guest is lát mindent), aktív page/funkció route-ján van redirect
- **UI-ban is check, route-on is redirect**: UI gombok nem aktívak guestnek, de route redirect is védi
- **Best practice:**
  - Auth providerből szedd az állapotot (Provider/Riverpod/etc)
  - ShellRoute/strukturált navigáció nagyobb appnál
  - Hibakezelés: redirectnél őrizd meg returnUrl-t, vissza lehessen vezetni sikeres login után
- **Példa GoRouter auth-checkre:**

```dart
final _router = GoRouter(
  routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AuthGate()),
      ),
    GoRoute(
      path: '/fogadas',
      builder: (context, state) => BetScreen(),
      redirect: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        return user != null ? null : '/login';
      },
    ),
    // ...
  ],

);
```

Az alap '/' route tehát egy `AuthGate` widgetre mutat, amely dönti el, hogy a
felhasználó a LoginScreenre, az EmailNotVerifiedScreenre vagy a HomeScreenre
kerül.

---

## 🧪 Tesztállapot

- MVP-re a következőket kell ellenőrizni:
  - Auth state observer működik mindenhol
  - Vendégként csak nézhető minden, aktív gombok blokkoltak, prompt működik
  - Bejelentkezve minden funkció elérhető
  - Token kezelés biztonságos (secure storage, backend validáció)
  - GoRouter route protection minden auth-only oldalra

---

## 🌍 Lokalizáció

- Login, regisztráció, prompt szövegek minden támogatott nyelven
- Vendég státusz, „Csak regisztrált felhasználóknak” típusú üzenetek mind lefordítva

---

## 📎 Kapcsolódások

- Auth modul kapcsolódik a backend API-hoz, user adatmodellhez
- Vendég/Regisztrált user állapotot minden feature screen és widget figyeli
- Session kezelő/Token manager
- UI komponensek (gombok, promptok) közös wrapperrel használják a login-checket
- GoRouter minden oldalra/auth-only page-re kiterjed

---

## 🏁 TL;DR

- **Vendég bármit nézhet, de nem aktíválhat**
- Aktív funkció csak login után
- Modern auth: Google/Apple/Firebase Auth
- UX: először mutass, csak utána kérj regisztrációt
- GoRouter: deklaratív, skálázható route védelem, hosszú távon kötelező

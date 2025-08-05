# 🏛️ Rendszerarchitektúra áttekintés (HU)

Ez a dokumentum a **TippmixApp** magas szintű architektúráját mutatja be,
a főbb modulokat, rétegeket és keresztfunkciókat összefoglalva.

## 🧱 Fő komponensek

### 1. Flutter kliens

- **Material 3** dizájn + **Riverpod** állapotkezelés.
- Navigáció: **GoRouter** (ShellRoute) AppBar + BottomNavBar elrendezéssel.
- Lokalizálás: `flutter_localizations` + `.arb` fájlok.
- Fő képernyők: Főoldal, Profil, Szelvényeim, Belépés, Regisztráció, Beállítások (fejlesztés alatt).

### 2. Firebase backend

- **Firebase Authentication** – email/jelszavas beléptetés.
- **Firestore** – felhasználók, szelvények, odds pillanatképek tárolása.
- **Firebase Functions** – terv szerint odds frissítés, eredménykezelés, TippCoin logika.
- **Emulátor** – teszteléshez ajánlott a Firebase Emulator használata.

### 3. Külső API

- **OddsAPI** integráció: valós idejű odds lekérés.
- Egyedi `OddsApiService` osztályon keresztül történik a kommunikáció.
- API kulcs jelenleg beégetve – terv szerint `.env` fájlba költözik.

### 4. Cloud Functions (Node/TypeScript)

- `match_finalizer.ts`: meccsek kiértékelése.
- Később további ütemezett feladatokkal bővülhet.

---

## 🧭 Rétegzett felépítés

```
┌──────────────────────────────┐
│        Felhasználó (UI)      │ ← Főképernyő, Profil, Belépés...
└────────────┬────────────────┘
             ↓
┌────────────┴────────────┐
│   Prezentációs réteg     │ ← Widgetek, ViewModel-ek
└────────────┬────────────┘
             ↓
┌────────────┴────────────┐
│   Domain logika réteg   │ ← Szervizek, üzleti logika
└────────────┬────────────┘
             ↓
┌────────────┴────────────┐
│   Adatkezelési réteg    │ ← Firestore, OddsAPI, beállítások
└─────────────────────────┘
```

---

## 🔄 Keresztfunkciók

- **Lokalizáció** – `AppLocalizations`, `loc()` wrapper függvények
- **Témakezelés** – `FlexColorScheme`, világos/sötét mód támogatás
- **Biztonság** – Firestore szabályok, még nem véglegesítve
- **Tesztelés** – widget tesztek vannak, bővítés szükséges (szerviz, integráció)
- **Codex integráció** – vásznak és YAML fájlok alapján működik (csak az `_en.md` fájlokat használja)

---

## 📌 Tervezett fejlesztések

- API kulcs áthelyezése `.env` fájlba
- Odds frissítő és Coin logikák beépítése Firebase Functions-ként
- CI pipeline bevezetése (`flutter test`, `markdownlint`, link-ellenőrzés)
- Beállítások képernyő befejezése (nyelv + téma választás)

---

Kapcsolódó doksik: `data_model_hu.md`, `auth_strategy_hu.md`, `coin_service_logic_hu.md`

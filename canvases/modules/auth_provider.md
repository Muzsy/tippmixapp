# 🔑 AuthProvider & AuthService modul

🎯 **Funkció**

Az AuthProvider és az AuthService felelős a felhasználói hitelesítés logikájáért, beleértve a regisztrációt, bejelentkezést, tokenkezelést, illetve a felhasználói profil frissítését. A rendszer a `Riverpod` állapotkezelőt használja a szolgáltatások expozíciójára【985332463923123†L0-L16】.

🧠 **Felépítés**

- **Provider réteg** (`auth_provider.dart`): a `ref.watch(authRepositoryProvider)` hívással biztosítja az AuthRepository elérését, és a `signIn`, `register`, `signOut`, `currentUser` függvényeket delegálja a service‑nek【985332463923123†L0-L16】.
- **Service réteg** (`auth_service.dart`): közvetlenül használja a `firebase_auth` API‑t a felhasználói hitelesítési műveletekhez. A service felel a jelszó ellenőrzéséért, a felhasználói adatok (név, avatar) frissítéséért és a hibák megfelelő kezeléséért【985332463923123†L17-L29】.
- **Model réteg** (`auth_user.dart`): definiálja a belső felhasználó modellt (ID, email, displayName stb.).
- A modul UI‑val való integrációja aszinkron módon történik, a műveletek progress állapotát `AsyncValue` segítségével jelezve.

📄 **Kapcsolódó YAML fájlok**

- `fill_canvas_auth_provider.yaml` – a Codex tartalmazza a részletes célokat, feladatlistát és DoD‑t【985332463923123†L0-L16】.

🐞 **Fixek és tanulságok**

Az eredeti vászon rámutatott, hogy a hibakezelés nem megfelelő (például nem elkülönítve kezelte a hibakódokat), valamint hiányoztak a service és provider unit tesztek【985332463923123†L17-L29】. Ezeket a problémákat mindenképp orvosolni kell.

🧪 **Tesztállapot**

A modul jelenleg részleges teszttel lefedett: hiányoznak a negatív esetek (rossz jelszó, nem létező felhasználó) és a sikeres token frissítés ellenőrzése. A javasolt tesztek:

- `AuthProvider.signIn` sikeres és sikertelen hívások,
- `AuthService` hibaágak validálása,
- Avatar és felhasználónév frissítési logika.
A NotificationCenter és Reward szolgáltatások használhatják ezt a modult.

📎 **Modul hivatkozások**

- A modul szoros kapcsolatban áll a [Login screen](../screens/login_screen.md) és a [Regisztrációs varázsló](../screens/register_wizard_screen.md) képernyőkkel.

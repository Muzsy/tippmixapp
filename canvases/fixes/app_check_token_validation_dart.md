## 🔹 Codex Canvas: AppCheck Token érvényeség és Auth regisztráció kompatibilitás

### 🌟 Funkció

Ez a Codex ügynök ellenőrzi, hogy a Firebase AppCheck token validálódik-e még a felhasználó regisztráció (Email+jelszó) előtt, elkerülve a "A reCAPTCHA ellenőrzés nem sikerült" hibát.

---

### 🧠 Fejlesztési részletek

- A Codex ellenőrzi, hogy a `FirebaseAppCheck.instance.activate()` időben lefut-e.
- Késleltetést iktat be a Firebase Auth regisztráció előtt, amennyiben a token még nem elérhető.
- Lekéri a `FirebaseAppCheck.instance.getToken()` értékét és logolja.
- Beavatkozik a `createUserWithEmailAndPassword()` előtti folyamatba, ha token érvénytelen vagy hiányzik.

---

### 🧪 Tesztállapot

- ✅ A logban megjelenik érvényes AppCheck token.
- ✅ A regisztráció nem dob reCAPTCHA hibát.
- ❌ Hiba, ha a regisztráció megelőzi az AppCheck aktiválást, vagy token `null`.

---

### 🌍 Lokalizáció

- A log angol nyelvű (Firebase SDK alapértelmezett), de a riport magyarul készül.

---

### 📌 Kapcsolódások

- `lib/firebase_options.dart`
- `main.dart` (AppCheck init)
- `auth_service.dart` vagy hasonló fájl, ahol az Auth regisztráció történik
- Flutter debug log ("reCAPTCHA ellenőrzés nem sikerült")

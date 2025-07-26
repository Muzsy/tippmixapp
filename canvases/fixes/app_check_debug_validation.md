## 🌟 Codex Canvas: App Check Debug Token Validálás

### 🌟 Funkció

Ez a canvas egy automatizált Codex ügynök definiálására szolgál, amely validálja, hogy a Firebase App Check debug token helyesen van-e beállítva a fejlesztői Flutter környezetben. Célja, hogy kiszűrje azokat a hibákat, amelyek miatt a natív `firebase_app_check` plugin mégis új debug tokent generál, vagy elutasítja az előre megadottat.

---

### 🧠 Fejlesztési részletek

A ügynök az alábbi elemeket vizsgálja:

* `main.dart`: beolvassa-e a `FIREBASE_APP_CHECK_DEBUG_TOKEN` kulcsot
* `.vscode/launch.json`: szerepel-e benne a `--dart-define=...` argumentum
* `gradle.properties` és `AndroidManifest.xml`: nem duplikál-e, illetve nem akad-e össze a beállítás
* `google-services.json`: az app package name és project ID egyezik-e a Firebase Console-ban szereplővel
* `flutter run` vagy `run.bat` utáni log: megjelenik-e a "Enter this debug secret..." sor
* Firebase Console Debug Token lista: tartalmazza-e a logban generált tokent

---

### 🧪 Tesztállapot

**Sikeres validáció esetén:**

* A log NEM tartalmaz "Enter this debug secret" sort
* A log NEM generál új tokent
* A Firebase App Check nem blokkolja a hívásokat

**Hibának minősül:**

* Bármelyik forrásfájl nem tartalmazza vagy hibásan adja át a tokent
* A debug token nem szerepel a Console-ban
* A beolvasott token és logban generált nem egyezik

---

### 🌍 Lokalizáció

* A logokat angol nyelven ellenőrzi (pl. "Enter this debug secret..."), a környezet magyar lehet
* A riport magyarul generálódik

---

### 📌 Kapcsolódások

* `main.dart`
* `.vscode/launch.json`
* `android/gradle.properties`
* `android/app/src/main/AndroidManifest.xml`
* `google-services.json`
* Firebase Console > App Check > Debug Tokens
* Logfile: `log.txt` vagy `flutter run` kimenet

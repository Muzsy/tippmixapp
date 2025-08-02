# 🔒 Elfelejtett jelszó és jelszó-visszaállító képernyők

🎯 **Funkció**

A modul háromlépcsős folyamatot biztosít azoknak a felhasználóknak, akik elfelejtették jelszavukat:

1. **Elfelejtett jelszó képernyő** – email cím megadása,
2. **Megerősítő képernyő** – értesítés a sikeres emailküldésről,
3. **Jelszó-visszaállító képernyő** – új jelszó beállítása a dinamikus linkből megnyitva【471745219585009†L7-L16】.

🧠 **Felépítés**

- **Elfelejtett jelszó screen**: Az első képernyőn a felhasználó megadja a regisztrált email címét. A rendszer a `FirebaseAuth.sendPasswordResetEmail` hívással e‑mailt küld, amely tartalmazza a jelszó-visszaállító linket【471745219585009†L11-L38】.
- **Megerősítő screen**: Sikeres e‑mailküldés után megjelenő egyszerű képernyő, amely tájékoztatja a felhasználót, hogy ellenőrizze postafiókját. Innen nincs visszalépés a login képernyőre, a varázsló a linkig lezár.
- **Jelszó-visszaállító screen**: A felhasználó a kapott linkre kattintva egy deep link által megnyitott képernyőre jut. Itt megadja az új jelszót, majd a `confirmPasswordReset()` metódus segítségével véglegesíti azt, a linkből kapott `oobCode` és `mode` paraméterek ellenőrzése után【471745219585009†L11-L38】.

📄 **Kapcsolódó YAML fájlok**

- `fill_canvas_forgot_password_revamp.yaml` – rögzíti a részletes funkcionalitást, tesztelési célokat és CI követelményeket【471745219585009†L7-L16】.

🐞 **Fixek és tanulságok**

A modul célja a felhasználók jelszó-visszaállításának teljes lefedése, ezért külön fixeket nem tartalmaz. Kiemelten fontos a biztonság: az új jelszónak legalább 6 karakter hosszúnak kell lennie, és nem egyezhet meg a korábbi jelszóval【471745219585009†L47-L49】.

🧪 **Tesztállapot**

A specifikáció hangsúlyozza, hogy a jelszó‑visszaállítás minden lépését fedezzék unit és widget tesztek:

- helyes és helytelen email formátumok kezelése,
- sikeres emailküldés és hibaüzenetek,
- deep link paraméterek (`oobCode`, `mode`) ellenőrzése,
- jelszómezők validációja és a jelszó sikeres frissítése【471745219585009†L35-L43】.

📎 **Modul hivatkozások**

- Kapcsolódik az [AuthProvider modulhoz](../modules/auth_provider.md), amely a Firebase hívásokat végzi.
- A login képernyőn (lásd [Login Screen](login_screen.md)) érhető el a „Elfelejtettem a jelszavam” link.

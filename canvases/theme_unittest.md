# Theme rendszer unit-tesztek (ThemeBuilder, ThemeService, BrandColors)

---

🎯 **Funkció**

A unit-tesztek célja, hogy automatikusan ellenőrizzék az új színséma-architektúra fő funkcióit: ThemeBuilder helyes működését, ThemeService state logikáját, BrandColors ThemeExtension elérhetőségét és bővíthetőségét. A tesztlefedettség kiemelt minőségi kapu: legalább 90% coverage szükséges minden theme-kapcsolódó modulra.

---

🧠 **Fejlesztési részletek**

- Hozz létre tesztfájlokat a következő helyeken:
  - `test/theme/theme_builder_test.dart` – ThemeBuilder működés tesztje (helyes ThemeData generálás, scheme/dark mode/BrandColors kezelés)
  - `test/services/theme_service_test.dart` – ThemeService state logika tesztje (váltás, rebuild, értesítés)
  - `test/theme/brand_colors_test.dart` – BrandColors ThemeExtension példányosítás, value-teszt, bővítés, elérés widgetből
- A tesztek fedjék le a fő state-váltásokat: scheme változtatás, dark/light mód, ThemeExtension bővíthetőség, skin preview működés.
- Használj mock/stub widgetet, hogy Theme.of(context)-ből ellenőrizd a ThemeExtension elérhetőségét.
- A teljes tesztkészlet CI-ben 100% zölden fusson, minden branch-en.

---

🧪 **Tesztállapot**

- Minden theme-funkciót érintő unit- és widget-teszt legalább 90%-os coverage-t ad.
- Tesztek minden skin, mód, theme state kombinációt érintenek.
- Sikertelen vagy hiányzó tesztre a CI blokkolja a merge-t.

---

🌍 **Lokalizáció**

- A tesztelés nem tartalmaz lokalizálandó szöveget.
- Amennyiben skin nevek lokalizálása szükséges, a kapcsolódó fájlokat stubold/mockold.

---

📎 **Kapcsolódások**

- **ThemeBuilder**: theme_builder_test.dart
- **ThemeService**: theme_service_test.dart
- **BrandColors**: brand_colors_test.dart
- **CI pipeline**: automata tesztfutás minden branch-en.

---

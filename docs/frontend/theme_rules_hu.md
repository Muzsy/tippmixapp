# 🎨 Témakezelési szabályok (HU)

Ez a dokumentum a TippmixApp alkalmazásban használt témakezelési szabályokat és színpalettát rögzíti.

---

## 🎯 Dizájn célok

- Material 3 + FlexColorScheme használata
- Konzisztens világos/sötét témák
- Könnyen cserélhető színpaletta

---

## 🎨 Használt technológia

- `flex_color_scheme` csomag (Material 3)
- `ThemeService` kezeli a téma váltást
- Központi konfigurációban történik a téma definiálása

---

## 🌈 Színek

- `BrandColors` osztály tartalmazza
- Elérési út: `lib/constants/colors.dart`
- Példa:

```dart
class BrandColors {
  static const Color primary = Color(0xFF016D3D);
  static const Color secondary = Color(0xFF49B67D);
  static const Color accent = Color(0xFFE4F3EC);
}
```

---

## 🧠 Ajánlások

- Ne használj hardcoded színeket widgetekben
- Használd: `Theme.of(context).colorScheme.*`
- Téma mód váltásához `ThemeService` ajánlott
- Ne írj felül globális témát belső widgeteknél
- Adj színneveknek szemantikus nevet (`primary`, `error`, `surface`, stb.)

---

## 🧪 Tesztelési elvárások

- Golden tesztek kötelezőek világos és sötét módhoz is
- Accessibility kontrasztvizsgálat javasolt

# T11 – BadgeScreen widget‑teszt vászon

## Cél

Ellenőrizni, hogy a **BadgeScreen** (lib/screens/badges/badge\_screen.dart) helyesen jelenik meg és működik a következő szempontok szerint:

* dinamikus grid (badge‑ikonok száma, üres állapot)
* szűrő (All / Owned / Missing) működése
* részletező modal + (később) Hero animáció indítása
* 3 nyelvű lokalizáció (en, hu, de)
* stabil scroll magatartás (kis–nagy badge‑szám mellett is)

---

## Környezet

* **Flutter**: stable (≥ 3.22)
* **flutter\_test** & **riverpod** mockok
* `ProviderScope`‑on belül a **userBadgesProvider** felülbírálása (Stream mock)
* locale váltáshoz az `AppLocalizations` bevezetése (`supportedLocales`‑ből)

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [userBadgesProvider.overrideWith((_) => mockStream)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const BadgeScreen(),
    ),
  ),
);
```

---

## Tesztesetek

| ID    | Leírás                 | Előkészítés                                              | Elvárt eredmény                                                   |
| ----- | ---------------------- | -------------------------------------------------------- | ----------------------------------------------------------------- |
| TC‑01 | **Grid megjelenítése** | `controller.add(['badge_rookie'])` → `pump()`            | Megjelenik a `BadgeGridView`, benne rookie ikon                   |
| TC‑02 | **Üres állapot**       | `controller.add([])`                                     | Látó az `loc.noBadgesYet` szöveg                                  |
| TC‑03 | **Szűrő – Missing**    | 1) Owned = `[rookie]`<br>2) Szűrő legördítőből „Missing” | Csak a hiányzó badge‑ek listája jelenik meg                       |
| TC‑04 | **Szűrő – All**        | ugyanaz, szűrő „All”                                     | Minden badge megjelenik                                           |
| TC‑05 | **Modal megnyitás**    | Tap egy badge‑re                                         | Felugró `BadgeDetailDialog` (nincs implementálva → `expect` skip) |
| TC‑06 | **Hero animáció**      | (későbbi) Tap + navigáció `BadgeDetailPage`              | `find.byType(Hero)` működik, animáció lefut                       |
| TC‑07 | **Lokalizáció – HU**   | locale = `Locale('hu')`, owned = `[]`                    | Grid cím, filter címkék, empty‑state szöveg magyarul              |
| TC‑08 | **Lokalizáció – DE**   | locale = `Locale('de')`                                  | Feliratok németül                                                 |
| TC‑09 | **Scroll stabilitás**  | 100+ badge dummy a streamben → vertikális scroll         | Nem dob Exception‑t / overflow‑t                                  |

> **Megjegyzés**: TC‑05 és TC‑06 egyelőre *skip* jelöléssel kerülnek a tesztfájlba, mert a dialógus + Hero még nincs a kódbázisban. A teszt‐vázakat előre legeneráljuk a Codex‑szabályok szerint.

---

## Dene of Definition (DoD)

* Fentiekhez tartozó tesztesetek futnak **CI**‑ben (`flutter test`) zölden
* Teszt‐coverage ≥ 90 % a `BadgeScreen`, `BadgeGridView` és kapcsolódó helper függvényekre
* NINCS `debugPrint`, nem szivárog konzolra
* Aranykép (golden) regression‑t **nem** használjuk – csak widget assert
* a `goals/fill_canvas_badge_screen_test.yaml` a Codex‐szabályfájlokkal validálható (`yaml lint` OK)

---

## Nyitott kérdések

1. A részletező dialógus UI‑követelményei? (title, long desc, progressbar?)
2. Hero animáció pontos flow‑ja: badge‑ikontól a dialógus képéig, vagy külön details screen?
3. Badge‑ikon sprite vs. egyedi asset? (Behatárolja a golden‑teszt igényt.)

---

## Hivatkozások

* badge\_screen.dart, badge\_grid\_view\.dart – **lib/**
* userBadgesProvider – **lib/screens/badges/badge\_screen.dart**
* `test/screens/badge_screen_test.dart` meglévő két teszt (bővítendő)
* Sprint5 Docs: **Sprint5 Progress Overview2.pdf**, **Audit 2025‑06‑26.pdf**

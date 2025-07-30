# 🧪 Golden tesztelés és akadálymentesítés (HU)

Ez a dokumentum bemutatja a TippmixApp vizuális (golden) tesztelési és hozzáférhetőségi (a11y) munkafolyamatait.

---

## 🖼️ Golden tesztek

A golden tesztek képernyőképet készítenek a widgetről, és összehasonlítják a referenciával.

### Eszközök

* `flutter_test` + `matchesGoldenFile()` használata
* Tesztfájlok: `test/golden/`
* Referencia képek: `test/golden/_goldens/`

### Munkamenet

1. Készíts widget tesztet
2. Állítsd fix méretre a widgetet
3. Hasonlítsd össze a golden képpel

```dart
testWidgets('ProfileHeader golden test', (tester) async {
  await tester.pumpWidget(MyApp());
  await expectLater(
    find.byType(ProfileHeader),
    matchesGoldenFile('goldens/profile_header.png'),
  );
});
```

### Szabályok

* Mind világos, mind sötét témát tesztelj
* Külön fájlok: `*_light.png`, `*_dark.png`
* Kerüld a dinamikus tartalmakat (pl. időbélyeg)

---

## ♿ Akadálymentesség (a11y)

A TippmixApp célja az alapvető akadálymentes megfelelés.

* Fontos elemekhez `Semantics()` használata
* `Text()` widgeteknél megfelelő kontraszt
* Egyedi elemek (gombok, ikonok) kapjanak tooltipet vagy leírást

### Eszközök

* `flutter_test` támogatja az alap semantics ellenőrzést
* Golden tesztek futtathatók `accessibilityChecksEnabled: true` opcióval

### Terv

* `accessibility_test` csomag bevezetése
* CI pipeline-ban akadálymentességi ellenőrzés

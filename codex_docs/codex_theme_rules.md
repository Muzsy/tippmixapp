# 🛡️ Codex Szabályfájl – TippmixApp Színséma Logika

---

## **Alapelvek**

1. **Csak FlexColorScheme alapú paletta használható**  
   - Az alkalmazás kizárólag a FlexColorScheme csomag előre definiált vagy golden/accessibility-auditált egyedi palettáiból választhat.
   - Nincs helye hardcoded hex, rgb, hsl vagy egyéb manuális színnek widgetekben vagy ThemeData-ban.
   - Minden paletta Material 3-kompatibilis, dark/light módra optimalizált.

2. **Előre definiált skin-választék**  
   - A felhasználó a Beállítások képernyőn csak a project által engedélyezett (tesztelt, auditált) FlexColorScheme skinek közül választhat.
   - Minden skin index/név és preview alapján jelenik meg, és lokalizálható.

3. **ThemeService logika**  
   - Skin-váltás, mentés, visszatöltés kizárólag ThemeService-en keresztül.
   - Widgetek közvetlenül nem férhetnek hozzá színekhez, csak Theme.of(context).colorScheme.* vagy ThemeExtension-on keresztül.

4. **Skin mentése és visszatöltése**  
   - Kiválasztott skin index/név a felhasználói profilban (Firestore) vagy local storage-ban tárolódik.
   - App indításkor az utoljára választott skin automatikusan aktiválódik.

5. **CI pipeline és tesztelés**
   - Új skin csak akkor kerülhet be, ha minden pipeline teszten (golden, accessibility, linter) átmegy.
   - Minden skin garantáltan AA-szintű kontraszttal, teljes golden screenshot diff-tel és accessibility audittal validált.

6. **Hardcoded színhasználat tilos**
   - Minden manuális színreferenciát, hex, rgb stb. tilos! Linterrel, Codex auditálással kötelezően tiltható.
   - Csak a theme színeit szabad használni: Theme.of(context).colorScheme.* vagy ThemeExtension.

7. **Bővítés és kampánylogika**
   - Új skin hozzáadásához csak az availableThemes listát kell bővíteni, minden új skin kötelezően végigmegy a pipeline-on.
   - Kampány/brand skin ideiglenesen is beadható, ha megfelel minden előírásnak.

8. **Lokalizáció**
   - Skin nevek, leírások és previewk minden platformon lokalizálhatók.
   - Színséma-váltás a felhasználói élményen kívül más funkciót (pl. adatlogika, jogosultság, workflow) nem befolyásolhat.

---

## **Kötelező érvényű workflow lépések**

1. **Skin-váltás kizárólag a ThemeService felületén keresztül!**
2. **Widgetek kizárólag a theme-ből származó színekkel dolgozhatnak!**
3. **Minden új skin golden és accessibility pipeline-on validálva kell legyen!**
4. **Felhasználó csak az előre definiált palettákból választhat (egyéni színválasztás nem engedélyezett, kivéve ha előre auditált)!**
5. **Skin index/név minden platformon lokalizálható, és csak CI által jóváhagyott skin kerülhet be!**

---

**Ez a szabályfájl minden Codex-alapú színséma módosításhoz vagy generált kódhoz kötelezően alkalmazandó!  
A szabályfájl a /codex_docs könyvtárban helyezendő el.**


## 🧾 educational\_tips.json

### 🎯 Funkció

Ez a fájl tartalmazza az edukációs célú tippeket, amelyeket a TippmixApp főképernyőjén a `HomeTileEducationalTip` csempe jelenít meg. A cél, hogy tanácsokat és hasznos tudnivalókat közvetítsen a fogadási alapokról, kezdők számára.

### 📁 Fájlútvonal

```
lib/assets/educational_tips.json
```

### 🧠 Formátum

A fájl egy `tips` tömböt tartalmaz, ahol minden tipp egy `id` és lokalizált nyelvi kulcsokból áll:

```json
{
  "tips": [
    {
      "id": "tip_1",
      "hu": "Kombinált fogadással magasabb oddsszal nyerhetsz.",
      "en": "With combo betting, you can win with higher odds.",
      "de": "Mit Kombiwetten kannst du höhere Quoten erzielen."
    },
    {
      "id": "tip_2",
      "hu": "Egyes fogadással kisebb a kockázat – kezdőknek ajánlott.",
      "en": "Single bets are safer – ideal for beginners.",
      "de": "Einzelwetten sind risikoärmer – ideal für Anfänger."
    }
  ]
}
```

### 🔁 Betöltés logika

A csempéhez tartozó widget betölti a JSON fájlt a `rootBundle.loadString()` segítségével, és véletlenszerűen kiválaszt egy tippet az aktuális AppLocalizations nyelve szerint.

### 📎 Kapcsolódások

* Widget: `HomeTileEducationalTip`
* Lokalizáció nem ARB fájlon keresztül, hanem JSON alapján nyelvenként
* Támogatja a könnyű bővítést és akár szerveroldali frissítést is

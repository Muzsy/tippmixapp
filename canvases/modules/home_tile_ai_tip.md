## 🤖 AI tipp csempe modul

### 🎯 Funkció

Ez a csempe a mesterséges intelligencia által javasolt legvalószínűbb napi tippet jeleníti meg a főképernyőn, hogy irányt mutasson a kevésbé tapasztalt felhasználóknak【65885556010431†L2-L6】.

### 🧠 Fejlesztési részletek

- A csempe egy mondatos AI ajánlást jelenít meg, például: „AI szerint ma a Bayern győzelme a legvalószínűbb (78%).”【65885556010431†L8-L13】.
- A háttérben az `AiTipProvider` szolgáltatás biztosítja az adatot, amely figyelembe veszi a csapatformát, statisztikákat és odds‑mozgást【65885556010431†L11-L13】.
- A csempe gombot is tartalmazhat: „Részletek megtekintése”, amely az AI ajánló részletező képernyőre navigál【65885556010431†L12-L13】.
- Ha nincs elérhető AI tipp, a csempe nem jelenik meg【65885556010431†L13-L14】.

### 🧪 Tesztállapot

- Unit teszt: az `AiTipProvider` logika helyessége (például, hogy naponta legfeljebb egy ajánlás adható)【65885556010431†L15-L18】.
- Widget teszt: a csempe csak akkor renderelődik, ha van tipp【65885556010431†L17-L19】.
- Interakció: a részletek gomb navigációját tesztelni kell【65885556010431†L17-L20】.

### 🌍 Lokalizáció

A csempe kulcsai: `home_tile_ai_tip_title`, `home_tile_ai_tip_description`, `home_tile_ai_tip_cta`【65885556010431†L21-L28】.

### 📎 Kapcsolódások

- `AiTipProvider` – a tipp szolgáltatója【65885556010431†L32-L33】.
- Navigáció – az AI tipp részletező képernyő (opcionális).
- HomeScreen – feltételes megjelenítés a főképernyőn【65885556010431†L32-L35】.
- Codex szabályfájlok: `codex_context.yaml`, `localization_logic.md`, `priority_rules.md`, `service_dependencies.md`【65885556010431†L36-L40】.
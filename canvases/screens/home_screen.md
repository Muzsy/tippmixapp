# 🏠 Home képernyő (HomeScreen)

Ez a vászon a TippmixApp főoldalának összefoglalója.  A **Home képernyő** dinamikus, csempézett elrendezésben jeleníti meg a legfontosabb statisztikákat, jutalmakat és ajánlásokat, hogy a felhasználó már a belépéskor áttekintést kapjon a számára releváns információkról.

## 🎯 Funkció

Az új Home képernyő célja, hogy a korábbi statikus listát vizuálisan vonzó, interaktív csemperendszerrel váltsa le.  A `home_screen_refactor.md` vászon alapján a fő funkciók a következők:

- **Statisztikák és rangsor** – a felső szekcióban megjelenik az avatar, TippCoin egyenleg, win‑ratio és helyezés a ranglistán【464063698324409†L8-L12】.
- **Dinamikus csempék** – a fő tartalom egy GridView alapú elrendezés, amely csempéken jeleníti meg a napi bónuszt, AI‑alapú tippeket, legújabb badge‑eket, feed aktivitásokat és kihívásokat【464063698324409†L8-L17】.
- **Állapotfüggő megjelenés** – a csempék csak akkor jelennek meg, ha a kapcsolódó szolgáltatások aktív adatot adnak vissza (pl. van aktív kihívás vagy elérhető napi bónusz)【464063698324409†L15-L18】.

## 🧠 Felépítés

A Home képernyő modulárisan épül fel.  A fejrészt a `UserStatsHeader` widget alkotja, alatta pedig egy rugalmas rács foglal helyet, amely önálló modulokra bontott csempéket tartalmaz.  Ezek a csempék elkülönített modulvászonként szerepelnek a `canvases/modules/` könyvtárban.  A legfontosabb modulok:

- **Napi bónusz csempe** (`home_tile_daily_bonus.md`) – megjeleníti, hogy elérhető‑e az aznapi TippCoin jutalom, és begyűjthető gombot kínál【674288901791015†L2-L14】.
- **AI tipp csempe** (`home_tile_ai_tip.md`) – egy mesterséges intelligencia által javasolt, magas valószínűségű tippet jelenít meg, amely irányt mutat a felhasználónak【65885556010431†L2-L13】.
- **Top tipster csempe**, **Feed aktivitás**, **Badge elnyerés** – további csempék, amelyek a felhasználói aktivitásról, klubstátuszról és jutalmakról adnak visszajelzést.

A csempék Riverpod/Provider alapú állapotfigyeléssel frissülnek, a CoinService, BadgeService, FeedService, AiTipProvider és egyéb modulok adataira építve【464063698324409†L31-L36】.

## 📄 Kapcsolódó YAML fájlok

- `codex/goals/fill_canvas_home_screen.yaml` – a Home képernyő Codex‑utasításainak generálása.
- `codex/goals/fix_home_screen_showstats.yaml`, `codex/goals/fix_home_screen_showgrid.yaml` – korábbi hibajavítások.
- Egyéb, a Home képernyőt érintő fix vagy funkció YAML fájlok a `codex/goals/` könyvtárban találhatók (pl. sprinthez kötött dinamikus témák).

## 🐞 Fixek és tanulságok

Több vászon foglalkozik a Home képernyő hibáival; ezeket archiváltuk a `canvases/_archive/fixes/` mappában.  Ilyenek például a `fix_home_screen_userstatsheader.md` (UserStats fejléc hibája) vagy a `fix_home_screen_showgrid.md` (Grid megjelenítési hiba).  Ezek részletezik a problémát és a megoldás tanulságait.

## 🧪 Tesztállapot

Az új Home képernyőhöz átfogó widget- és integrációs tesztek tartoznak【464063698324409†L13-L18】.  A csempék helyes megjelenését, az interakciókat (pl. napi bónusz begyűjtése) és a feltételes renderelést UI snapshot alapú tesztek vizsgálják.  A lokalizációs kulcsok lefedettségét is ellenőrzik.

## 📎 Modul hivatkozások

Az alábbi modulvásznak kapcsolódnak közvetlenül a Home képernyőhöz (a `canvases/modules/` mappában találhatók):

- `home_tile_daily_bonus.md` – Napi bónusz csempe.
- `home_tile_ai_tip.md` – AI‑alapú tipp csempe.
- `home_tile_top_tipster.md` – Top tipster rangsor csempe.
- `home_tile_feed_activity.md` – Feed aktivitás megjelenítése.
- `home_tile_educational_tip.md` – Oktató jellegű tippek.
- `home_tile_challenge_prompt.md` – Kihívás felhívása.
- `home_tile_badge_earned.md` – Újonnan szerzett badge csempe.

Ezek a modulok önállóan is használhatók és tesztelhetők, valamint további képernyőkbe is integrálhatók.

# BadgeScreen Hero Animáció – Widget Teszt

🎯 Funkció
A BadgeScreen minden badge elemére Hero animáció alkalmazása, amely a badge kártya és a profil/kitüntetés között látványos, smooth átmenetet biztosít. A kapcsolódó widget-teszt (és golden test, ha van) CI-ben is zölden lefut, skip nélkül.

🧠 Fejlesztési részletek
- BadgeCard widgeten Hero wrapper, unique tag-gel (pl. badge.id vagy badge.type).
- Navigáció: badge-re tappolva BadgeDetail vagy Modal nyílik animációval.
- Hero animáció UI/UX visszajelzés alapján finomítva.
- Widget-teszt (pl. test/screens/badge_screen_test.dart): a Hero animáció is tesztelt (pl. aranykép teszt vagy animáció szimuláció).
- Ha korábban skip-elt teszt volt (pl. `@Skip` vagy `skip: true`), ezt feloldani.
- Golden teszt assetek naprakészen, referenciakép(ek) frissítve.

🧪 Tesztállapot
- Widget-teszt CI-ben sikeresen fut, aranykép összehasonlítás (golden test) is zöld.
- Minden branch/PR build zöld, nincs skipelt teszt.
- Animációra vonatkozó assert(ek) a tesztben.

🌍 Lokalizáció
- Az animáció során megjelenő szövegek (pl. badge title) helyesen lokalizáltak minden támogatott nyelven.
- Lokalizációs hiányosság a tesztben visszajelzést ad (pl. assert vagy teszt fail).

📎 Kapcsolódások
- lib/screens/badge_screen.dart (vagy badge_card.dart, badge_detail.dart)
- test/screens/badge_screen_test.dart (és golden assetek)
- Codex canvas + yaml, golden test workflow
- UI/UX feedback (designer)

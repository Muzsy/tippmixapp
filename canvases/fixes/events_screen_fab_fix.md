# Sprint P0 – EventsScreen FAB Bug

## Kontextus

A fogadási eseményeket listázó `EventsScreen`-en a „Szelvény beküldése” (FloatingActionButton) csak akkor jelenne meg, ha a widget **saját** `Scaffold`‑ját építi. A jelenlegi implementáció viszont korán visszatér csupán a `body`‑val, amikor `showAppBar == false` **vagy** ha a hívási hierarchiában már létezik `Scaffold`. Mivel az alkalmazás fő képernyője (`HomeScreen`) maga is `Scaffold`, és az `EventsScreen`‑t többnyire `showAppBar: false` paraméterrel fűzi be, a beküldésre szolgáló FAB így **soha nem jelenik meg**.

## Cél (Goal)

A beküldő gomb mindenkor jelenjen meg, amikor a felhasználó már választott tippeket ( `betSlipProvider.tips.isNotEmpty` ), függetlenül attól, hogy az `EventsScreen` önálló‑e, vagy egy külső `Scaffold`‑ban fut.

## Feladatok

* [ ] Távolítsuk el a korai `return body;` ágakat, amelyek elrejtik a gombot.
* [ ] Építsünk **mindig** `Scaffold`‑ot; az `appBar` legyen `null`, ha `widget.showAppBar` hamis, különben látszódjon.
* [ ] A meglévő `floatingActionButton` kód változatlanul marad, így a gomb megjelenik.
* [ ] Új widget‑teszt: ha legalább **egy** tipp van, a `create_ticket_button` kulcsú FAB megjelenik; ha nincs, nem látható.
* [ ] Nincs szükség l10n vagy egyéb refaktorra.

## Acceptance Criteria / Done Definition

* [ ] A gomb látható, ha ≥1 tipp van kiválasztva bármely sportnézetben.
* [ ] `flutter analyze` hibamentes.
* [ ] Új widget‑teszt zöld, a tesztlefedettség ≥ 80 % marad.
* [ ] A frissítés‑gomb (refresh FAB) működése változatlan.
* [ ] Navigációs regresszió nem lép fel (minden meglévő teszt zöld).

## Hivatkozások

* Canvas → `/codex/goals/events_screen_fab_fix.yaml`
* Issue ID ✏️ #fab‑missing

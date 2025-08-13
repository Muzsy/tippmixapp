# Tippkártya gombsor – egységes „pill” stílus

## 🎯 Funkció

Az alsó három akciógomb (**További fogadások**, **Statisztika**, **AI ajánló**) vizuálisan egységes, kompakt és reszponzív „pill” stílusban jelenjen meg a tippkártyán:

* fix magasság (36–40), azonos tipográfia,
* ikon + felirat, egyforma paddings, kerekített sarkok,
* sor fölött vékony elválasztó (Divider),
* Row-ban három **Expanded** elem, kisméretű közökkel, kis képernyőn törés nélkül.

Cél: letisztult, konzisztens megjelenés, a kártya többi részével harmonizáló UI – a meglévő logika (onTap hívások) változtatása nélkül.

## 🧠 Fejlesztési részletek

**Új, újrahasznosítható komponens:** `ActionPill`

* paraméterek: `icon`, `label`, `onTap`, opcionálisan `selected` (későbbi bővítéshez),
* stílus: `Theme.of(context).colorScheme.secondaryContainer` háttér, 10–12 px corner radius, 1 px halvány keret, `InkWell` vizuális visszajelzéssel,
* belső elrendezés: ikon (16–18) + 8 px hézag + felirat, ellipszis overflow.

**Kártya módosítás:** `event_bet_card.dart`

* a jelenlegi három gomb helyett `Divider` + `Row(children: [Expanded(ActionPill...), ...])` blokk,
* a meglévő callbackek változatlanul beköthetők: `onShowMoreBets`, `onShowStats`, `onShowAIRecommendation` (ami a kódban ténylegesen elérhető; ha eltér a név, a YAML patch a kódban megtalált hívásokra cserél).

**Hozzáférhetőség:**

* `Semantics(button: true, label: ...)` a `ActionPill` köré,
* min. tappable area 40 logical pixel magasság.

**Teljesítmény:**

* egyszerű, Material-kompat komponens; nincs extra csomag, nincs képtöltés.

## 🧪 Tesztállapot

* Widget teszt: az `EventBetCard` rendereli a három gombot, a feliratok megtalálhatók,
* Tap teszt: mindhárom pill meghívja a kapott callbacket (mockolva).

## 🌍 Lokalizáció

* Új szöveg **nincs**: a meglévő feliratokat használjuk (HU/EN/DE már megvan a projektben). Ha mégis kulcsokból kell olvasni, a következő i18n vászonban elkülönítve intézzük.

## 📎 Kapcsolódások

* `lib/widgets/event_bet_card.dart` – gombsor szakasz
* `lib/widgets/action_pill.dart` – **új** közös widget
* (opcionális) későbbi stílusegységesítéshez ugyanilyen komponens más listakártyákon is használható

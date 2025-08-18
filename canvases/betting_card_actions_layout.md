# Tippkártya – Alsó akciógombok újrarendezése

## 🎯 Funkció

A H2H kártya alsó három akciógombjának ("További fogadások", "Statisztika", "AI tippek") UI‑javítása:

* **Hierarchia**: felül egy **elsődleges**, teljes szélességű gomb – „További fogadások”.
* **Másodlagos akciók**: alatta két kisebb gomb egymás mellett – „Statisztika”, „AI tippek”.
* **Ikon + szöveg** mindhárom gombon. A meglévő pill‑stílus megmarad.

## 🧠 Fejlesztési részletek

* **Érintett fájl**: `lib/widgets/event_bet_card.dart`
* **Változás lényege**: az eddigi egy sorban elhelyezett három gomb helyett oszlopos elrendezés (Column):

  1. első sor: teljes szélességű „További fogadások”,
  2. második sor: `Row` két `Expanded` gombbal – „Statisztika” és „AI tippek”.
* **Visszafelé kompatibilis**: a callbackek (további piacok, statisztika, AI ajánló) nem változnak, csak az elrendezés.
* **Ikonok**: `Icons.more_horiz`, `Icons.bar_chart`, `Icons.smart_toy`.

## 🧪 Tesztállapot

* Widget snapshot: a gombsor új elrendezése (full‑width + 2× half‑width) helyesen renderel.
* Interakció: a három onTap callback változatlanul működik.

## 🌍 Lokalizáció

* Új kulcs nem szükséges – a meglévő feliratok maradnak (HU/EN/DE fordításokkal, ha már léteznek).

## 📎 Kapcsolódások

* Kapcsolódik: `canvases/betting_page_uiux_polish.md` (kártya UI finomítások).

# 📈 Odds drift figyelmeztetés (HU)

Ez a dokumentum a jegy véglegesítése előtti figyelmeztető párbeszédablakot írja le, amely jelzi, ha a kiválasztott tippek oddsa megváltozott.

## 📝 Áttekintés

- Összehasonlítja a korábbi `oddsSnapshot` értékeket az ApiFootballService friss oddsaival.
- Ha az eltérés meghaladja a konfigurálható küszöböt, a dialog felsorolja a változásokat.
- A felhasználó elfogadhatja az új oddsokat vagy megszakíthatja a fogadást.

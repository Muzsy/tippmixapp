# Lokalizációs audit és automatikus javítás (Sprint5)

🎯 **Cél:**  
A projekt teljes lokalizációs lefedettségének automatikus biztosítása.  
- Hiányzó vagy üres fordítási kulcsok minden ARB fájlban (hu, en, de) legyenek pótolva.
- Minden hardcoded (nem lokalizált) string legyen kiváltva lokalizációs kulccsal.
- Ahol a javítás automatikusan nem egyértelmű, azt “TODO” vagy “FIXME” kommenttel naplózd és ne módosítsd magától!
- A teljes folyamat naplózott legyen: minden változtatás, skip, hibás vagy emberi döntést igénylő eset külön listázva.
- Csak a ténylegesen létező projektfájlokra dolgozz, semmit ne találj ki!

## 🧠 **Módszertan**
- ARB és forráskód diff: minden kulcs három nyelven egyezzen.
- Hardcoded stringek keresése: csak a lib/ és widget/ alatt.
- Automatikus pótlás, ahol biztosan egyértelmű, különben naplózás “TODO”-val.

## 🧪 **Tesztállapot**
- CI pipeline futtatása, coverage + linter ellenőrzés, hardcoded stringek újraellenőrzése.

## 📎 **Naplózás**
- Külön fájl(ok)ba írd ki a teljes változáslistát, és az összes “TODO”/“FIXME” problémát is.

---

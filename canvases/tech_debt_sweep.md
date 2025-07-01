# Tech-debt sweep – fejlesztői adósságok felszámolása (Sprint5)

🎯 **Cél:**  
A teljes projektben minden fejlesztői “adósság” (linter warning, debugPrint, nem használt kód, skipelt golden teszt, félbehagyott TODO) felszámolása, naplózással.

🧠 **Fejlesztési részletek:**  
- Automatikus linter/fixer futtatása minden forrás- és tesztfájlon
- Felesleges debugPrint-ek eltávolítása
- Nem használt kódok, változók, importok törlése
- Golden tesztek un-skip, snapshot frissítés
- Minden módosítás naplózása, külön TODO lista, amit nem lehet automatikusan javítani

🧪 **Tesztállapot:**  
- CI/linter zöld minden branch-en
- Nincs skipelt golden teszt
- Nincs debugPrint vagy warning

📎 **Kapcsolódó fájlok:**  
- lib/, test/
- .github/workflows/ci.yaml
- golden snapshot fájlok

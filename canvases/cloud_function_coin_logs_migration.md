# Cloud Function migráció a coin_logs naplózásához (Sprint5)

🎯 **Cél:**  
Minden TippCoin mozgás (debit/credit) kizárólag szerveroldali Cloud Function-ön keresztül legyen naplózva a coin_logs kollekcióban, kliensoldali írás kizárva.

🧠 **Fejlesztési részletek:**  
- Új Cloud Function: paraméterezett naplózás
- Kliensoldali refaktor: minden logolás function hívás
- Firestore rules: csak function írhat
- Teljes körű tesztelés
- Dokumentáció frissítés

🧪 **Tesztállapot:**  
- Minden írás function útvonalon
- Hibás vagy jogosulatlan hívás = nincs írás
- Teljes naplózás, CI teszt

📎 **Kapcsolódó fájlok:**  
- cloud_functions/coin_logs_write.js (vagy ts)
- lib/services/coin_service.dart
- firebase.rules
- tesztfájlok, devdoc

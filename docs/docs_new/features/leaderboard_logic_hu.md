# 🏆 Ranglista logika (HU)

Ez a dokumentum a TippmixApp ranglista (leaderboard) funkciójának működését és tervét írja le.

---

## 🎯 Célja

* TippCoin alapján sorrendbe tenni a felhasználókat
* Növelni a motivációt és versengést
* Alapja lehet badge-eknek és jutalmaknak (később)

---

## 📊 Rendezés logika

* TippCoin egyenleg alapján csökkenő sorrend
* Holtverseny esetén: korábbi regisztráció előrébb

---

## 📁 Firestore struktúra

Javasolt kollekció:

```
leaderboard/{uid} → LeaderboardEntry
```

Példa modell:

```json
{
  "uid": "abc123",
  "displayName": "PlayerX",
  "tippCoin": 3150,
  "rank": 5,
  "avatarUrl": "..."
}
```

* Periodikusan generálható (pl. Cloud Function)
* Kerülendő a valós idejű újrarendezés (lassú lehet)

---

## 🔁 Frissítési stratégia

* TippCoin változásnál frissítjük a cache-t
* Teljes ranglista naponta újraszámolva
* Top 100 felhasználó mentése `leaderboard/` kollekcióba
* Saját rang lekérhető cloud function segítségével (opcionális)

---

## 📌 Megjelenítés

* `LeaderboardScreen`: top 10 lista
* Profil: saját rang megjelenítése (ha nincs a top10-ben is)
* Saját user kiemelve a listában

---

## 🧪 Tesztelés

* Snapshot teszt: lista UI
* Unit teszt: rendezési logika
* Integrációs teszt: rank frissülés validálása

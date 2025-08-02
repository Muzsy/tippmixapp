# 📰 Feed modul terv (HU)

Ez a dokumentum a TippmixApp közösségi feed moduljának felépítését és működését írja le.

---

## 🎯 Célja

- Megjeleníteni a legfrissebb nyilvános felhasználói aktivitásokat
- Növelni az alkalmazás közösségi élményét
- Inspirációt és mintát adni új usereknek

---

## 📋 Mi kerül bele a feedbe?

- Fogadás megtétele (szelvény kivonat)
- Nyeremény (szelvény nyert)
- Új badge szerzése

---

## 📁 Javasolt Firestore struktúra

```
feed_events/{eventId}
```

```json
{
  "type": "ticket_placed" | "ticket_won" | "badge_earned",
  "userId": "abc123",
  "displayName": "PlayerX",
  "timestamp": "...",
  "payload": { ... }
}
```

- Csak nem érzékeny adatokat tároljunk
- Figyelni kell az adatméretre (Firestore kvóta)

---

## 🔁 Feed generálás

- Trigger: szelvény beküldés, szelvény eredmény, badge szerzés
- Cloud Function adja hozzá a `feed_events` kollekcióhoz
- Opcionális: időzített törlés (max. 7–14 nap tárolás)

---

## 🧠 UI terv

- `HomeScreen`: függőleges feed lista
- Kártyatípusok:

  - TicketPlacedCard
  - TicketWonCard
  - BadgeEarnedCard
- Felhasználónév lehet anonimizált vagy `displayName`
- Profilkép megjelenhet, ha elérhető

---

## 🧪 Tesztelés

- Widget tesztek kártyákhoz
- Lista görgetési teszt (virtuális lista)
- Mock Firebase lekérdezés integrációs teszt

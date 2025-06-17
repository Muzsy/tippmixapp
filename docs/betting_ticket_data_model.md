# 🎟️ TippmixApp – Szelvény (Ticket) és Több Tipp (Bet) Adatmodell

## 1. Adattárolási szint (Firestore + BigQuery)

- **Firestore:** aktuális, élő szelvények gyors eléréséhez, felhasználói feedhez.
- **BigQuery:** historikus szelvények, analitika, AI-elemzés, teljes fogadástörténet.

---

## 2. Szelvény (Ticket) – Bővíthető, többelemes logikai modell

```json
{
  "ticket_id": "user123_20250820_001",
  "user_id": "user123",
  "bets": [
    {
      "match_id": "oddsapi123",
      "bookmaker": "bet365",
      "market_key": "h2h",
      "selection": "Arsenal",
      "odd": 2.10,
      "status": "pending",     // won/lost/void
      "evaluated_at": null
    },
    {
      "match_id": "oddsapi124",
      "bookmaker": "bet365",
      "market_key": "over_under",
      "selection": "Over",
      "odd": 1.85,
      "point": 2.5,
      "status": "pending"
    }
  ],
  "stake": 100,
  "potential_win": 388.5,
  "created_at": "2025-08-20T19:55:00Z",
  "status": "pending",      // pending/won/lost/void
  "evaluated_at": null,
  "result": null
}
```

### ⚙️ Logika

- **Egy szelvényen tetszőleges számú tipp lehet** (`bets` tömb).
- **Minden bet külön-külön kiértékelhető**.
- **A szelvény össz-státusza**:
  - "won": minden bet "won"
  - "lost": bármelyik bet "lost"
  - "void": ha van void és nincs lost (üzleti szabály szerint)
- **Bővíthető kombi, rendszer vagy single szelvényekhez.**

---

## 3. Kiértékelési folyamat

- Esemény lezárásakor minden érintett bet státusza frissül a ticketen belül.
- Ticket státusza a fenti logika szerint frissül.
- AI/analitika számára minden bet külön is kereshető, de az egész ticket aggregálható.

---

## 4. Bővíthetőség

- Kombinált szelvényekhez csak a ticket aggregáló logikán kell bővíteni.
- Rész-kifizetés (cashout), rendszer fogadás, egyéb piacok támogatása csak a bets tömb bővítését vagy logikáját igényli.

---

## 5. Részletes magyarázat (miért ez a modell?)

Ez a modell tökéletesen tükrözi a valódi fogadási rendszerek működését:

- Egy szelvény egyedi, a felhasználóhoz, időponthoz kötött.
- Több tipp (bet) – mindegyik saját eseményre, piacra, bookmakerre mutat.
- A szelvény össz-státusza nem lehet "won", amíg minden bet le nem zárult; ha egy "lost", a ticket is az.
- Mobilon, Firestore-ban gyorsan lekérdezhető, BigQuery-ben is könnyen aggregálható.
- Tetszőleges piac, sport, bookmaker hozzáadható – bármikor új tipp vagy piac bevezethető modellváltás nélkül.
- Jövőbeli fejlesztésnél támogatott: rész-kifizetés (cashout), rendszer-fogadás, komplex odds-összegzés.

Ez a struktúra hosszú távon biztosítja a bővíthetőséget, auditálhatóságot, fejlesztőbarát és AI/elemzésre is kész.


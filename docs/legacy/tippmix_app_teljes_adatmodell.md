# 📊 TippmixApp – Teljes Adatmodell (Firestore + BigQuery)

## 1. Fogadási adatok

### A) Esemény (Match/Event) – Firestore: `matches/{match_id}`

```json
{
  "match_id": "oddsapi123456",
  "sport_key": "soccer_epl",
  "sport_title": "Premier League",
  "commence_time": "2025-08-21T20:00:00Z",
  "home_team": "Arsenal",
  "away_team": "Liverpool",
  "league": "Premier League",
  "status": "NS",
  "venue": { "name": "Emirates Stadium", "city": "London" },
  "bookmakers": [
    {
      "key": "bet365",
      "title": "Bet365",
      "last_update": "2025-08-20T19:50:00Z",
      "markets": [
        {
          "key": "h2h",
          "last_update": "2025-08-20T19:50:00Z",
          "outcomes": [
            { "name": "Arsenal", "price": 2.10 },
            { "name": "Draw", "price": 3.40 },
            { "name": "Liverpool", "price": 3.00 }
          ]
        },
        {
          "key": "over_under",
          "point": 2.5,
          "last_update": "2025-08-20T19:50:00Z",
          "outcomes": [
            { "name": "Over", "price": 1.95 },
            { "name": "Under", "price": 1.85 }
          ]
        }
      ]
    }
  ]
}
```

- Firestore-ban csak az aktív események élnek.
- BigQuery-ben historikus táblák:
  - `matches`, `markets`, `outcomes`, `results`, `features` (külön oszlopokkal, szabványos kulcsokkal).

---

### B) Szelvény + Több Tipp (Ticket, Bet) – Firestore: `tickets/{ticket_id}`

Lásd: külön vászon "Betting Ticket Data Model"

---

## 2. Felhasználói adatok

### A) Profil Firestore: `users/{uid}`

```json
{
  "uid": "user123",
  "nickname": "ProTippelő",
  "avatarUrl": "...",
  "createdAt": "2025-01-01T12:00:00Z",
  "country": "HU",
  "city": "Budapest",
  "language": "hu",
  "verified": true,
  "twoFactorAuthEnabled": false,
  "isPrivate": false,
  "coins": 1000,
  "badges": ["top10", "ai_supporter"],
  "level": 7,
  "rankTitle": "Profi",
  "tipsSubmitted": 243,
  "ticketsPlayed": 70,
  "winRate": 0.72,
  "streak": 9,
  "maxOddsWon": 14.2,
  "positiveLikes": 51,
  "negativeLikes": 7,
  "followersCount": 80,
  "friendsCount": 10,
  "favoriteSports": ["football", "tennis"],
  "favoriteTeams": ["Barcelona"],
  "notificationPreferences": {
    "tips": true,
    "friendActivity": false
  }
}
```

- Csak aggregált mezők.
- Történeti, nagy adathalmaz (pl. tranzakciók, badge események, versenyek) → BigQuery, vagy külön kollekció.

---

### B) Felhasználói történelem, kapcsolatok – BigQuery táblák

| Tábla              | Fő mezők                                 | Megjegyzés                      |
| ------------------ | ---------------------------------------- | ------------------------------- |
| `transactions`     | user\_id, type, amount, timestamp, meta  | Coin műveletek, badge, vásárlás |
| `badge_events`     | user\_id, badge\_id, timestamp, type     | Badge megszerzés/vesztés        |
| `tournament_stats` | user\_id, tournament\_id, rank, score    | Tippverseny eredmények          |
| `follows`          | user\_id, followed\_id, timestamp        | Követések, barátok              |
| `forum_posts`      | user\_id, post\_id, content, created\_at | Közösségi aktivitás             |
| `activity_logs`    | user\_id, type, data, created\_at        | Beállítás, profilváltás stb.    |

---

## 3. BigQuery – Fogadási adatok tábla-struktúra (AI/analitika)

| Tábla         | Fő mezők                                                                                                           | Cél                                |
| ------------- | ------------------------------------------------------------------------------------------------------------------ | ---------------------------------- |
| `matches`     | match\_id, date, home\_team, away\_team, league, sport, venue, status                                              | Metaadat minden meccsről           |
| `markets`     | market\_id, match\_id, bookmaker, market\_type, point, last\_update                                                | Piacok (h2h, OU stb.)              |
| `outcomes`    | outcome\_id, market\_id, name, price, implied\_probability                                                         | Kimenetek oddsokkal                |
| `results`     | match\_id, score\_home, score\_away, winner, result\_type, evaluated\_at                                           | Eredmények                         |
| `features`    | match\_id, odds\_change, ai\_prediction, user\_votes, created\_at                                                  | AI inputok, aggregált mutatók      |
| `tickets`     | ticket\_id, user\_id, match\_id, bet\_index, market\_key, selection, odd, stake, placed\_at, result, evaluated\_at | Szelvények összes tippje soronként |
| `user_events` | user\_id, type, timestamp, meta                                                                                    | Badge, tranzakció, követés, fórum  |

---

## 4. Magyarázat, hosszú távú stabilitás

- Firestore csak aggregált, gyors elérésű, aktuális, UI-kritikus mezőket tárol.
- BigQuery-ben minden történeti, nagy tömegű adat, elemzésre/AI-ra kész szerkezetben él.
- Minden azonosító (match\_id, user\_id, market\_id, outcome\_id) egységes, szabványosított, kereshető.
- Események, piacok, tippek/ bets minden szinten tömbökben – bármikor bővíthető új sporttal, piac típussal, fogadóirodával.
- Felhasználói adatok: profil gyors (Firestore), minden más, ami nagytömegű – külön tábla.

---

Ez a vászon a projekt végleges adatmodellje. Bármilyen további bővítés, új piac vagy közösségi/AI funkció könnyen beépíthető – zárt, bővíthető és auditálható szerkezet. Hivatkozási alap minden backend/frontend/AI vagy analitikai fejlesztéshez.

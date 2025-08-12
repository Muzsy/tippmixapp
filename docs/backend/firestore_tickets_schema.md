# Firestore – `tickets` séma (provider‑független)

## Gyors áttekintés
Kollekció: `tickets/{ticketId}`

| Mező | Típus | Kötelező | Megjegyzés |
|---|---|---|---|
| userId | string | igen | Ticket tulajdonosa |
| createdAt | timestamp | igen | Szerver idő |
| status | string | igen | `pending|won|lost|void` |
| stake | number | igen | TippCoin tét |
| payout | number | igen | Záráskor számolt |
| tips | array<Tip> | igen | Lásd alább |
| processedAt | timestamp | nem | Finalizer állítja |

**Tip**
- fixtureId: string (API‑Football fixture ID)
- leagueId: string
- teamHomeId: string
- teamAwayId: string
- market: string (pl. `1X2|OU|BTTS|AH`)
- selection: string (pl. `HOME|DRAW|AWAY`, `OVER_2_5`)
- oddsSnapshot: number (kötelező)
- kickoff: timestamp

## Példadokumentum
```json
{
  "userId": "uid_123",
  "createdAt": {"_seconds": 1700000000, "_nanoseconds": 0},
  "status": "pending",
  "stake": 100,
  "payout": 0,
  "tips": [
    {
      "fixtureId": "120934",
      "leagueId": "39",
      "teamHomeId": "40",
      "teamAwayId": "50",
      "market": "1X2",
      "selection": "HOME",
      "oddsSnapshot": 1.85,
      "kickoff": {"_seconds": 1700003600, "_nanoseconds": 0}
    }
  ]
}
```

## Indexek
- `tickets`: (userId ASC, createdAt DESC)
- `tickets`: (status ASC, createdAt DESC)

## Megjegyzés
- A `tickets` írását Cloud Functions végzi Admin SDK‑val (rules megkerülve), ezért a kliens‑write tiltása biztonságos.

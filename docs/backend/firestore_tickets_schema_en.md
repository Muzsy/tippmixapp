# Firestore – `tickets` schema (provider‑agnostic)

## Quick overview
Collection: `users/{uid}/tickets/{ticketId}`

| Field | Type | Required | Notes |
|---|---|---|---|
| id | string | yes | Ticket document ID |
| userId | string | yes | Ticket owner |
| tips | array<Tip> | yes | See below |
| stake | number | yes | TippCoin stake |
| totalOdd | number | yes | Product of odds (2 decimals) |
| potentialWin | number | yes | `stake * totalOdd` |
| createdAt | timestamp | yes | Server time |
| updatedAt | timestamp | yes | Server time |
| status | string | yes | `pending|won|lost|void` |
| payout | number | no | Calculated at closure |
| processedAt | timestamp | no | Set by finalizer |

**Tip**
- fixtureId: string (API‑Football fixture ID)
- leagueId: string
- teamHomeId: string
- teamAwayId: string
- marketKey: string (e.g. `1X2|OU|BTTS|AH`)
- outcome: string (e.g. `HOME|DRAW|AWAY`, `OVER_2_5`)
- odds: number (required)
- kickoff: timestamp

## Sample document
```json
{
  "id": "abc123",
  "userId": "uid_123",
  "tips": [
    {
      "fixtureId": "120934",
      "leagueId": "39",
      "teamHomeId": "40",
      "teamAwayId": "50",
      "marketKey": "1X2",
      "outcome": "HOME",
      "odds": 1.85,
      "kickoff": {"_seconds": 1700003600, "_nanoseconds": 0}
    }
  ],
  "stake": 100,
  "totalOdd": 1.85,
  "potentialWin": 185,
  "createdAt": {"_seconds": 1700000000, "_nanoseconds": 0},
  "updatedAt": {"_seconds": 1700000000, "_nanoseconds": 0},
  "status": "pending",
  "payout": 0
}
```

## Indexes
- `users/{uid}/tickets`: (createdAt DESC)
- `users/{uid}/tickets`: (status ASC, createdAt DESC)

## Notes
- Clients create tickets under their own user document; Cloud Functions handle coin deductions and may aggregate reads via `collectionGroup('tickets')`.

# Firestore – `tickets` schema (provider‑agnostic)

## Quick overview
Collection: `tickets/{ticketId}`

| Field | Type | Required | Notes |
|---|---|---|---|
| userId | string | yes | Ticket owner |
| createdAt | timestamp | yes | Server time |
| status | string | yes | `pending|won|lost|void` |
| stake | number | yes | TippCoin stake |
| payout | number | yes | Calculated at closure |
| tips | array<Tip> | yes | See below |
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
      "marketKey": "1X2",
      "outcome": "HOME",
      "odds": 1.85,
      "kickoff": {"_seconds": 1700003600, "_nanoseconds": 0}
    }
  ]
}
```

## Indexes
- `tickets`: (userId ASC, createdAt DESC)
- `tickets`: (status ASC, createdAt DESC)

## Notes
- Cloud Functions write `tickets` via the Admin SDK (bypassing rules), so denying client writes is safe.

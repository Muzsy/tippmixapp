# 🏆 Leaderboard Logic (EN)

This document describes the design and logic of the TippmixApp leaderboard feature.

---

## 🎯 Purpose

* Show top TippCoin holders
* Motivate users via competitive ranking
* Used for profile badges and rewards (future)

---

## 📊 Ranking Criteria

* Based on total TippCoin balance
* Sorted descending by value
* Tiebreaker: registration date (earlier = higher)

---

## 📁 Firestore Design

Suggested collection:

```
leaderboard/{uid} → LeaderboardEntry
```

Example model:

```json
{
  "uid": "abc123",
  "displayName": "PlayerX",
  "tippCoin": 3150,
  "rank": 5,
  "avatarUrl": "..."
}
```

* Can be generated periodically (e.g. via Cloud Function)
* Avoid real-time sorting for performance

---

## 🔁 Update Strategy

* On TippCoin change: update cache
* Recompute full leaderboard daily
* Store top 100 in `leaderboard/`
* Each user can query own rank via cloud function (optional)

---

## 📌 UI Display

* `LeaderboardScreen` shows top 10
* Profile shows user’s own rank (if not in top 10)
* Highlight current user in list

---

## 🧪 Testing

* Snapshot test: leaderboard list rendering
* Unit test: sorting logic
* Integration test: rank updates